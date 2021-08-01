

#ifndef __SYMBOLS_H__
#define __SYMBOLS_H__

#include <stdbool.h>
#include "object.h"

typedef enum {
    SYM_NO_ERROR,
    SYM_NOT_FOUND,
    SYM_EXISTS,
    SYM_NOT_ASSIGNED,
    SYM_TRUE,
    SYM_FALSE,
} symbols_error_t;

#define SE_TOSTR(e) ( \
    ((e) == SYM_NO_ERROR)? "NO_ERROR" :\
    ((e) == SYM_NOT_FOUND)? "NOT_FOUND" :\
    ((e) == SYM_NOT_ASSIGNED)? "NOT_ASSIGNED" :\
    ((e) == SYM_EXISTS)? "EXISTS" :\
    ((e) == SYM_TRUE)? "TRUE" :\
    ((e) == SYM_FALSE)? "FALSE" : "UNKNOWN"\
    )

typedef enum {
    ST_OBJECT,
    ST_INUM,
    ST_UNUM,
    ST_FNUM,
    ST_STRING,
    ST_BOOL,
} symbol_type_t;

#define ST_TOSTR(t) (\
    ((t) == ST_OBJECT)? "OBJECT": \
    ((t) == ST_INUM)? "INUM": \
    ((t) == ST_UNUM)? "UNUM": \
    ((t) == ST_FNUM)? "FNUM": \
    ((t) == ST_STRING)? "STRING": \
    ((t) == ST_BOOL)? "BOOL": "UNKNOWN"\
    )

/*
 * Symbol table data entry.
 */
typedef struct {
    symbol_type_t type;
    union {
        object_t* obj;
        long inum;
        unsigned long unum;
        double fnum;
        char* str;
        unsigned char boolean;
    } value;
    unsigned char is_assigned:1;
    unsigned char is_const:1;
    unsigned char is_private:1;
} symbol_data_t;

/*
 * Symbol table entry.
 */
typedef struct _ste_t_ {
    const char* name;
    symbol_data_t* value; // standard attributes of a symbol
    struct _ste_t_* left;
    struct _ste_t_* right;
    int line_no; // source code line where symbol is defined
    int col_no; // source code column where symbol is defined
} symbol_table_t;

symbols_error_t add_symbol(const char* name, symbol_data_t* val);
symbols_error_t update_symbol(const char* name, symbol_data_t* val);
symbols_error_t find_symbol(const char* name, symbol_data_t* val);
symbols_error_t symbol_is_assigned(const char* name);
symbols_error_t symbol_is_const(const char* name);
symbols_error_t symbol_is_private(const char* name);

symbol_data_t* create_symbol_data(symbol_type_t type,
                        unsigned char is_const,
                        unsigned char is_private);

symbols_error_t add_obj_symbol(const char* name, object_t* obj,
                        unsigned char is_const,
                        unsigned char is_private);

symbols_error_t add_inum_symbol(const char* name, long inum,
                        unsigned char is_assigned,
                        unsigned char is_const,
                        unsigned char is_private);

symbols_error_t add_unum_symbol(const char* name, unsigned long unum,
                        unsigned char is_assigned,
                        unsigned char is_const,
                        unsigned char is_private);

symbols_error_t add_fnum_symbol(const char* name, double fnum,
                        unsigned char is_assigned,
                        unsigned char is_const,
                        unsigned char is_private);

symbols_error_t add_str_symbol(const char* name, char* str,
                        unsigned char is_assigned,
                        unsigned char is_const,
                        unsigned char is_private);

symbols_error_t add_bool_symbol(const char* name, unsigned char boolean,
                        unsigned char is_assigned,
                        unsigned char is_const,
                        unsigned char is_private);


void dump_symbols();

#endif
