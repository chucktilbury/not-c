/*
 *
 */
#ifndef __CONSTANTS_H__
#define __CONSTANTS_H__

typedef enum {
    CT_BOOL,
    CT_INUM,
    CT_UNUM,
    CT_FNUM,
    CT_STRG,
} const_type_t;

typedef struct {
    const_type_t type;
    union {
        bool bval;
        const char* sval;
        uint64_t uval;
        int64_t ival;
        double fval;
    } value;
} constant_t;

constant_t* make_const(const_type_t type);
constant_t* make_inum_const(int64_t ival);
constant_t* make_unum_const(uint64_t uval);
constant_t* make_fnum_const(double fval);
constant_t* make_bool_const(bool bval);
constant_t* make_strg_const(const char* sval);

#endif
