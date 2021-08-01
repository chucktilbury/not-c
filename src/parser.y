/*
 * ANSI C Yacc grammar
 *
 * (This Yacc file is accompanied by a matching Lex file.)
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
 * This grammar assumes that translation phases 1..5 have already been
 * completed, including preprocessing and _Pragma processing. The Lex rule for
 * string literals will perform concatenation (translation phase 6).
 * Transliteration of universal character names (\uHHHH or \UHHHHHHHH) must
 * have been done by either the preprocessor or a replacement for the input()
 * macro used by Lex (or the YY_INPUT function used by Flex) to read
 * characters. Although comments should have been changed to space characters
 * during translation phase 3, there are Lex rules for them anyway.
 *
 * I want to keep this version as close to the current C Standard grammar as
 * possible; please let me know if you discover discrepancies.
 * (There is an FAQ for this grammar that you might want to read first.)
 *
 * jutta@pobox.com, 2012
 *
 * Last edit: 2012-12-18 DAGwyn@aol.com
 * Note: There are two shift/reduce conflicts, correctly resolved by default:
 *
 *   IF '(' expression ')' statement _ ELSE statement
 *
 * and
 *
 *   ATOMIC _ '(' type_name ')'
 *
 * where "_" has been used to flag the points of ambiguity.
 *
 * *****************************************************************************
 *
 * This grammar is modified to match the NOP grammar. The NOP language is very
 * similar to C, but there are significant differences in the way that block
 * syntax works.
 *
 * For example:
 *  - All blocks are enclosed in "{}", including "else" clauses.
 *  - Else clause accepts the same parameters are an if and if can be defined
 *    with no expression. While, if, for, and others defined with an empty or
 *    absent expression are taken to be true.
 *  - String and bool are first class types.
 *  - String formatting is a language feature, not a library routine.
 *  - Structs can have methods and struct members are local to methods defined
 *    in a struct.
 *  - Structs have constructors and destructors.
 *  - Name spaces are supported and used to "import" symbols.
 *  - Method parameter overloading is supported for methods.
 *  - Methods must be defined as struct members.
 *  - No global data definitions are allowed and all struct definitions are
 *    global.
 * This is not a comprehensive list of differences, but it's a good start on
 * one. See the tests directory for examples.
 *
 */

%{
#include <stdio.h>
#include <stdint.h>
#include "scanner.h"
#include "symbols.h"

#ifdef PARSE_TRACE
#define OSTR stderr
extern int verbosity; // defined in nop.c
extern int line_no, col_no; // defined in scanner.c, generated file
#define PTRACE(v,fmt,...) do{ \
    if(verbosity >= (v)) { \
    fprintf(OSTR, ">>>>>>>>>> PTRACE: %d: %d: %d: ", __LINE__, line_no, col_no); \
    fprintf(OSTR, fmt, ##__VA_ARGS__); \
    fprintf(OSTR,"\n");}}while(0)
#else
#define PTRACE(v,fmt,...)
#endif

%}
%debug
%defines
%locations
%define parse.error verbose

%union {
    const char* identifier;
    const char* str_literal;
    const char* type_name;
    unsigned long uint_literal;
    long int_literal;
    double float_literal;
};

%token <identifier> IDENTIFIER TYPEDEF_NAME
%token <int_literal> I_CONSTANT B_CONSTANT
%token <uint_literal> U_CONSTANT
%token <float_literal> F_CONSTANT
%token <str_literal> STRING_LITERAL

%token  LE_OP GE_OP EQ_OP NE_OP
%token  AND_OP OR_OP
%token  MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token  SUB_ASSIGN ADD_ASSIGN

%token  BOOL INT UINT FLOAT STRING NOTHING LIST DICT
%token  CONST STRUCT CTOR DTOR ENTRY

%token  CASE DEFAULT IF ELSE SWITCH WHILE DO FOR CONTINUE BREAK RETURN
%token  NAMESPACE IMPORT PUBLIC PRIVATE

%right '='
%right ADD_ASSIGN SUB_ASSIGN
%right MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%left OR_OP
%left AND_OP
%left EQ_OP NE_OP
%left '>' '<' LE_OP GE_OP
%left '+' '-'
%left '*' '/' '%'
%left NEG
%right NOT
%left ':'  // typecast

%%

translation_unit
    : translation_unit_item
    | translation_unit translation_unit_item
    ;

translation_unit_item
    : namespace
    | IMPORT formatted_string
    | ENTRY method_body
    ;

namespace
    : NAMESPACE IDENTIFIER '{' namespace_item_list '}'
    ;

namespace_item
    : struct_declaration
    | public_or_private method_definition
    | public_or_private variable_definition
    ;

namespace_item_list
    : namespace_item
    | namespace_item_list namespace_item
    ;

formatted_string
    : STRING_LITERAL
    | STRING_LITERAL '(' ')'
    | STRING_LITERAL '(' expression_list ')'
    ;

identifier_parameter_list
    : identifier_parameter
    | identifier_parameter_list identifier_parameter
    ;

identifier_parameter
    : '(' ')'
    | '(' expression_list ')'
    | '[' expression ']'
    ;

identifier
    : IDENTIFIER
    | IDENTIFIER identifier_parameter_list
    ;

compound_identifier
    : IDENTIFIER
    | compound_identifier '.' IDENTIFIER
    | error
    ;

compound_name
    : identifier
    | compound_name '.' identifier
    ;

type_name
    : BOOL
    | INT
    | UINT
    | FLOAT
    | STRING
    | NOTHING
    | TYPEDEF_NAME
    ;

list_or_dict
    : LIST
    | DICT
    ;

type_specifier
    : type_name
    | CONST type_name
    | CONST type_name list_or_dict
    | type_name list_or_dict
    ;

primary_expression
    : I_CONSTANT
    | U_CONSTANT
    | F_CONSTANT
    | B_CONSTANT
    | formatted_string
    | compound_name
    ;

expression
    : primary_expression
    | expression '+' expression
    | expression '-' expression
    | expression '*' expression
    | expression '/' expression
    | expression '%' expression
    | expression EQ_OP expression
    | expression NE_OP expression
    | expression '<' expression
    | expression '>' expression
    | expression LE_OP expression
    | expression GE_OP expression
    | expression AND_OP expression
    | expression OR_OP expression
    | '-' expression %prec NEG
    | NOT expression
    | type_specifier '(' expression ')'
    | '(' expression ')'
    | error
    ;

assignment_expression
    : compound_name ADD_ASSIGN expression
    | compound_name SUB_ASSIGN expression
    | compound_name MUL_ASSIGN expression
    | compound_name DIV_ASSIGN expression
    | compound_name MOD_ASSIGN expression
    ;

expression_list
    : expression
    | expression_list ',' expression
    ;

public_or_private
    : PUBLIC
    | PRIVATE
    |
    ;

struct_declaration
    : public_or_private STRUCT IDENTIFIER '{' struct_list '}'
    ;

struct_item
    : public_or_private variable_declaration
    | public_or_private method_declaration
    | CTOR '(' method_declaration_parameters ')'
    | CTOR '(' ')'
    | DTOR
    | struct_declaration
    | error
    ;

struct_list
    : struct_item
    | struct_list struct_item
    ;

variable_declaration
    : type_specifier IDENTIFIER
    ;

method_declaration
    : type_specifier IDENTIFIER '(' method_declaration_parameters ')'
    | type_specifier IDENTIFIER '(' ')'
    ;

method_declaration_parameters
    : variable_declaration
    | method_declaration_parameters ',' variable_declaration
    ;

method_definition
    : type_specifier compound_identifier '(' method_declaration_parameters ')' method_body
    | type_specifier compound_identifier '(' ')' method_body
    | compound_identifier '.' CTOR '(' method_declaration_parameters ')' method_body
    | compound_identifier '.' CTOR '(' ')' method_body
    | compound_identifier '.' DTOR method_body
    | error
    ;

method_body
    : '{' '}'
    | '{' method_body_list '}'
    ;

method_body_item
    : variable_definition
    | if_clause
    | while_clause
    | do_clause
    | for_clause
    | switch_clause
    | assignment
    | assignment_expression
    | compound_name
    | BREAK
    | CONTINUE
    | RETURN expression
    | method_body
    | error
    ;

method_body_list
    : method_body_item
    | method_body_list method_body_item
    ;

dict_init_element
    : IDENTIFIER '=' expression
    ;

dict_init_list
    : dict_init_element
    | dict_init_list ',' dict_init_element
    ;

list_init
    : '[' expression_list ']'
    | '[' dict_init_list ']'
    ;

variable_definition
    : variable_declaration
    | variable_declaration '=' expression
    | variable_declaration '=' list_init
    ;

if_clause
    : IF '(' expression ')' method_body
    | IF '(' expression ')' method_body else_clause_list
    | IF '(' expression ')' method_body final_else
    | IF '(' expression ')' method_body else_clause_list final_else
    ;

else_clause
    : ELSE '(' expression ')' method_body
    ;

else_clause_list
    : else_clause
    | else_clause_list else_clause
    ;

final_else
    : ELSE method_body
    | ELSE '(' ')' method_body
    ;

while_clause
    : WHILE '(' expression ')' method_body
    | WHILE '(' ')' method_body
    | WHILE method_body
    ;

do_clause
    : DO method_body WHILE '(' expression ')'
    | DO method_body WHILE '(' ')'
    ;

for_init
    : variable_definition
    | IDENTIFIER
    ;

for_clause
    : FOR '(' for_init ';' expression ';' expression ')' method_body
    | FOR '(' ';' expression ';' expression ')' method_body
    | FOR '(' for_init ';' expression ';' ')' method_body
    | FOR '(' ';' expression ';' ')' method_body
    ;

case_clause
    : CASE '(' primary_expression ')' method_body
    ;

case_clause_list
    : case_clause
    | case_clause_list case_clause
    ;

final_case_clause
    : CASE method_body
    | CASE '(' ')' method_body
    | DEFAULT method_body
    ;

switch_clause
    : SWITCH '(' expression ')' '{' case_clause_list '}'
    | SWITCH '(' expression ')' '{' case_clause_list final_case_clause '}'
    ;

assignment
    : compound_name '=' expression
    ;

%%
#include <stdio.h>

// defined in scanner.l
extern int col_no;
extern int line_no;
extern char yytext[];

void yyerror(const char *s)
{
    fflush(stdout);
    //fprintf(stderr, "*** %s\n", s);
    //fprintf(stderr, "%s\n%*s\nsyntax error: %d: %s\n", yytext, col_no, "^", line_no, s);
    fprintf(stderr, "syntax error: %d: %d: %s\n", line_no, col_no, s);
}
