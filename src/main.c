/*
 * Main routine for the AST test.
 */
#include "common.h"
#include "constants.h"
#include "symbols.h"
#include "parser.h"
#include "scanner.h"

int main(int argc, char** argv) {

    if(argc < 2)
        fatal_error("file name required");

    open_file(argv[1]);
    int retv = yyparse();

    printf("errors: %d warnings: %d\n", get_num_errors(), get_num_warnings());
    return retv;
}
