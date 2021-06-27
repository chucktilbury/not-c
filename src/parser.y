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
    constant_t* value;
    compound_symbol_t* compound;
};

    // TODO:
    // 1. import feature
    // 2. external keyword to call an external library routine
    // 3. inline keyword and functionality (in scanner)
    // 4. support for non-local goto for iterators
    // 5. exceptions, strings only...
    // 6. multi-dimensional lists and dicts

%token <value> FPCONST INTCONST UINTCONST STRCONST BOOLCONST
%token <symbol> SYMBOL
%token <type> DICT LIST BOOL STRING FLOAT INT UINT NOTHING

%type <type> type_specifier
%type <value> expression constant
%type <scope> scope_specifier
%type <compound> compound_symbol

%token SWITCH CASE DEFAULT RETURN PUBLIC PRIVATE
%token IF ELSE WHILE DO BREAK CONTINUE
%token AND OR NOT EQ NEQ LTE GTE LT GT
%token ENTRY EXIT CONST STRUCT INIT DEINIT

%right '='
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
            MSG("program begin");
        } all_module {
            MSG("program end\n");
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
    | ';' // ignore extra no-op statements at module level
    ;

struct_definition:
      STRUCT SYMBOL {
            MSG("begin struct definition: %s", $2->name);
        } '{' struct_list '}' ';' {
            MSG("end of struct definition\n");
        }
    ;

struct_list:
      struct_element {}
    | struct_list struct_element {}
    ;

struct_element:
      var_declaration ';' {}
    | func_declaration ';' {}
    | ';' // allow no-op statements in a struct
    ;


scope_specifier:
      /* blank specifier */ { $$ = PRIVATE; }
    | PUBLIC {}
    | PRIVATE {}
    ;

var_declaration:
      scope_specifier CONST type_specifier SYMBOL {
            MSG("var declaration: %s CONST %s %s",TOK_TOSTR($1),TOK_TOSTR($3),$4->name);
        }
    | scope_specifier type_specifier SYMBOL {
            MSG("var declaration: %s %s %s",TOK_TOSTR($1),TOK_TOSTR($2),$3->name);
        }
    | scope_specifier CONST SYMBOL SYMBOL {
            MSG("var declaration: %s CONST %s %s",TOK_TOSTR($1),$3->name,$4->name);
        }
    | scope_specifier SYMBOL SYMBOL {
            MSG("var declaration: %s %s %s",TOK_TOSTR($1),$2->name,$3->name);
        }
    | scope_specifier type_specifier LIST SYMBOL {
            MSG("var declaration: %s %s LIST %s",TOK_TOSTR($1),TOK_TOSTR($2),$4->name);
        }
    | scope_specifier SYMBOL LIST SYMBOL {
            MSG("var declaration: %s %s LIST %s",TOK_TOSTR($1),$2->name,$4->name);
        }
    | scope_specifier type_specifier DICT SYMBOL {
            MSG("var declaration: %s %s DICT %s",TOK_TOSTR($1),TOK_TOSTR($2),$4->name);
        }
    | scope_specifier SYMBOL DICT SYMBOL {
            MSG("var declaration: %s %s DICT %s",TOK_TOSTR($1),$2->name,$4->name);
        }
    ;

func_declaration:
      scope_specifier type_specifier SYMBOL {
            MSG("begin func decl: %s %s %s",TOK_TOSTR($1),TOK_TOSTR($2),$3->name);
        } '(' func_def_parms ')' {
            MSG("end func declaration\n");
        }
    | scope_specifier type_specifier LIST SYMBOL {
            MSG("begin func decl: %s %s LIST %s",TOK_TOSTR($1),TOK_TOSTR($2),$4->name);
        } '(' func_def_parms ')' {
            MSG("end func declaration\n");
        }
    | scope_specifier type_specifier DICT SYMBOL {
            MSG("begin func decl: %s %s DICT %s",TOK_TOSTR($1),TOK_TOSTR($2),$4->name);
        }'(' func_def_parms ')' {
            MSG("end func declaration\n");
        }
    | scope_specifier SYMBOL SYMBOL {
            MSG("begin func decl: %s %s %s",TOK_TOSTR($1),$2->name,$3->name);
        } '(' func_def_parms ')' {
            MSG("end func declaration\n");
        }
    | scope_specifier SYMBOL LIST SYMBOL {
            MSG("begin func decl: %s %s LIST %s", TOK_TOSTR($1),$2->name,$4->name);
        } '(' func_def_parms ')' {
            MSG("end func declaration\n");
        }
    | scope_specifier SYMBOL DICT SYMBOL {
            MSG("begin func decl: %s %s DICT %s", TOK_TOSTR($1),$2->name,$4->name);
        }'(' func_def_parms ')' {
            MSG("end func declaration\n");
        }
    | INIT {
            MSG("begin init func def");
        } '(' func_def_parms ')' {
            MSG("end init func def\n");
        }
    | DEINIT '(' ')' {
            MSG("deinit func def");
        }
    | DEINIT {
            MSG("deinit func def");
        }
    | error
    ;

compound_symbol:
      SYMBOL {
            MSG("begin compound symbol %s", $1->name);
            $$ = create_compound($1->name);
        }
    | compound_symbol '.' SYMBOL {
            MSG("add to compound symbol %s", $3->name);
            add_compound($1, $3->name);
        }
    ;

func_definition:
      type_specifier compound_symbol {
            MSG("begin func def: %s %s", TOK_TOSTR($1), $2->name);
        } '(' func_def_parms ')' {
            MSG("begin func body");
        } func_body {
            MSG("end func body\n");
        }
    | ENTRY {
            MSG("begin entry body def");
        } func_body {
            MSG("end entry body def");
        }
    | error
    ;

func_def_parms_items:
      /* empty */ { MSG("empty function decl list"); }
    | type_specifier SYMBOL {
            MSG("func parameter def: %s %s", TOK_TOSTR($1), $2->name);
        }
    | type_specifier LIST SYMBOL {
            MSG("func parameter def: %s LIST %s", TOK_TOSTR($1), $3->name);
        }
    | type_specifier DICT SYMBOL {
            MSG("func parameter def: %s DICT %s", TOK_TOSTR($1), $3->name);
        }
    ;

func_def_parms:
      func_def_parms_items {}
    | func_def_parms ',' func_def_parms_items {}
    ;

func_body:
      '{' {
            MSG("\nopen function context");
        } func_body_list '}' {
            MSG("\nclose function context");
        }
    | '{' '}' {
            MSG("empty function body");
        }
    ;

func_body_list:
      func_body_element {}
    | func_body_list func_body_element {}
    ;

list_initializer:
      '[' ']' {
            MSG("empty list initializer");
        }
    | '[' list_initializer_list ']' {
            MSG("list initializer with data");
        }
    | compound_symbol {
            MSG("list initializer with compound symbol: %s",$1->name);
        }
    ;

list_initializer_list:
      assignment_item {
            MSG("begin list assignment list");
        }
    | list_initializer_list ',' assignment_item {
            MSG("add list assignment list");
        }
    //| compound_symbol {}
    ;

dict_initializer_item:
      SYMBOL '=' expression {
            MSG("dict initializer: %s expression", $1->name);
        }
    | SYMBOL '=' formatted_string {
            MSG("dict initializer: %s formatted string", $1->name);
        }
    //| compound_symbol {}
    ;

dict_initializer_list:
      dict_initializer_item {
            MSG("begin dict assignment list");
        }
    | dict_initializer_list ',' dict_initializer_item {
            MSG("add dict assignment list");
        }
    ;

dict_initializer:
      '[' ']' {
            MSG("empty dict initializer");
        }
    | '[' dict_initializer_list ']' {
            MSG("dict initalizer with data");
        }
    | compound_symbol {
            MSG("dict initialzer with compound symbol: %s", $1->name);
        }
    ;

assignment_item:
      expression {
            MSG("expression assignment item");
        }
    | formatted_string {
            MSG("formatted string assignment item");
        }
    ;

var_definition:
      SYMBOL SYMBOL {
            MSG("var definition: %s %s", $1->name, $2->name);
        }
    | type_specifier SYMBOL {
            MSG("var definition: %s %s", TOK_TOSTR($1), $2->name);
        }
    ;

list_definition:
      type_specifier LIST SYMBOL {
            MSG("var definition: %s LIST %s", TOK_TOSTR($1), $3->name);
        }
    | SYMBOL LIST SYMBOL {
            MSG("var definition: %s LIST %s", $1->name, $3->name);
        }
    ;

dict_definition:
      type_specifier DICT SYMBOL {
            MSG("var definition: %s DICT %s", TOK_TOSTR($1), $3->name);
        }
    | SYMBOL DICT SYMBOL {
            MSG("var definition: %s DICT %s", $1->name, $3->name);
        }
    ;

func_body_element:
      var_definition ';' {}
    | var_definition '=' assignment_item ';' {}
    | compound_symbol '=' assignment_item ';' {}
    | list_definition '=' list_initializer ';' {}
    | list_definition ';' {}
    | dict_definition '=' dict_initializer ';' {}
    | dict_definition ';' {}
    | func_call ';' {}
    | while_statement {}
    | do_statement {}
    | if_statement {}
    | switch_statement {}
    | func_body {}
    | RETURN expression ';' {
            MSG("return expression");
        }
    | EXIT expression ';' {
            MSG("exit expression");
        }
    | ';' // allow extra no-op statements in a func
    ;

loop_body:
      '{' loop_body_list '}' {}
    ;

loop_body_element:
      func_body_element {}
    | BREAK ';' {}
    | CONTINUE ';' {}
    ;

loop_body_list:
      loop_body_element {}
    | loop_body_list loop_body_element {}
    ;

comparison_expr:
      '(' {
            MSG("begin comparison expression");
        } expression ')' {
            MSG("end comparison expression");
        }
    | '(' ')' {
            MSG("blank comparison expression");
        }
    ;

while_statement:
      WHILE comparison_expr {
            MSG("begin while loop body\nopen local context");
        } loop_body {
            MSG("end while loop body\nclose local context");
        }
    ;

do_statement:
      DO {
            MSG("begin do loop body\nopen local context");
        } func_body {
            MSG("end do loop body\nclose local context");
        } WHILE comparison_expr ';'
    ;

if_introduction:
      IF {
            MSG("begin if clause");
        } comparison_expr {
            MSG("begin if func body\nopen local context");
        }
    ;

if_statement:
      if_introduction func_body {
            MSG("end if func body (no else)\nclose local context");
        }
    | if_introduction func_body {
            MSG("end if func body (with else)\nclose local context");
        } else_clause_list {
            MSG("end if/else clause\nclose local context");
        }
    ;

else_clause:
      ELSE {
            MSG("begin else clause (with expression)");
        } comparison_expr {
            MSG("begin else func body\nopen local context");
        } func_body {
            MSG("end else func body\nclose local context");
        }
    | ELSE {
            MSG("begin else clause (no expression)\nopen local context");
        } func_body {
            MSG("end else func body\nclose local context");
        }
    ;

else_clause_list:
      else_clause {}
    | else_clause_list else_clause {}
    ;

switch_statement:
      SWITCH {
            MSG("begin switch/case statement");
        } comparison_expr '{' case_clause '}' {
            MSG("end switch/case statement");
        }
    ;

default_clause:
      DEFAULT {
            MSG("begin default clause");
        } func_body {
            MSG("end default clause");
        }
    ;

case_base:
      CASE '(' constant ')' {
            MSG("begin case clause/case constant");
        } func_body {
            MSG("end case clause");
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
      compound_symbol {
            MSG("func call to %s", $1->name);
        } '(' fcall_list ')' {
            MSG("end func call");
        }
    ;

fcall_list:
      /* can be blank */ {
            MSG("blank function call parameters");
        }
    | fcall_list_element {}
    | fcall_list ',' fcall_list_element {}
    ;

fcall_list_element:
      expression {
            MSG("func call expression parameter");
        }
    | formatted_string {
            MSG("func call formatted string parameter");
        }
    ;

formatted_string:
      STRCONST {}
    | STRCONST '(' expression_list ')' {}
    ;

type_specifier:
      STRING {  }
    | FLOAT  {  }
    | INT    {  }
    | UINT   {  }
    | BOOL   {  }
    | NOTHING { MSG("NOTHING type specifier"); }
    ;

list_reference:
      compound_symbol '[' expression ']' {}
    ;

dict_reference:
      compound_symbol '[' formatted_string ']' {}
    ;

constant:
      FPCONST {  }
    | INTCONST {  }
    | UINTCONST {  }
    | BOOLCONST { }
    | NOTHING {}
    ;

expression_factor:
      constant { }
    | compound_symbol { }
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
    fflush(stdout);
    fprintf(stdout, "%s: line %d: at %d: %s\n", get_file_name(), get_line_number(), get_col_number(), s);
    inc_error_count();
}
