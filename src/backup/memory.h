/*
 * Memory interface. This is a simple wrapper around the memory allocation
 * routines to facilitate error handling.
 */
#ifndef __MEMORY_H__
#  define __MEMORY_H__

#  define MALLOC(s)                   memory_alloc(1, s)
#  define CALLOC(n,s)                 memory_alloc(n, s)
#  define REALLOC(p,s)                memory_realloc(p, s)
#  define FREE(p)                     memory_free(p)
#  define STRDUP(s)                   memory_strdup(s)
#  define ALLOC_DS(type)              memory_alloc(1, sizeof(type))
#  define ALLOC_LIST(num,type)        memory_alloc(num, sizeof(type)*num)
#  define REALLOC_LIST(ptr,num,type)  memory_realloc(ptr, sizeof(type)*num)

void *memory_alloc(size_t num, size_t size);
void *memory_realloc(void *ptr, size_t size);
void memory_free(void *ptr);
char *memory_strdup(const char *str);

#endif
