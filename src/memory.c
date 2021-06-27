/*
 * Simple wrapper around memory allocation routines that facilitate error
 * handling. All memory allocation errors are fatal.
 */
#include "common.h"

void* memory_alloc(size_t num, size_t size) {

    void* ptr = calloc(num, size);
    if(ptr == NULL)
        fatal_error("cannot allocate %lu bytes", num*size);

    return ptr;
}

void* memory_realloc(void* ptr, size_t size) {

    void* nptr = realloc(ptr, size);
    if(nptr == NULL)
        fatal_error("cannot reallocate %lu bytes", size);

    return nptr;
}

void memory_free(void* ptr) {

    free(ptr);
}

char* memory_strdup(const char* str) {

    size_t len = strlen(str) + 1;
    char* ptr = malloc(len);
    if(ptr == NULL)
        fatal_error("cannot strdup %lu bytes", len);

    memcpy((void*)ptr, str, len);
    return ptr;
}
