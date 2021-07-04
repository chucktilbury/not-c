/*
 * This is the complete grammar for the NOP programming language.
 */

%debug
%defines
%locations

%{

#include "common.h"
#include "scanner.h"
#include "symbols.h"
#include "constants.h"
#include "ast.h"

#define TOKSTR get_tok_str()

%}
%define parse.error verbose
%locations

%union {
    int type;
    int scope;
    symbol_t* symbol;
    constant_t* constant;
    compound_name_t* compound;
};

    // TODO:
    //  function overloads (name mangling)
    //  import feature
    //  "external" keyword to call an external library routine
    //  inline keyword and functionality (in scanner)
    //  support for non-local goto for iterators
    //  exceptions, strings only...
    //  multi-dimensional lists and dicts
    //  lists and dicts hold any type, incl lists and dicts


%token <constant> FPCONST INTCONST UINTCONST STRCONST BOOLCONST
%token <symbol> SYMBOL
%token <type> DICT LIST BOOL STRING FLOAT INT UINT NOTHING

%type <type> type_specifier compound_type
%type <constant> expression constant
%type <scope> scope_specifier
%type <compound> compound_name init_preamble

%token SWITCH CASE DEFAULT RETURN PUBLIC PRIVATE
%token IF ELSE WHILE DO BREAK CONTINUE NAMESPACE
%token AND OR NOT EQ NEQ LTE GTE LT GT
%token ENTRY EXIT CONST STRUCT INIT DEINIT
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN

    // not returned by the scanner
%token USR_TYPE

%right '='
%right ADD_ASSIGN SUB_ASSIGN
%right MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%left AND OR
%left EQ NEQ
%left LT GT LTE GTE
%right ':'
%left '+' '-'
%left '*' '/' '%'
%left NEG
%right NOT

%%
    /*
        Module rules.
     */
program:
        {
            PARSER_TRACE("program begin");
        } all_module {
            PARSER_TRACE("program end\n");
        }
    ;

all_module: module_list
    ;

module_list:
      module_element {}
    | module_list module_element {}
    ;

module_element:
      struct_definition {}
    | func_definition {}
    | namespace_definition {}
    | ';' // ignore extra no-op statements at module level
    ;

namespace_definition:
      NAMESPACE SYMBOL {
            PARSER_TRACE("begin namespace definition: %s", $2->name);
        } '{' module_list '}' {
            PARSER_TRACE("end namespace definition");
        }
    ;

struct_definition:
      STRUCT SYMBOL {
            PARSER_TRACE("begin struct definition: %s", $2->name);
        } '{' struct_list '}' {
            PARSER_TRACE("end of struct definition\n");
        }
    ;

struct_list:
      struct_element {}
    | struct_list struct_element {}
    ;

struct_element:
      var_declaration {}
    | func_declaration {}
    | ';' // allow no-op statements in a struct
    ;


scope_specifier:
      /* blank specifier */ { $$ = PRIVATE; }
    | PUBLIC {}
    | PRIVATE {}
    ;

var_declaration:
      scope_specifier CONST compound_type SYMBOL {
            PARSER_TRACE("var declaration: %s CONST %s %s",TOK_TOSTR($1),TOK_TOSTR($3),$4->name);
        }
    | scope_specifier compound_type SYMBOL {
            PARSER_TRACE("var declaration: %s %s %s",TOK_TOSTR($1),TOK_TOSTR($2),$3->name);
        }
    | scope_specifier compound_type LIST SYMBOL {
            PARSER_TRACE("var declaration: %s %s LIST %s",TOK_TOSTR($1),TOK_TOSTR($2),$4->name);
        }
    | scope_specifier compound_type DICT SYMBOL {
            PARSER_TRACE("var declaration: %s %s DICT %s",TOK_TOSTR($1),TOK_TOSTR($2),$4->name);
        }
    ;

init_preamble:
      compound_name '.' {
            PARSER_TRACE("(de)init for class: %s", $1->name);
        }
    ;

func_declaration:
      scope_specifier compound_type SYMBOL {
            PARSER_TRACE("begin func decl: %s %s %s",TOK_TOSTR($1),TOK_TOSTR($2),$3->name);
        } '(' func_def_parms ')' {
            PARSER_TRACE("end func declaration\n");
        }
    | scope_specifier compound_type LIST SYMBOL {
            PARSER_TRACE("begin func decl: %s %s LIST %s",TOK_TOSTR($1),TOK_TOSTR($2),$4->name);
        } '(' func_def_parms ')' {
            PARSER_TRACE("end func declaration\n");
        }
    | scope_specifier compound_type DICT SYMBOL {
            PARSER_TRACE("begin func decl: %s %s DICT %s",TOK_TOSTR($1),TOK_TOSTR($2),$4->name);
        }'(' func_def_parms ')' {
            PARSER_TRACE("end func declaration\n");
        }
    | INIT {
            PARSER_TRACE("begin init func def");
        } '(' func_def_parms ')' {
            PARSER_TRACE("end init func def\n");
        }
    | DEINIT '(' ')' {
            PARSER_TRACE("deinit func def");
        }
    | DEINIT {
            PARSER_TRACE("deinit func def");
        }
    | error
    ;

compound_name:
      SYMBOL {
            PARSER_TRACE("begin compound symbol %s", $1->name);
            $$ = create_compound($1->name);
        }
    | compound_name '.' SYMBOL {
            PARSER_TRACE("add to compound symbol %s", $3->name);
            add_compound($1, $3->name);
        }
    ;

func_definition:
      compound_type compound_name {
            PARSER_TRACE("begin func def: %s %s", TOK_TOSTR($1), $2->name);
        } '(' func_def_parms ')' {
            PARSER_TRACE("begin func body");
        } func_body {
            PARSER_TRACE("end func body\n");
        }
    | ENTRY {
            PARSER_TRACE("begin entry body def");
        } func_body {
            PARSER_TRACE("end entry body def");
        }
    | init_preamble INIT {
            PARSER_TRACE("begin init definition for class: %s", $1->name);
        } '(' func_def_parms ')' {
            PARSER_TRACE("begin func body");
        } func_body {
            PARSER_TRACE("end func body\n");
        }
    | init_preamble DEINIT {
            PARSER_TRACE("begin deinit definition for class: %s", $1->name);
            PARSER_TRACE("begin func body");
        } func_body {
            PARSER_TRACE("end func body\n");
        }
    | init_preamble DEINIT {
        } '(' ')' {
            PARSER_TRACE("begin deinit definition for class: %s", $1->name);
            PARSER_TRACE("begin func body");
        } func_body {
            PARSER_TRACE("end func body\n");
        }
    | error
    ;

func_def_parms_items:
      /* empty */ { PARSER_TRACE("empty function decl list"); }
    | compound_type SYMBOL {
            PARSER_TRACE("func parameter def: %s %s", TOK_TOSTR($1), $2->name);
        }
    | compound_type LIST SYMBOL {
            PARSER_TRACE("func parameter def: %s LIST %s", TOK_TOSTR($1), $3->name);
        }
    | compound_type DICT SYMBOL {
            PARSER_TRACE("func parameter def: %s DICT %s", TOK_TOSTR($1), $3->name);
        }
    ;

func_def_parms:
      func_def_parms_items {}
    | func_def_parms ',' func_def_parms_items {}
    ;

func_body:
      '{' {
            PARSER_TRACE("\nopen function context");
        } func_body_list '}' {
            PARSER_TRACE("\nclose function context");
        }
    | '{' '}' {
            PARSER_TRACE("empty function body");
        }
    ;

func_body_list:
      func_body_element {}
    | func_body_list func_body_element {}
    ;

list_initializer:
      '[' ']' {
            PARSER_TRACE("empty list initializer");
        }
    | '[' list_initializer_list ']' {
            PARSER_TRACE("list initializer with data");
        }
    | compound_name {
            PARSER_TRACE("list initializer with compound symbol: %s",$1->name);
        }
    ;

list_initializer_list:
      assignment_item {
            PARSER_TRACE("begin list assignment list");
        }
    | list_initializer_list ',' assignment_item {
            PARSER_TRACE("add list assignment list");
        }
    ;

dict_initializer_item:
      SYMBOL '=' expression {
            PARSER_TRACE("dict initializer: %s expression", $1->name);
        }
    | SYMBOL '=' formatted_string {
            PARSER_TRACE("dict initializer: %s formatted string", $1->name);
        }
    ;

dict_initializer_list:
      dict_initializer_item {
            PARSER_TRACE("begin dict assignment list");
        }
    | dict_initializer_list ',' dict_initializer_item {
            PARSER_TRACE("add dict assignment list");
        }
    ;

dict_initializer:
      '[' ']' {
            PARSER_TRACE("empty dict initializer");
        }
    | '[' dict_initializer_list ']' {
            PARSER_TRACE("dict initalizer with data");
        }
    | compound_name {
            PARSER_TRACE("dict initialzer with compound symbol: %s", $1->name);
        }
    ;

assignment_item:
      expression {
            PARSER_TRACE("expression assignment item");
        }
    | formatted_string {
            PARSER_TRACE("formatted string assignment item");
        }
    ;

var_definition:
      compound_type SYMBOL {
            PARSER_TRACE("var definition: %s %s", TOK_TOSTR($1), $2->name);
        }
    ;

list_definition:
      compound_type LIST SYMBOL {
            PARSER_TRACE("var definition: %s LIST %s", TOK_TOSTR($1), $3->name);
        }
    ;

dict_definition:
      compound_type DICT SYMBOL {
            PARSER_TRACE("var definition: %s DICT %s", TOK_TOSTR($1), $3->name);
        }
    ;

func_body_element:
      var_definition {}
    | var_definition '=' assignment_item {}
    | compound_name '=' assignment_item {}
    | list_definition '=' list_initializer {}
    | list_definition {}
    | dict_definition '=' dict_initializer {}
    | dict_definition {}
    | list_reference '=' assignment_item {}
    | dict_reference '=' assignment_item {}
    | func_call {}
    | while_statement {}
    | do_statement {}
    | if_statement {}
    | switch_statement {}
    | func_body {}
    | RETURN expression {
            PARSER_TRACE("return expression");
        }
    | EXIT expression {
            PARSER_TRACE("exit expression");
        }
    | BREAK {}
    | CONTINUE {}
    | ';' // allow extra no-op statements in a func
    ;

comparison_expr:
      '(' {
            PARSER_TRACE("begin comparison expression");
        } expression ')' {
            PARSER_TRACE("end comparison expression");
        }
    | '(' ')' {
            PARSER_TRACE("blank comparison expression");
        }
    ;

while_statement:
      WHILE comparison_expr {
            PARSER_TRACE("begin while loop body\nopen local context");
        } func_body {
            PARSER_TRACE("end while loop body\nclose local context");
        }
    ;

do_statement:
      DO {
            PARSER_TRACE("begin do loop body\nopen local context");
        } func_body {
            PARSER_TRACE("end do loop body\nclose local context");
        } WHILE comparison_expr
    ;

if_introduction:
      IF {
            PARSER_TRACE("begin if clause");
        } comparison_expr {
            PARSER_TRACE("begin if func body\nopen local context");
        }
    ;

if_statement:
      if_introduction func_body {
            PARSER_TRACE("end if func body (no else)\nclose local context");
        }
    | if_introduction func_body {
            PARSER_TRACE("end if func body (with else)\nclose local context");
        } else_clause_list {
            PARSER_TRACE("end if/else clause\nclose local context");
        }
    ;

else_clause:
      ELSE {
            PARSER_TRACE("begin else clause (with expression)");
        } comparison_expr {
            PARSER_TRACE("begin else func body\nopen local context");
        } func_body {
            PARSER_TRACE("end else func body\nclose local context");
        }
    | ELSE {
            PARSER_TRACE("begin else clause (no expression)\nopen local context");
        } func_body {
            PARSER_TRACE("end else func body\nclose local context");
        }
    ;

else_clause_list:
      else_clause {}
    | else_clause_list else_clause {}
    ;

switch_statement:
      SWITCH {
            PARSER_TRACE("begin switch/case statement");
        } comparison_expr '{' case_clause '}' {
            PARSER_TRACE("end switch/case statement");
        }
    ;

default_clause:
      DEFAULT {
            PARSER_TRACE("begin default clause");
        } func_body {
            PARSER_TRACE("end default clause");
        }
    ;

case_base:
      CASE '(' constant ')' {
            PARSER_TRACE("begin case clause/case constant");
        } func_body {
            PARSER_TRACE("end case clause");
        }
    ;

case_clause:
      case_clause_list {}
    | case_clause_list default_clause {}
    ;

case_clause_list:
      case_base {}
    | case_clause_list case_base {}
    ;

func_call:
      compound_name {
            PARSER_TRACE("func call to %s", $1->name);
        } '(' fcall_list ')' {
            PARSER_TRACE("end func call");
        }
    ;

fcall_list:
      /* can be blank */ {
            PARSER_TRACE("blank function call parameters");
        }
    | fcall_list_element {}
    | fcall_list ',' fcall_list_element {}
    ;

fcall_list_element:
      expression {
            PARSER_TRACE("func call expression parameter");
        }
    | formatted_string {
            PARSER_TRACE("func call formatted string parameter");
        }
    ;

formatted_string:
      STRCONST {}
    | STRCONST '(' expression_list ')' {}
    ;

compound_type:
      type_specifier { $$ = $1; }
    | compound_name { $$ = USR_TYPE; }
    ;

type_specifier:
      STRING {  }
    | FLOAT  {  }
    | INT    {  }
    | UINT   {  }
    | BOOL   {  }
    | NOTHING { PARSER_TRACE("NOTHING type specifier"); }
    ;

list_reference:
      compound_name '[' expression ']' {}
    ;

dict_reference:
      compound_name '[' formatted_string ']' {}
    ;

constant:
      FPCONST {  }
    | INTCONST {  }
    | UINTCONST {  }
    | BOOLCONST { }
    | NOTHING { PARSER_TRACE("NOTHING CONSTANT"); }
    ;

expression_factor:
      constant { }
    | compound_name { }
    | list_reference {}
    | dict_reference {}
    | func_call {}
    ;

expression:
      expression_factor {}
    | expression '+' expression {  }
    | expression '-' expression {  }
    | expression '*' expression {  }
    | expression '/' expression {  }
    | expression '%' expression {  }
    | expression EQ expression {  }
    | expression NEQ expression {  }
    | expression LT expression {  }
    | expression GT expression {  }
    | expression LTE expression {  }
    | expression GTE expression {  }
    | expression AND expression {  }
    | expression OR expression {  }
    | '-' expression %prec NEG  {  }
    | NOT expression {  }
    | type_specifier ':' SYMBOL  {  }
    | SYMBOL ADD_ASSIGN expression {}
    | SYMBOL SUB_ASSIGN expression {}
    | SYMBOL MUL_ASSIGN expression {}
    | SYMBOL DIV_ASSIGN expression {}
    | SYMBOL MOD_ASSIGN expression {}
    | '(' expression ')' {}
    ;

expression_list:
      expression {}
    | expression_list ',' expression {}
    ;

%%

#include <stdio.h>

extern char yytext[];

void yyerror(const char* s)
{
    fflush(stderr);
    fprintf(stderr, "Syntax Error: %s: line %d: at %d: %s\n", get_file_name(), get_line_number(), get_col_number(), s);
    inc_error_count();
}
