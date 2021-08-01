/*
 * Simple routines to wrap memory allocation and facilitate error handling.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "errors.h"

void* memory_alloc(size_t size) {

    void* ptr = calloc(1, size); // memory is cleared by calloc().
    if(ptr == NULL) {
        fatal_error("cannot allocate %lu bytes", size);
        exit(1);
    }

    return ptr;
}

void* memory_realloc(void* ptr, size_t size) {

    void* nptr = realloc(ptr, size);
    if(nptr == NULL) {
        fatal_error("cannot re-allocate ptr %p with %lu bytes", ptr, size);
        exit(1);
    }

    return nptr;
}

void memory_free(void* ptr) {

    if(ptr != NULL)
        free(ptr);
    else {
        fatal_error("cannot free NULL pointer");
        exit(1);
    }
}

char* memory_dupstr(const char* str) {

    size_t len = strlen(str) + 1;
    char* buf = malloc(len);
    if(buf == NULL) {
        fatal_error("cannot allocate string of %lu bytes", len);
        exit(1);
    }
    memcpy(buf, str, len);
    return buf;
}

void* memory_dupdata(void* data, size_t size) {

    void* ptr = malloc(size);
    if(ptr == NULL) {
        fatal_error("cannot duplicate %lu bytes", size);
        exit(1);
    }
    memcpy(ptr, data, size);
    return ptr;
}
