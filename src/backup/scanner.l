
%{
//#undef //_DEBUGGING
//#undef //_TRACE
//#define //_TRACE(...)

#include "common.h"
#include "constants.h"
#include "symbols.h"
#include "parser.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wimplicit-function-declaration"

// maximum depth of imports prevents crashing from circular imports.
//static int import_depth = 0;
//#define MAX_IMPORTS 15

// string buffer to get token from
static char strbuf[1024*64];

typedef struct _file_name_stack {
    int line_no;
    int col_no;
    char *name;
    struct _file_name_stack *next;
} _file_name_stack;

void count(void);
static char buffer[1024*64];
static int bidx = 0;
static _file_name_stack *name_stack;
int num_errors = 0; // global updated by parser

// these funcs support the string scanner
static void __append_char(char ch) {
    if((sizeof(buffer)-1) > (size_t)bidx) {
        buffer[bidx] = ch;
        bidx++;
    }
    else {
        fatal_error("buffer overrun");
        //fprintf(stderr, "scanner buffer overrun");
        exit(1);
    }
}

static void __append_str(char *str) {
    if((sizeof(buffer)-1) > (strlen(buffer) + strlen(str))) {
        strcat(buffer, str);
        bidx = strlen(buffer);
    }
    else {
        fatal_error("buffer overrun");
        //fprintf(stderr, "scanner buffer overrun");
        exit(1);
    }
}

static void update_loc(void){

    if(NULL != name_stack) {
        yylloc.first_line   = name_stack->line_no;
        yylloc.first_column = name_stack->col_no;
    }
    else
        return;

    for(char *s = yytext; *s != '\0'; s++) {
        name_stack->col_no++;
    }

    yylloc.last_line   = name_stack->line_no;
    yylloc.last_column = name_stack->col_no-1;
}

#define YY_USER_ACTION update_loc();
//#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
%}

/* state definitions */
%x SQUOTES
%x DQUOTES
%x COMMENT
%option noinput nounput
%option yylineno
%option noyywrap
%%

    /* overhead */
\n              { name_stack->line_no++; name_stack->col_no=1; } // yylineno++; }
[ \t\r]         {}

    /* keywords */
"string"        { yylval.type = STRING; return STRING; }
"float"         { yylval.type = FLOAT; return FLOAT; }
"int"           { yylval.type = INT; return INT; }
"uint"          { yylval.type = UINT; return UINT; }
"dict"          { yylval.type = DICT; return DICT; }
"list"          { yylval.type = LIST; return LIST; }
"bool"          { yylval.type = BOOL; return BOOL; }
"nothing"       { yylval.type = NOTHING; return NOTHING; }
"true"          { yylval.constant = make_bool_const(true); return BOOLCONST; }
"false"         { yylval.constant = make_bool_const(false); return BOOLCONST; }
"public"        { yylval.scope = PUBLIC; return PUBLIC; }
"private"       { yylval.scope = PRIVATE; return PRIVATE; }

"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"do"            { return DO; }
"switch"        { return SWITCH; }
"case"          { return CASE; }
"break"         { return BREAK; }
"continue"      { return CONTINUE; }
"default"       { return DEFAULT; }
"entry"         { return ENTRY; }
"exit"          { return EXIT; }
"init"          { return INIT; }
"deinit"        { return DEINIT; }
"return"        { return RETURN; }
"const"         { return CONST; }
"struct"        { return STRUCT; }
"namespace"     { return NAMESPACE; }

    /* boolean operator tokens composed of special characters */
"and"           { return AND; }
"or"            { return OR; }

"not"           { return NOT; }
"!"             { return NOT; }
"equ"           { return EQ; }
"=="            { return EQ; }
"neq"           { return NEQ; }
"!="            { return NEQ; }
"leq"           { return LTE; }
"<="            { return LTE; }
"geq"           { return GTE; }
">="            { return GTE; }
"lt"            { return LT; }
"<"             { return LT; }
"gt"            { return GT; }
">"             { return GT; }
"+="            { return ADD_ASSIGN; }
"-="            { return SUB_ASSIGN; }
"*="            { return MUL_ASSIGN; }
"/="            { return DIV_ASSIGN; }
"%="            { return MOD_ASSIGN; }

        /* arithmetic operators */
"-"             { return '-'; }
"+"             { return '+'; }
"="             { return '='; }
"/"             { return '/'; }
"*"             { return '*'; }
"%"             { return '%'; }

        /* Other operators */
","             { return ','; }
";"             { /* ignore all */ }
":"             { return ':'; }
"["             { return '['; }
"]"             { return ']'; }
"{"             { return '{'; }
"}"             { return '}'; }
"("             { return '('; }
")"             { return ')'; }
"."             { return '.'; }

    /* constructed tokens */

    /* A simple symbol */
[a-zA-Z_][a-zA-Z_0-9]* {
        yylval.symbol = create_symbol(yytext);
        //printf("SYMBOL: %s\n", yytext);
        return SYMBOL;
    }

    /* recognize and ignore comments */
[/][*]+ { BEGIN(COMMENT); }
<COMMENT>[*]+[/] { BEGIN(INITIAL); }
<COMMENT>\n { name_stack->line_no++; yylineno++; }
<COMMENT>.  {}  /* eat everything in between */

    /* eat up until the newline */
[/][/].* { ;
    }

[0-9]+ {
        //yylval.literal.intval = strtol(yytext, NULL, 10);
        yylval.constant = make_inum_const(strtol(yytext, NULL, 10));
        return INTCONST;
    }

    /* recognize a float */
([0-9]*\.)?[0-9]+([Ee][-+]?[0-9]+)? {
        //yylval.literal.fpval = strtod(yytext, NULL);
        yylval.constant = make_fnum_const(strtod(yytext, NULL));
        return FPCONST;
    }

0[Xx][0-9a-fA-F]+ {
        //yylval.literal.uintval = strtol(yytext, NULL, 16);
        yylval.constant = make_unum_const(strtol(yytext, NULL, 16));
        return UINTCONST;
    }

    /* double quoted strings have escapes managed */
\"  {
        bidx = 0;
        memset(buffer, 0, sizeof(buffer));
        BEGIN(DQUOTES);
    }

<DQUOTES>\" {
        //yylval.literal.str = STRDUP(buffer);
        yylval.constant = make_strg_const(buffer);
        BEGIN(INITIAL);
        return STRCONST;
    }

    /* the short rule matches before the long one does */
<DQUOTES>\\n    { __append_char('\n'); }
<DQUOTES>\\r    { __append_char('\r'); }
<DQUOTES>\\e    { __append_char('\x1b'); }
<DQUOTES>\\t    { __append_char('\t'); }
<DQUOTES>\\b    { __append_char('\b'); }
<DQUOTES>\\f    { __append_char('\f'); }
<DQUOTES>\\v    { __append_char('\v'); }
<DQUOTES>\\\\   { __append_char('\\'); }
<DQUOTES>\\\"   { __append_char('\"'); }
<DQUOTES>\\\'   { __append_char('\''); }
<DQUOTES>\\\?   { __append_char('\?'); }
<DQUOTES>\\.    { __append_char(yytext[1]); }
<DQUOTES>\\[0-7]{1,3} { __append_char((char)strtol(yytext+1, 0, 8));  }
<DQUOTES>\\[xX][0-9a-fA-F]{1,3} { __append_char((char)strtol(yytext+2, 0, 16));  }
<DQUOTES>[^\\\"\n]*  { __append_str(yytext); }
<DQUOTES>\n     { name_stack->line_no++; yylineno++; } /* track line numbers, but strip new line */


    /* single quoted strings are absolute literals */
\'  {
        bidx = 0;
        memset(buffer, 0, sizeof(buffer));
        BEGIN(SQUOTES);
    }

<SQUOTES>\' {
        //yylval.literal.str = STRDUP(buffer);
        yylval.constant = make_strg_const(buffer);
        BEGIN(INITIAL);
        return STRCONST;
    }

<SQUOTES>[^\\'\n]*  { __append_str(yytext); }
<SQUOTES>\\.    { __append_str(yytext); }
<SQUOTES>\n     { __append_str(yytext); name_stack->line_no++; yylineno++; } /* don't strip new lines */

.               { warning("unrecognized character: %c (0x%02X)", yytext[0], yytext[0]);}

<<EOF>> {

        _file_name_stack *name = name_stack->next;
        FREE(name_stack->name);
        FREE(name_stack);
        name_stack = name;

        memset(strbuf, 0, sizeof(strbuf));
        yypop_buffer_state();
        if(!YY_CURRENT_BUFFER) {
            yyterminate();
        }
        //import_depth--;

        //return EOF;
    }

%%

int open_file(const char *fname) {

    _file_name_stack *name;

    name = CALLOC(1, sizeof(_file_name_stack));
    name->name = STRDUP(fname);
    name->next = name_stack;
    name->line_no = 1;
    name->col_no = 1;
    name_stack = name;

    yyin = fopen(fname, "r");
    if(NULL == yyin) {
        fatal_error("cannot open the input file: \"%s\": %s", fname, strerror(errno));
        return 1;
    }

    yypush_buffer_state(yy_create_buffer(yyin, YY_BUF_SIZE));
    return 0;
}

// Tracking and global interface
char *get_file_name(void) {
    if(NULL != name_stack)
        return name_stack->name;
    else
        return "no name";
}

int get_line_number(void) {
    if(NULL != name_stack)
        return name_stack->line_no;
    else
        return -1;
}

int get_col_number(void) {
    if(NULL != name_stack)
        return name_stack->col_no;
    else
        return -1;
}

const char *get_tok_str(void) {
    return strbuf;
}

#pragma GCC diagnostic pop

#if 0
size_t yyread(FILE* file, char* buf, size_t max, Interpreter* interpreter)
{
    // Interactive input is signaled by yyin==NULL.
    if (file == NULL) {
        if (interpreter->completeLine) {
            if (interpreter->atStart && interpreter->echo != NULL) {
                fputs(interpreter->echo, stdout);
                fputs("\n", stdout);
                free(interpreter->echo);
                interpreter->echo = NULL;
            }
            fputs(interpreter->atStart ? interpreter->ps1 : interpreter->ps2, stdout);
            fflush(stdout);
        }

        char ibuf[max+1]; // fgets needs an extra byte for \0
        size_t len = 0;
        if (fgets(ibuf, max+1, stdin)) {
            len = strlen(ibuf);
            memcpy(buf, ibuf, len);
            // Show the prompt next time if we've read a full line.
            interpreter->completeLine = (ibuf[len-1] == '\n');
        }
        else if (ferror(stdin)) {
            // TODO: propagate error value
        }
        return len;
    }
    else { // not interactive
        size_t len = fread(buf, 1, max, file);
        if (len == 0 && ferror(file)) {
            // TODO: propagate error value
        }
        return len;
    }
}
#endif
