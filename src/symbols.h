/*
 * Symbol table.
 */
#ifndef __SYMBOLS_H__
#define __SYMBOLS_H__

typedef enum {
    SYM_NO_ERROR,
    SYM_EXISTS,
    SYM_NOT_FOUND,
    SYM_ERROR,
} sym_error_t;

typedef struct {
    const char* name;
} symbol_t;

typedef struct {
    const char* name;
} compound_symbol_t;

sym_error_t init_symbol_table();
sym_error_t add_symbol(const char* str, symbol_t* sym);
sym_error_t del_symbol(const char* str);
symbol_t* find_symbol(const char* str);
symbol_t* create_symbol(const char* str);

compound_symbol_t* create_compound(const char* str);
void add_compound(compound_symbol_t* sym, const char* str);


#endif
