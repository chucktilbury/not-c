/*
 * Make the constant values for the scanner.
 */
#include "common.h"
#include "constants.h"

constant_t* make_const(const_type_t type) {

    constant_t* ds = ALLOC_DS(constant_t);
    ds->type = type;
    return ds;
}

constant_t* make_inum_const(int64_t ival) {
    constant_t* ds = make_const(CT_INUM);
    ds->value.ival = ival;
    return ds;
}

constant_t* make_unum_const(uint64_t uval) {
    constant_t* ds = make_const(CT_UNUM);
    ds->value.uval = uval;
    return ds;
}

constant_t* make_fnum_const(double fval) {
    constant_t* ds = make_const(CT_FNUM);
    ds->value.fval = fval;
    return ds;
}

constant_t* make_bool_const(bool bval) {
    constant_t* ds = make_const(CT_BOOL);
    ds->value.bval = bval;
    return ds;
}

constant_t* make_strg_const(const char* sval) {
    constant_t* ds = make_const(CT_STRG);
    ds->value.sval = STRDUP(sval);
    return ds;
}
