/**
 * @file scanner.h
 * @brief Definitions and prototypes for the code located in scanner.l
 */
#ifndef __SCANNER_H__
#define __SCANNER_H__

#include <stdio.h>
//#include "parser.h"

char *get_file_name(void);
int get_line_number(void);
int get_col_number(void);
int open_file(const char *fname);
const char *get_tok_str(void);
int get_token(void);

/*
 * Defined by flex. Call one time to isolate a symbol and then use the global
 * symbol struct to access the symbol.
 */
extern int yylex(void);
extern int yyparse(void);
extern FILE *yyin;

// void yyerror(char *s, ...);
void yyerror(const char *s);


#define TOK_TOSTR(t) ( \
    ((t) == FPCONST)? "FPCONST": \
    ((t) == INTCONST)? "INTCONST": \
    ((t) == UINTCONST)? "UINTCONST": \
    ((t) == STRCONST)? "STRCONST": \
    ((t) == BOOLCONST)? "BOOLCONST": \
    ((t) == SYMBOL)? "SYMBOL": \
    ((t) == DICT)? "DICT": \
    ((t) == LIST)? "LIST": \
    ((t) == BOOL)? "BOOL": \
    ((t) == STRING)? "STRING": \
    ((t) == FLOAT)? "FLOAT": \
    ((t) == INT)? "INT": \
    ((t) == UINT)? "UINT": \
    ((t) == NOTHING)? "NOTHING": \
    ((t) == SWITCH)? "SWITCH": \
    ((t) == CASE)? "CASE": \
    ((t) == DEFAULT)? "DEFAULT": \
    ((t) == RETURN)? "RETURN": \
    ((t) == IF)? "IF": \
    ((t) == ELSE)? "ELSE": \
    ((t) == WHILE)? "WHILE": \
    ((t) == DO)? "DO": \
    ((t) == BREAK)? "BREAK": \
    ((t) == CONTINUE)? "CONTINUE": \
    ((t) == AND)? "AND": \
    ((t) == OR)? "OR": \
    ((t) == NOT)? "NOT": \
    ((t) == EQ)? "EQ": \
    ((t) == NEQ)? "NEQ": \
    ((t) == LTE)? "LTE": \
    ((t) == GTE)? "GTE": \
    ((t) == LT)? "LT": \
    ((t) == GT)? "GT": \
    ((t) == PUBLIC)? "PUBLIC": \
    ((t) == PRIVATE)? "PRIVATE": \
    ((t) == ENTRY)? "ENTRY": \
    ((t) == CONST)? "CONST": \
    ((t) == STRUCT)? "STRUCT": \
    ((t) == INIT)? "INIT": \
    ((t) == USR_TYPE)? "USR_TYPE": \
    ((t) == DEINIT)? "DEINIT": "UNKNOWN")\


#endif
