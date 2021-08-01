/*
 * This is the main function for the parser. It is intended to be used as a
 * platform for testing the parser.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "parser.h"
#include "scanner.h"
#include "errors.h"

extern FILE* yyin; // defined in scanner.c, generated file
int verbosity = 0;

int main(int argc, char** argv) {

    if(argc < 2) {
        fprintf(stderr, "%s inputfile [verbosity]\n", argv[0]);
        return 1;
    }
    else if(argc >= 3) {
        verbosity = (int)strtol(argv[2], NULL, 10);
        if(verbosity >= 5)
            yydebug = 1;
    }
    else {
        yydebug = 0;
    }

    init_scanner(argv[1]);
    yyparse();
    destroy_scanner();

    return 0;
}
