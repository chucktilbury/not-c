/*
 * ANSI C grammar, Lex specification
 *
 * (This Lex file is accompanied by a matching Yacc file.)
 *
 * In 1985, Jeff Lee published his Yacc grammar based on a draft version of
 * the ANSI C standard, along with a supporting Lex specification. Tom
 * Stockfisch reposted those files to net.sources in 1987; as mentioned in the
 * answer to question 17.25 of the comp.lang.c FAQ, they used to be available
 * from ftp.uu.net as usenet/net.sources/ansi.c.grammar.Z.
 *
 * The version you see here has been updated based on the 2011 ISO C standard.
 * (The previous version's Lex and Yacc files for ANSI C9X still exist as
 * archived copies.)
 *
 * It is assumed that translation phases 1..5 have already been completed,
 * including preprocessing and _Pragma processing. The Lex rule for string
 * literals will perform concatenation (translation phase 6). Transliteration
 * of universal character names (\uHHHH or \UHHHHHHHH) must have been done by
 * either the preprocessor or a replacement for the input() macro used by Lex
 * (or the YY_INPUT function used by Flex) to read characters. Although
 * comments should have been changed to space characters during translation
 * phase 3, there are Lex rules for them anyway.
 *
 * I want to keep this version as close to the current C Standard grammar as
 * possible; please let me know if you discover discrepancies.
 *
 * (There is an FAQ for this grammar that you might want to read first.)
 *
 * jutta@pobox.com, 2012
 *
 */

%{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wimplicit-function-declaration"
#pragma GCC diagnostic ignored "-Wunused-function"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"
#include "memory.h"

extern void yyerror(const char *);  /* prints grammar violation message */

extern int sym_type(const char *);  /* returns type from symbol table */

#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */

static int check_type(void);

int col_no = 1;
int line_no = 1;

static void update_loc(void){

    yylloc.first_line   = line_no;
    yylloc.first_column = col_no;

    for(char *s = yytext; *s != '\0'; s++) {
        col_no++;
    }

    yylloc.last_line   = line_no;
    yylloc.last_column = col_no-1;
}

#define YY_USER_ACTION update_loc();

typedef struct {
    size_t cap;
    size_t len;
    char* buf;
} _str_buffer;

_str_buffer* sbuf = NULL;

void init_scanner(const char* fname) {

    yyin = fopen(fname, "r");
    if(yyin == NULL) {
        fprintf(stderr, "Cannot open input file: %s: %s\n", fname, strerror(errno));
        exit(1);
    }

    sbuf = ALLOC_DS(_str_buffer);
    sbuf->cap = 0x01 << 3;
    sbuf->len = 0;
    sbuf->buf = ALLOC_LST(sbuf->cap, char);
}

void destroy_scanner() {

    fclose(yyin);
    if(sbuf != NULL) {
        if(sbuf->buf != NULL)
            FREE(sbuf->buf);
        FREE(sbuf);
    }
}

static void resize_str_buffer() {

    if(sbuf != NULL) {
        if(sbuf->len+2 >= sbuf->cap) {
            sbuf->cap <<= 1;
            sbuf->buf = REALLOC_LST(sbuf->buf, sbuf->cap, char);
        }
    }
}

static void add_char(int ch) {

    resize_str_buffer();
    sbuf->buf[sbuf->len] = (char)ch;
    sbuf->buf[sbuf->len+1] = '\0';
    sbuf->len++;
}

static void reset_buffer() {
    sbuf->len = 0;
}

static void add_str(const char* str) {

    // quick and dirty
    for(int i = 0; str[i] != 0; i++)
        add_char(str[i]);
}

%}

%x COMMENT
%x SQUOTES
%x DQUOTES

%%

    /* recognize and ignore comments */
[/][*]+ { BEGIN(COMMENT); }
<COMMENT>[*]+[/] { BEGIN(INITIAL); }
<COMMENT>\n { line_no++; yylineno++; }
<COMMENT>.  {}  /* eat everything in between */

    /* eat up until the newline */
[/][/].* { ;
    }

"float" {
        yylval.type_name = DUPSTR(yytext);
        return(FLOAT);
    }
"int" {
        yylval.type_name = DUPSTR(yytext);
        return(INT);
    }
"uint" {
        yylval.type_name = DUPSTR(yytext);
        return(UINT);
    }
"nothing" {
        yylval.type_name = DUPSTR(yytext);
        return(NOTHING);
    }
"bool" {
        yylval.type_name = DUPSTR(yytext);
        return BOOL;
    }
"string" {
        yylval.type_name = DUPSTR(yytext);
        return STRING;
    }

"break"                 { return(BREAK); }
"case"                  { return(CASE); }
"const"                 { return(CONST); }
"continue"              { return(CONTINUE); }
"default"               { return(DEFAULT); }
"do"                    { return(DO); }
"else"                  { return(ELSE); }
"for"                   { return(FOR); }
"if"                    { return(IF); }
"return"                { return(RETURN); }
"struct"                { return(STRUCT); }
"switch"                { return(SWITCH); }
"while"                 { return(WHILE); }
"namespace"             { return(NAMESPACE); }
"import"                { return(IMPORT); }
"ctor"                  { return(CTOR); }
"dtor"                  { return(DTOR); }
"entry"                 { return(ENTRY); }
"list"                  { return(LIST); }
"dict"                  { return(DICT); }
"public"                { return(PUBLIC); }
"private"               { return(PRIVATE); }

"true" {
        yylval.int_literal = 1;
        return B_CONSTANT;
    }

"false" {
        yylval.int_literal = 0;
        return B_CONSTANT;
    }

"+="                    { return ADD_ASSIGN; }
"-="                    { return SUB_ASSIGN; }
"*="                    { return MUL_ASSIGN; }
"/="                    { return DIV_ASSIGN; }
"%="                    { return MOD_ASSIGN; }
"&&"|"and"              { return AND_OP; }
"||"|"or"               { return OR_OP; }
"<="|"le"               { return LE_OP; }
">="|"ge"               { return GE_OP; }
"=="|"eq"               { return EQ_OP; }
"!="|"ne"               { return NE_OP; }

[a-zA-Z_][a-zA-Z_0-9]* {
        yylval.identifier = DUPSTR(yytext);
        return check_type();
    }

(0[xX])[a-fA-F0-9]+ {
        yylval.uint_literal = strtol(yytext, NULL, 16);
        return U_CONSTANT;
    }

[1-9][0-9]*|0 {
        yylval.int_literal = strtol(yytext, NULL, 10);
        return I_CONSTANT;
    }

[0-9]+([Ee][+-]?[0-9]+) {
        yylval.float_literal = strtod(yytext, NULL);
        return F_CONSTANT;
    }

[0-9]*\.[0-9]+([Ee][+-]?[0-9]+)? {
        yylval.float_literal = strtod(yytext, NULL);
        return F_CONSTANT;
    }

    /* double quoted strings have escapes managed */
\"  {
        reset_buffer();
        BEGIN(DQUOTES);
    }

<DQUOTES>\" {
        yylval.str_literal = DUPSTR(sbuf->buf);
        BEGIN(INITIAL);
        return STRING_LITERAL;
    }

    /* the short rule matches before the long one does */
<DQUOTES>\\n    { add_char('\n'); }
<DQUOTES>\\r    { add_char('\r'); }
<DQUOTES>\\e    { add_char('\x1b'); }
<DQUOTES>\\t    { add_char('\t'); }
<DQUOTES>\\b    { add_char('\b'); }
<DQUOTES>\\f    { add_char('\f'); }
<DQUOTES>\\v    { add_char('\v'); }
<DQUOTES>\\\\   { add_char('\\'); }
<DQUOTES>\\\"   { add_char('\"'); }
<DQUOTES>\\\'   { add_char('\''); }
<DQUOTES>\\\?   { add_char('\?'); }
<DQUOTES>\\.    { add_char(yytext[1]); }
<DQUOTES>\\[0-7]{1,3} { add_char((char)strtol(yytext+1, 0, 8));  }
<DQUOTES>\\[xX][0-9a-fA-F]{1,3} { add_char((char)strtol(yytext+2, 0, 16));  }
<DQUOTES>[^\\\"\n]*  { add_str(yytext); }
<DQUOTES>\n     { line_no++; col_no = 1; } /* track line numbers, but strip new line */


    /* single quoted strings are absolute literals */
\'  {
        reset_buffer();
        BEGIN(SQUOTES);
    }

<SQUOTES>\' {
        yylval.str_literal = DUPSTR(sbuf->buf);
        BEGIN(INITIAL);
        return STRING_LITERAL;
    }

<SQUOTES>[^\\'\n]*  { add_str(yytext); }
<SQUOTES>\\.    { add_str(yytext); }
<SQUOTES>\n     { add_str(yytext); line_no++; col_no = 1; } /* don't strip new lines */

";"                 { /* swallow the ';' */ }
"{"                 { return '{'; }
"}"                 { return '}'; }
","                 { return ','; }
":"                 { return ':'; }
"="                 { return '='; }
"("                 { return '('; }
")"                 { return ')'; }
"["                 { return '['; }
"]"                 { return ']'; }
"."                 { return '.'; }
"&"                 { return '&'; }
"!"                 { return '!'; }
"~"                 { return '~'; }
"-"                 { return '-'; }
"+"                 { return '+'; }
"*"                 { return '*'; }
"/"                 { return '/'; }
"%"                 { return '%'; }
"<"                 { return '<'; }
">"                 { return '>'; }

[ \t\v\f]+          { /* whitespace separates tokens */ }
\n                  { line_no++; col_no = 1; }
.                   { /* discard bad characters */ printf("unexpected character: %c: (0x%02X)\n", yytext[0], yytext[0]); }

%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

static int check_type(void)
{
    //switch (sym_type(yytext))
    //{
    //case TYPEDEF_NAME:                /* struct name previously seen */
        //return TYPEDEF_NAME;
    //default:                          /* includes undefined */
        //return IDENTIFIER;
    //}
    if(strcmp(yytext, "lkjg") == 0 ||
            strcmp(yytext, "some_name") == 0) // contrived test
        return TYPEDEF_NAME;
    else
        return IDENTIFIER;
}

int get_line_no() { return line_no; }
int get_col_no() { return col_no; }

#pragma GCC diagnostic pop
