/*
 * Symbol table.
 */
#include "common.h"
#include "symbols.h"

sym_error_t init_symbol_table() {
    return SYM_NO_ERROR;
}

sym_error_t add_symbol(const char* str, symbol_t* sym) {
    (void)str;
    (void)sym;
    return SYM_NO_ERROR;
}

sym_error_t del_symbol(const char* str) {
    (void)str;
    return SYM_NO_ERROR;
}

symbol_t* find_symbol(const char* str) {
    (void)str;
    return NULL;
}

symbol_t* create_symbol(const char* str) {

    symbol_t* sym = ALLOC_DS(symbol_t);
    sym->name = STRDUP(str);
    return sym;
}

// compound symbols are stored as a list of segments. This implementation
// for development testing only.
compound_symbol_t* create_compound(const char* str) {

    compound_symbol_t* sym = ALLOC_DS(compound_symbol_t);
    sym->name = STRDUP(str);
    return sym;
}

void add_compound(compound_symbol_t* sym, const char* str) {

    char buf[1024]; // FIXME!
    if(sym != NULL) {
        if(sym->name != NULL) {
            strcpy(buf, sym->name);
            strcat(buf, ".");
            strcat(buf, str);
            FREE((void*)sym->name);
        }
        sym->name = STRDUP(buf);
    }
    else
        fatal_error("cannot allocate string in NULL compound symbol");
}
