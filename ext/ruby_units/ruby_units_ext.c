/*
 * ruby_units_ext.c - C extension for ruby-units
 *
 * Replaces hot-path Ruby methods with C implementations:
 *   - finalize_initialization (Phase 2)
 *   - eliminate_terms (Phase 3)
 *   - convert_scalar (Phase 4)
 *
 * The C code reads Ruby state directly via rb_ivar_get and rb_hash_aref.
 * No data is copied or synced -- everything lives in Ruby objects.
 *
 * Optimization: Definition object properties (kind, display_name, prefix?,
 * base?, unity?) are accessed via rb_ivar_get instead of rb_funcall to
 * eliminate Ruby method dispatch overhead (~300-700ns per call).
 */

#include <ruby.h>
#include <string.h>

/* ========================================================================
 * Interned IDs
 * ======================================================================== */

/* Unit instance variable IDs */
static ID id_iv_scalar;
static ID id_iv_numerator;
static ID id_iv_denominator;
static ID id_iv_base_scalar;
static ID id_iv_signature;
static ID id_iv_base;
static ID id_iv_unit_name;

/* Definition object ivar IDs (direct access, bypassing Ruby dispatch) */
static ID id_defn_kind;
static ID id_defn_display_name;
static ID id_defn_scalar;
static ID id_defn_numerator;
static ID id_defn_denominator;
static ID id_defn_name;

/* Method IDs (only for methods we still need to call via rb_funcall) */
static ID id_definitions;
static ID id_prefix_values;
static ID id_unit_values;
static ID id_cached;
static ID id_set;
static ID id_to_unit;
static ID id_parse_into_numbers_and_units;
static ID id_normalize_to_i;
static ID id_keys;
static ID id_concat;
static ID id_eq;
static ID id_to_r;

/* ========================================================================
 * Ruby symbol/string constants
 * ======================================================================== */

/* Hash key symbols */
static VALUE sym_scalar;
static VALUE sym_numerator;
static VALUE sym_denominator;
static VALUE sym_signature;

/* Kind symbols */
static VALUE sym_prefix;
static VALUE sym_length;
static VALUE sym_time;
static VALUE sym_temperature;
static VALUE sym_mass;
static VALUE sym_current;
static VALUE sym_substance;
static VALUE sym_luminosity;
static VALUE sym_currency;
static VALUE sym_information;
static VALUE sym_angle;

#define SIGNATURE_VECTOR_SIZE 10

/* Map from vector index to kind symbol (for pointer comparison) */
static VALUE signature_kind_symbols[SIGNATURE_VECTOR_SIZE];

/* Cached frozen strings */
static VALUE str_unity;       /* "<1>" */
static VALUE str_empty;       /* "" */

/* Cached class reference */
static VALUE cUnit;

/* ========================================================================
 * Inline helpers for Definition object property access
 *
 * These replace rb_funcall(defn, method, 0) with direct rb_ivar_get,
 * saving ~300-700ns per access.
 * ======================================================================== */

/*
 * Check if a token is the unity token "<1>"
 */
static inline int is_unity(VALUE token) {
    /* Fast pointer check first (works when token is the same frozen string) */
    if (token == str_unity) return 1;
    return rb_str_equal(token, str_unity) == Qtrue;
}

/*
 * Get Definition.kind via direct ivar access.
 * Returns the kind symbol (e.g., :length, :mass, :prefix).
 */
static inline VALUE defn_kind(VALUE defn) {
    return rb_ivar_get(defn, id_defn_kind);
}

/*
 * Get Definition.display_name via direct ivar access.
 */
static inline VALUE defn_display_name(VALUE defn) {
    return rb_ivar_get(defn, id_defn_display_name);
}

/*
 * Check Definition.prefix? -- kind == :prefix
 * Symbols are singletons, so pointer comparison is correct.
 */
static inline int defn_is_prefix(VALUE defn) {
    return rb_ivar_get(defn, id_defn_kind) == sym_prefix;
}

/*
 * Check Definition.base? without Ruby dispatch.
 * base? = scalar == 1 && numerator.size == 1 && denominator == ["<1>"]
 *         && numerator.first == "<@name>"
 */
static int defn_is_base(VALUE defn) {
    VALUE scalar = rb_ivar_get(defn, id_defn_scalar);
    /* Fast path for Fixnum 1 (most common) */
    if (scalar != INT2FIX(1)) {
        if (FIXNUM_P(scalar)) return 0;
        /* Handle Rational(1/1) etc. */
        if (rb_funcall(scalar, id_eq, 1, INT2FIX(1)) != Qtrue) return 0;
    }

    VALUE numerator = rb_ivar_get(defn, id_defn_numerator);
    if (NIL_P(numerator) || !RB_TYPE_P(numerator, T_ARRAY) || RARRAY_LEN(numerator) != 1)
        return 0;

    VALUE denominator = rb_ivar_get(defn, id_defn_denominator);
    if (NIL_P(denominator) || !RB_TYPE_P(denominator, T_ARRAY) || RARRAY_LEN(denominator) != 1)
        return 0;
    if (rb_str_equal(rb_ary_entry(denominator, 0), str_unity) != Qtrue)
        return 0;

    /* Check numerator.first == "<#{@name}>" */
    VALUE first_num = rb_ary_entry(numerator, 0);
    VALUE raw_name = rb_ivar_get(defn, id_defn_name); /* e.g., "meter" (no brackets) */

    if (!RB_TYPE_P(first_num, T_STRING) || NIL_P(raw_name) || !RB_TYPE_P(raw_name, T_STRING))
        return 0;

    const char *num_ptr = RSTRING_PTR(first_num);
    long num_len = RSTRING_LEN(first_num);
    const char *name_ptr = RSTRING_PTR(raw_name);
    long name_len = RSTRING_LEN(raw_name);

    if (num_len != name_len + 2) return 0;
    if (num_ptr[0] != '<' || num_ptr[num_len - 1] != '>') return 0;
    if (memcmp(num_ptr + 1, name_ptr, name_len) != 0) return 0;

    return 1;
}

/*
 * Check Definition.unity? -- prefix? && scalar == 1
 */
static inline int defn_is_unity(VALUE defn) {
    if (!defn_is_prefix(defn)) return 0;
    VALUE scalar = rb_ivar_get(defn, id_defn_scalar);
    return scalar == INT2FIX(1);
}

/*
 * Check if any tokens in numerator/denominator are temperature-related.
 * Replaces Ruby's temperature_tokens? method.
 * Checks for tokens starting with "<temp" or "<deg".
 */
static int has_temperature_token(VALUE numerator, VALUE denominator) {
    long i, len;
    VALUE token;
    const char *str;
    long slen;

    len = RARRAY_LEN(numerator);
    for (i = 0; i < len; i++) {
        token = rb_ary_entry(numerator, i);
        if (!RB_TYPE_P(token, T_STRING)) continue;
        str = RSTRING_PTR(token);
        slen = RSTRING_LEN(token);
        if (slen >= 6 && str[0] == '<' &&
            (strncmp(str + 1, "temp", 4) == 0 || strncmp(str + 1, "deg", 3) == 0))
            return 1;
    }

    len = RARRAY_LEN(denominator);
    for (i = 0; i < len; i++) {
        token = rb_ary_entry(denominator, i);
        if (!RB_TYPE_P(token, T_STRING)) continue;
        str = RSTRING_PTR(token);
        slen = RSTRING_LEN(token);
        if (slen >= 6 && str[0] == '<' &&
            (strncmp(str + 1, "temp", 4) == 0 || strncmp(str + 1, "deg", 3) == 0))
            return 1;
    }

    return 0;
}

/* ========================================================================
 * Core computation functions
 * ======================================================================== */

/*
 * Check if all tokens in numerator and denominator are base units.
 * Uses direct Definition ivar access instead of rb_funcall.
 */
static int check_base(VALUE definitions, VALUE numerator, VALUE denominator) {
    long i, len;
    VALUE token, defn;

    len = RARRAY_LEN(numerator);
    for (i = 0; i < len; i++) {
        token = rb_ary_entry(numerator, i);
        if (is_unity(token)) continue;

        defn = rb_hash_aref(definitions, token);
        if (NIL_P(defn)) return 0;

        if (defn_is_unity(defn)) continue;
        if (defn_is_base(defn)) continue;
        return 0;
    }

    len = RARRAY_LEN(denominator);
    for (i = 0; i < len; i++) {
        token = rb_ary_entry(denominator, i);
        if (is_unity(token)) continue;

        defn = rb_hash_aref(definitions, token);
        if (NIL_P(defn)) return 0;

        if (defn_is_unity(defn)) continue;
        if (defn_is_base(defn)) continue;
        return 0;
    }

    return 1;
}

/*
 * Compute base_scalar without creating intermediate Unit objects.
 * prefix_vals and unit_vals are passed in (fetched once by caller).
 */
static VALUE compute_base_scalar_c(VALUE scalar, VALUE numerator, VALUE denominator,
                                    VALUE prefix_vals, VALUE unit_vals) {
    VALUE factor = rb_rational_new(INT2FIX(1), INT2FIX(1));
    long i, len;
    VALUE token, pv, uv, uv_scalar;

    len = RARRAY_LEN(numerator);
    for (i = 0; i < len; i++) {
        token = rb_ary_entry(numerator, i);
        if (is_unity(token)) continue;

        pv = rb_hash_aref(prefix_vals, token);
        if (!NIL_P(pv)) {
            factor = rb_funcall(factor, '*', 1, pv);
        } else {
            uv = rb_hash_aref(unit_vals, token);
            if (!NIL_P(uv)) {
                uv_scalar = rb_hash_aref(uv, sym_scalar);
                if (!NIL_P(uv_scalar)) {
                    factor = rb_funcall(factor, '*', 1, uv_scalar);
                }
            }
        }
    }

    len = RARRAY_LEN(denominator);
    for (i = 0; i < len; i++) {
        token = rb_ary_entry(denominator, i);
        if (is_unity(token)) continue;

        pv = rb_hash_aref(prefix_vals, token);
        if (!NIL_P(pv)) {
            factor = rb_funcall(factor, '/', 1, pv);
        } else {
            uv = rb_hash_aref(unit_vals, token);
            if (!NIL_P(uv)) {
                uv_scalar = rb_hash_aref(uv, sym_scalar);
                if (!NIL_P(uv_scalar)) {
                    factor = rb_funcall(factor, '/', 1, uv_scalar);
                }
            }
        }
    }

    return rb_funcall(scalar, '*', 1, factor);
}

/*
 * Expand tokens into signature vector, accumulating with sign.
 * Uses direct ivar access for Definition.kind and pointer comparison
 * for symbol matching (symbols are singletons).
 */
static void expand_tokens_to_signature_c(VALUE tokens, int vector[SIGNATURE_VECTOR_SIZE], int sign,
                                          VALUE prefix_vals, VALUE unit_vals, VALUE definitions) {
    long i, len, j;
    VALUE token, uv, base_arr, bt, defn, kind_sym;

    len = RARRAY_LEN(tokens);
    for (i = 0; i < len; i++) {
        token = rb_ary_entry(tokens, i);
        if (is_unity(token)) continue;

        /* Skip prefix tokens - use rb_hash_aref instead of funcall key? */
        if (!NIL_P(rb_hash_aref(prefix_vals, token))) continue;

        uv = rb_hash_aref(unit_vals, token);
        if (!NIL_P(uv)) {
            /* Has a unit_values entry -- expand its base numerator/denominator */
            base_arr = rb_hash_aref(uv, sym_numerator);
            if (!NIL_P(base_arr)) {
                long blen = RARRAY_LEN(base_arr);
                for (j = 0; j < blen; j++) {
                    bt = rb_ary_entry(base_arr, j);
                    defn = rb_hash_aref(definitions, bt);
                    if (NIL_P(defn)) continue;
                    kind_sym = defn_kind(defn);
                    /* Pointer comparison -- symbols are singletons */
                    for (int k = 0; k < SIGNATURE_VECTOR_SIZE; k++) {
                        if (kind_sym == signature_kind_symbols[k]) {
                            vector[k] += sign;
                            break;
                        }
                    }
                }
            }
            base_arr = rb_hash_aref(uv, sym_denominator);
            if (!NIL_P(base_arr)) {
                long blen = RARRAY_LEN(base_arr);
                for (j = 0; j < blen; j++) {
                    bt = rb_ary_entry(base_arr, j);
                    defn = rb_hash_aref(definitions, bt);
                    if (NIL_P(defn)) continue;
                    kind_sym = defn_kind(defn);
                    for (int k = 0; k < SIGNATURE_VECTOR_SIZE; k++) {
                        if (kind_sym == signature_kind_symbols[k]) {
                            vector[k] -= sign;
                            break;
                        }
                    }
                }
            }
        } else {
            /* Direct base unit token */
            defn = rb_hash_aref(definitions, token);
            if (!NIL_P(defn)) {
                kind_sym = defn_kind(defn);
                for (int k = 0; k < SIGNATURE_VECTOR_SIZE; k++) {
                    if (kind_sym == signature_kind_symbols[k]) {
                        vector[k] += sign;
                        break;
                    }
                }
            }
        }
    }
}

/*
 * Compute signature from numerator/denominator.
 * Returns the integer signature (base-20 encoding of the signature vector).
 */
static long compute_signature_c(VALUE numerator, VALUE denominator,
                                 VALUE prefix_vals, VALUE unit_vals, VALUE definitions) {
    int vector[SIGNATURE_VECTOR_SIZE];
    int i;
    long signature = 0;
    long power = 1;

    for (i = 0; i < SIGNATURE_VECTOR_SIZE; i++) vector[i] = 0;

    expand_tokens_to_signature_c(numerator, vector, 1, prefix_vals, unit_vals, definitions);
    expand_tokens_to_signature_c(denominator, vector, -1, prefix_vals, unit_vals, definitions);

    for (i = 0; i < SIGNATURE_VECTOR_SIZE; i++) {
        if (abs(vector[i]) >= 20) {
            rb_raise(rb_eArgError, "Power out of range (-20 < net power of a unit < 20)");
        }
    }

    for (i = 0; i < SIGNATURE_VECTOR_SIZE; i++) {
        signature += vector[i] * power;
        power *= 20;
    }

    return signature;
}

/*
 * Build the units string from numerator/denominator arrays.
 * Uses direct ivar access for Definition properties.
 */
static VALUE build_units_string(VALUE definitions, VALUE numerator, VALUE denominator) {
    long num_len = RARRAY_LEN(numerator);
    long den_len = RARRAY_LEN(denominator);

    /* Quick check for unitless */
    if (num_len == 1 && den_len == 1 &&
        is_unity(rb_ary_entry(numerator, 0)) &&
        is_unity(rb_ary_entry(denominator, 0))) {
        return str_empty;
    }

    VALUE output_num = rb_ary_new();
    VALUE output_den = rb_ary_new();
    long i;
    VALUE token, defn, display, current_str;

    /* Process numerator: group prefixes with their units */
    if (!(num_len == 1 && is_unity(rb_ary_entry(numerator, 0)))) {
        current_str = Qnil;
        for (i = 0; i < num_len; i++) {
            token = rb_ary_entry(numerator, i);
            defn = rb_hash_aref(definitions, token);
            if (NIL_P(defn)) continue;

            display = defn_display_name(defn);
            if (defn_is_prefix(defn)) {
                current_str = rb_str_dup(display);
            } else {
                if (!NIL_P(current_str)) {
                    rb_str_append(current_str, display);
                    rb_ary_push(output_num, current_str);
                    current_str = Qnil;
                } else {
                    rb_ary_push(output_num, rb_str_dup(display));
                }
            }
        }
    }

    /* Process denominator: same grouping */
    if (!(den_len == 1 && is_unity(rb_ary_entry(denominator, 0)))) {
        current_str = Qnil;
        for (i = 0; i < den_len; i++) {
            token = rb_ary_entry(denominator, i);
            defn = rb_hash_aref(definitions, token);
            if (NIL_P(defn)) continue;

            display = defn_display_name(defn);
            if (defn_is_prefix(defn)) {
                current_str = rb_str_dup(display);
            } else {
                if (!NIL_P(current_str)) {
                    rb_str_append(current_str, display);
                    rb_ary_push(output_den, current_str);
                    current_str = Qnil;
                } else {
                    rb_ary_push(output_den, rb_str_dup(display));
                }
            }
        }
    }

    /* If numerator is empty, use "1" */
    if (RARRAY_LEN(output_num) == 0) {
        rb_ary_push(output_num, rb_str_new_cstr("1"));
    }

    /* Build result string with exponent notation for repeated units */
    VALUE result = rb_str_buf_new(64);
    VALUE seen = rb_hash_new();
    long total;

    total = RARRAY_LEN(output_num);
    int first = 1;
    for (i = 0; i < total; i++) {
        VALUE elem = rb_ary_entry(output_num, i);
        if (rb_hash_aref(seen, elem) != Qnil) continue;

        long count = 0;
        long j;
        for (j = 0; j < total; j++) {
            if (rb_str_equal(rb_ary_entry(output_num, j), elem) == Qtrue) count++;
        }
        rb_hash_aset(seen, elem, Qtrue);

        if (!first) rb_str_cat_cstr(result, "*");
        first = 0;

        /* Display names don't have leading/trailing whitespace, skip strip */
        rb_str_append(result, elem);
        if (count > 1) {
            char buf[16];
            snprintf(buf, sizeof(buf), "^%ld", count);
            rb_str_cat_cstr(result, buf);
        }
    }

    /* Build denominator string */
    total = RARRAY_LEN(output_den);
    if (total > 0) {
        rb_str_cat_cstr(result, "/");
        seen = rb_hash_new();
        first = 1;
        for (i = 0; i < total; i++) {
            VALUE elem = rb_ary_entry(output_den, i);
            if (rb_hash_aref(seen, elem) != Qnil) continue;

            long count = 0;
            long j;
            for (j = 0; j < total; j++) {
                if (rb_str_equal(rb_ary_entry(output_den, j), elem) == Qtrue) count++;
            }
            rb_hash_aset(seen, elem, Qtrue);

            if (!first) rb_str_cat_cstr(result, "*");
            first = 0;

            rb_str_append(result, elem);
            if (count > 1) {
                char buf[16];
                snprintf(buf, sizeof(buf), "^%ld", count);
                rb_str_cat_cstr(result, buf);
            }
        }
    }

    return result;
}

/* ========================================================================
 * Public Ruby methods
 * ======================================================================== */

/*
 * Phase 2: rb_unit_finalize - replaces finalize_initialization
 *
 * Called from Ruby's initialize after parsing is complete.
 * Computes base?, base_scalar, signature, builds units string, caches, and freezes.
 *
 * Returns Qtrue on success, Qfalse if temperature tokens detected (caller
 * should fall back to Ruby path).
 *
 * call-seq:
 *   unit._c_finalize(options_first_arg) -> true/false
 */
static VALUE rb_unit_finalize(VALUE self, VALUE options_first) {
    VALUE unit_class = rb_obj_class(self);
    VALUE scalar = rb_ivar_get(self, id_iv_scalar);
    VALUE numerator = rb_ivar_get(self, id_iv_numerator);
    VALUE denominator = rb_ivar_get(self, id_iv_denominator);
    VALUE signature = rb_ivar_get(self, id_iv_signature);

    /* Guard: fall back to Ruby if ivars aren't arrays yet */
    if (NIL_P(numerator) || !RB_TYPE_P(numerator, T_ARRAY) ||
        NIL_P(denominator) || !RB_TYPE_P(denominator, T_ARRAY)) {
        return Qfalse;
    }

    /* Check for temperature tokens -- fall back to Ruby path */
    if (has_temperature_token(numerator, denominator)) {
        return Qfalse;
    }

    /* Fetch class-level hashes ONCE and pass to all helpers */
    VALUE definitions = rb_funcall(unit_class, id_definitions, 0);
    VALUE prefix_vals = rb_funcall(unit_class, id_prefix_values, 0);
    VALUE unit_vals = rb_funcall(unit_class, id_unit_values, 0);

    int is_base;
    VALUE base_scalar_val;
    long sig_val;

    /* 1. Compute base?, base_scalar, signature */
    if (!NIL_P(signature)) {
        /* Signature was pre-supplied (e.g., from arithmetic fast-path) */
        is_base = check_base(definitions, numerator, denominator);
        if (is_base) {
            base_scalar_val = scalar;
        } else {
            base_scalar_val = compute_base_scalar_c(scalar, numerator, denominator,
                                                     prefix_vals, unit_vals);
        }
        sig_val = NUM2LONG(signature);
    } else {
        is_base = check_base(definitions, numerator, denominator);
        if (is_base) {
            base_scalar_val = scalar;
            sig_val = compute_signature_c(numerator, denominator,
                                           prefix_vals, unit_vals, definitions);
        } else {
            base_scalar_val = compute_base_scalar_c(scalar, numerator, denominator,
                                                     prefix_vals, unit_vals);
            sig_val = compute_signature_c(numerator, denominator,
                                           prefix_vals, unit_vals, definitions);
        }
    }

    rb_ivar_set(self, id_iv_base, is_base ? Qtrue : Qfalse);
    rb_ivar_set(self, id_iv_base_scalar, base_scalar_val);
    rb_ivar_set(self, id_iv_signature, LONG2NUM(sig_val));

    /* 2. Build units string */
    VALUE unary_unit = build_units_string(definitions, numerator, denominator);
    rb_ivar_set(self, id_iv_unit_name, unary_unit);

    /* 3. Cache the unit if appropriate */
    int scalar_is_one = FIXNUM_P(scalar) ? (scalar == INT2FIX(1))
                        : (rb_funcall(scalar, id_eq, 1, INT2FIX(1)) == Qtrue);

    if (RB_TYPE_P(options_first, T_STRING)) {
        VALUE parse_result = rb_funcall(unit_class, id_parse_into_numbers_and_units, 1, options_first);
        VALUE opt_units = rb_ary_entry(parse_result, 1);
        if (!NIL_P(opt_units) && RSTRING_LEN(opt_units) > 0) {
            VALUE cache = rb_funcall(unit_class, id_cached, 0);
            if (scalar_is_one) {
                rb_funcall(cache, id_set, 2, opt_units, self);
            } else {
                VALUE unit_from_str = rb_funcall(opt_units, id_to_unit, 0);
                rb_funcall(cache, id_set, 2, opt_units, unit_from_str);
            }
        }
    }

    if (RSTRING_LEN(unary_unit) > 0) {
        VALUE cache = rb_funcall(unit_class, id_cached, 0);
        if (scalar_is_one) {
            rb_funcall(cache, id_set, 2, unary_unit, self);
        } else {
            VALUE unit_from_str = rb_funcall(unary_unit, id_to_unit, 0);
            rb_funcall(cache, id_set, 2, unary_unit, unit_from_str);
        }
    }

    /* 4. Freeze instance variables using rb_obj_freeze (direct C API, no dispatch) */
    rb_obj_freeze(scalar);
    rb_obj_freeze(numerator);
    rb_obj_freeze(denominator);
    rb_obj_freeze(base_scalar_val);
    /* Fixnums, true/false, and nil are always frozen -- skip */

    return Qtrue;
}

/*
 * Phase 3: rb_unit_eliminate_terms - replaces eliminate_terms class method
 *
 * Uses direct Definition ivar access instead of rb_funcall for prefix? check.
 */
static VALUE rb_unit_eliminate_terms(VALUE klass, VALUE scalar, VALUE numerator, VALUE denominator) {
    VALUE definitions = rb_funcall(klass, id_definitions, 0);
    VALUE combined = rb_hash_new();
    long i, len;
    VALUE token, defn;

    /* Count numerator groups */
    VALUE current_group = rb_ary_new();
    len = RARRAY_LEN(numerator);
    for (i = 0; i < len; i++) {
        token = rb_ary_entry(numerator, i);
        if (is_unity(token)) continue;

        rb_ary_push(current_group, token);
        defn = rb_hash_aref(definitions, token);
        if (NIL_P(defn) || !defn_is_prefix(defn)) {
            VALUE existing = rb_hash_aref(combined, current_group);
            long val = NIL_P(existing) ? 0 : NUM2LONG(existing);
            rb_hash_aset(combined, current_group, LONG2NUM(val + 1));
            current_group = rb_ary_new();
        }
    }

    /* Count denominator groups */
    current_group = rb_ary_new();
    len = RARRAY_LEN(denominator);
    for (i = 0; i < len; i++) {
        token = rb_ary_entry(denominator, i);
        if (is_unity(token)) continue;

        rb_ary_push(current_group, token);
        defn = rb_hash_aref(definitions, token);
        if (NIL_P(defn) || !defn_is_prefix(defn)) {
            VALUE existing = rb_hash_aref(combined, current_group);
            long val = NIL_P(existing) ? 0 : NUM2LONG(existing);
            rb_hash_aset(combined, current_group, LONG2NUM(val - 1));
            current_group = rb_ary_new();
        }
    }

    /* Build result arrays */
    VALUE result_num = rb_ary_new();
    VALUE result_den = rb_ary_new();

    VALUE keys = rb_funcall(combined, id_keys, 0);
    long keys_len = RARRAY_LEN(keys);
    for (i = 0; i < keys_len; i++) {
        VALUE key = rb_ary_entry(keys, i);
        long val = NUM2LONG(rb_hash_aref(combined, key));
        long j;
        if (val > 0) {
            for (j = 0; j < val; j++) {
                rb_funcall(result_num, id_concat, 1, key);
            }
        } else if (val < 0) {
            for (j = 0; j < -val; j++) {
                rb_funcall(result_den, id_concat, 1, key);
            }
        }
    }

    /* Default to UNITY_ARRAY if empty */
    if (RARRAY_LEN(result_num) == 0) result_num = rb_ary_new_from_args(1, str_unity);
    if (RARRAY_LEN(result_den) == 0) result_den = rb_ary_new_from_args(1, str_unity);

    VALUE result = rb_hash_new();
    rb_hash_aset(result, sym_scalar, scalar);
    rb_hash_aset(result, sym_numerator, result_num);
    rb_hash_aset(result, sym_denominator, result_den);
    return result;
}

/*
 * Phase 4: rb_unit_convert_scalar - computes conversion factor between two units
 */
static VALUE rb_unit_convert_scalar(VALUE klass, VALUE self_unit, VALUE target_unit) {
    VALUE prefix_vals = rb_funcall(klass, id_prefix_values, 0);
    VALUE unit_vals = rb_funcall(klass, id_unit_values, 0);
    VALUE self_num = rb_ivar_get(self_unit, id_iv_numerator);
    VALUE self_den = rb_ivar_get(self_unit, id_iv_denominator);
    VALUE target_num = rb_ivar_get(target_unit, id_iv_numerator);
    VALUE target_den = rb_ivar_get(target_unit, id_iv_denominator);
    VALUE self_scalar = rb_ivar_get(self_unit, id_iv_scalar);

    long i, len;
    VALUE token, pv, uv, uv_scalar;

    #define COMPUTE_ARRAY_SCALAR(arr, result_var) do { \
        result_var = INT2FIX(1); \
        len = RARRAY_LEN(arr); \
        for (i = 0; i < len; i++) { \
            token = rb_ary_entry(arr, i); \
            pv = rb_hash_aref(prefix_vals, token); \
            if (!NIL_P(pv)) { \
                result_var = rb_funcall(result_var, '*', 1, pv); \
            } else { \
                uv = rb_hash_aref(unit_vals, token); \
                if (!NIL_P(uv)) { \
                    uv_scalar = rb_hash_aref(uv, sym_scalar); \
                    if (!NIL_P(uv_scalar)) { \
                        result_var = rb_funcall(result_var, '*', 1, uv_scalar); \
                    } \
                } \
            } \
        } \
    } while(0)

    VALUE self_num_scalar, self_den_scalar, target_num_scalar, target_den_scalar;

    COMPUTE_ARRAY_SCALAR(self_num, self_num_scalar);
    COMPUTE_ARRAY_SCALAR(self_den, self_den_scalar);
    COMPUTE_ARRAY_SCALAR(target_num, target_num_scalar);
    COMPUTE_ARRAY_SCALAR(target_den, target_den_scalar);

    #undef COMPUTE_ARRAY_SCALAR

    VALUE numerator_factor = rb_funcall(self_num_scalar, '*', 1, target_den_scalar);
    VALUE denominator_factor = rb_funcall(target_num_scalar, '*', 1, self_den_scalar);

    VALUE conversion_scalar;
    if (RB_TYPE_P(self_scalar, T_FIXNUM) || RB_TYPE_P(self_scalar, T_BIGNUM)) {
        conversion_scalar = rb_funcall(self_scalar, id_to_r, 0);
    } else {
        conversion_scalar = self_scalar;
    }

    VALUE converted = rb_funcall(conversion_scalar, '*', 1, numerator_factor);
    converted = rb_funcall(converted, '/', 1, denominator_factor);
    converted = rb_funcall(klass, id_normalize_to_i, 1, converted);

    return converted;
}

/* ========================================================================
 * Module initialization
 * ======================================================================== */

void Init_ruby_units_ext(void) {
    /* Unit instance variable IDs */
    id_iv_scalar = rb_intern("@scalar");
    id_iv_numerator = rb_intern("@numerator");
    id_iv_denominator = rb_intern("@denominator");
    id_iv_base_scalar = rb_intern("@base_scalar");
    id_iv_signature = rb_intern("@signature");
    id_iv_base = rb_intern("@base");
    id_iv_unit_name = rb_intern("@unit_name");

    /* Definition object ivar IDs */
    id_defn_kind = rb_intern("@kind");
    id_defn_display_name = rb_intern("@display_name");
    id_defn_scalar = rb_intern("@scalar");
    id_defn_numerator = rb_intern("@numerator");
    id_defn_denominator = rb_intern("@denominator");
    id_defn_name = rb_intern("@name");

    /* Method IDs (only those still needed) */
    id_definitions = rb_intern("definitions");
    id_prefix_values = rb_intern("prefix_values");
    id_unit_values = rb_intern("unit_values");
    id_cached = rb_intern("cached");
    id_set = rb_intern("set");
    id_to_unit = rb_intern("to_unit");
    id_parse_into_numbers_and_units = rb_intern("parse_into_numbers_and_units");
    id_normalize_to_i = rb_intern("normalize_to_i");
    id_keys = rb_intern("keys");
    id_concat = rb_intern("concat");
    id_eq = rb_intern("==");
    id_to_r = rb_intern("to_r");

    /* Hash key symbols */
    sym_scalar = ID2SYM(rb_intern("scalar"));
    sym_numerator = ID2SYM(rb_intern("numerator"));
    sym_denominator = ID2SYM(rb_intern("denominator"));
    sym_signature = ID2SYM(rb_intern("signature"));

    /* Kind symbols */
    sym_prefix = ID2SYM(rb_intern("prefix"));
    sym_length = ID2SYM(rb_intern("length"));
    sym_time = ID2SYM(rb_intern("time"));
    sym_temperature = ID2SYM(rb_intern("temperature"));
    sym_mass = ID2SYM(rb_intern("mass"));
    sym_current = ID2SYM(rb_intern("current"));
    sym_substance = ID2SYM(rb_intern("substance"));
    sym_luminosity = ID2SYM(rb_intern("luminosity"));
    sym_currency = ID2SYM(rb_intern("currency"));
    sym_information = ID2SYM(rb_intern("information"));
    sym_angle = ID2SYM(rb_intern("angle"));

    signature_kind_symbols[0] = sym_length;
    signature_kind_symbols[1] = sym_time;
    signature_kind_symbols[2] = sym_temperature;
    signature_kind_symbols[3] = sym_mass;
    signature_kind_symbols[4] = sym_current;
    signature_kind_symbols[5] = sym_substance;
    signature_kind_symbols[6] = sym_luminosity;
    signature_kind_symbols[7] = sym_currency;
    signature_kind_symbols[8] = sym_information;
    signature_kind_symbols[9] = sym_angle;

    /* Mark all symbols/strings as GC roots */
    rb_gc_register_address(&sym_scalar);
    rb_gc_register_address(&sym_numerator);
    rb_gc_register_address(&sym_denominator);
    rb_gc_register_address(&sym_signature);
    rb_gc_register_address(&sym_prefix);
    rb_gc_register_address(&sym_length);
    rb_gc_register_address(&sym_time);
    rb_gc_register_address(&sym_temperature);
    rb_gc_register_address(&sym_mass);
    rb_gc_register_address(&sym_current);
    rb_gc_register_address(&sym_substance);
    rb_gc_register_address(&sym_luminosity);
    rb_gc_register_address(&sym_currency);
    rb_gc_register_address(&sym_information);
    rb_gc_register_address(&sym_angle);

    str_unity = rb_str_freeze(rb_str_new_cstr("<1>"));
    rb_gc_register_address(&str_unity);

    str_empty = rb_str_freeze(rb_str_new_cstr(""));
    rb_gc_register_address(&str_empty);

    /* Get the Unit class and define methods */
    VALUE mRubyUnits = rb_define_module("RubyUnits");
    cUnit = rb_define_class_under(mRubyUnits, "Unit", rb_cNumeric);

    /* Instance methods */
    rb_define_private_method(cUnit, "_c_finalize", rb_unit_finalize, 1);

    /* Class methods */
    rb_define_singleton_method(cUnit, "_c_eliminate_terms", rb_unit_eliminate_terms, 3);
    rb_define_singleton_method(cUnit, "_c_convert_scalar", rb_unit_convert_scalar, 2);
}
