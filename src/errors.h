#ifndef __ERROR_H__
#define __ERROR_H__

void error(const char* fmt, ...);
void fatal_error(const char* fmt, ...);
int get_errors();
void reset_errors();
void msg(int level, const char* fmt, ...);

#endif
