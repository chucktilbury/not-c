#ifndef __SCANNER_H__
#define __SCANNER_H__

extern int yylex(void);
extern int yyparse(void);
extern void yyerror(const char *s);
extern void* yy_scan_string(const char* str);
extern void yy_delete_buffer(const char* str);

int get_line_no();
int get_col_no();

void init_scanner(const char*);
void destroy_scanner();

#endif
