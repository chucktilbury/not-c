/*
 * Symbols are stored in a binary tree because it's quick and easy. There
 * will never more than a couple of hundred symbols, one would think.
 * Different storage and retrieval techniques are not going to make much
 * difference.
 *
 * In the AST, when a node needs to reference a symbol, it stores a pointer to
 * one of these data structures, so all of the data pertaining to a symbol is
 * kept here.
 *
 */
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#include "memory.h"
#include "errors.h"
#include "symbols.h"
#include "scanner.h"

// global symbol table
static symbol_table_t* root = NULL;

/*
 * Recursively add the symbol to the tree.
 */
static symbols_error_t recursive_add(symbol_table_t* root, symbol_table_t* node) {

    if(strcmp(root->name, node->name) < 0) {
        if(root->left == NULL) {
            root->left = node;
            return SYM_NO_ERROR;
        }
        else
            return recursive_add(root->left, node);
    }
    else if(strcmp(root->name, node->name) > 0) {
        if(root->right == NULL) {
            root->right = node;
            return SYM_NO_ERROR;
        }
        else
            return recursive_add(root->right, node);
    }
    else {
        return SYM_EXISTS;  // node exists.
    }
}

/*
 * Recursively find a symbol in the tree.
 */
static symbol_table_t* recursive_find(symbol_table_t* root, const char* name) {

    if(root != NULL) {
        if(strcmp(root->name, name) < 0) {
            if(root->left == NULL)
                return NULL;
            else
                return recursive_find(root->left, name);

        }
        else if(strcmp(root->name, name) > 0) {
            if(root->right == NULL)
                return NULL;
            else
                return recursive_find(root->right, name);
        }
        else
            return root;
    }

    return NULL;
}

/*
 * Print the symbol according to type.
 */
void print_node(symbol_table_t* node) {

    printf("name: %s\n", node->name);
    if(node->value != NULL) {
        printf("    type:        %s\n", ST_TOSTR(node->value->type));
        printf("    is_assigned: %s\n", node->value->is_assigned? "TRUE": "FALSE");
        printf("    is_const:    %s\n", node->value->is_const? "TRUE": "FALSE");
        printf("    is_private:  %s\n", node->value->is_private? "TRUE": "FALSE");
        switch(node->value->type) {
            case ST_OBJECT:
                printf("    value: %p\n", node->value->value.obj);
                print_obj(6, node->value->value.obj);
                break;
            case ST_INUM:
                printf("    value: %ld\n", node->value->value.inum);
                break;
            case ST_UNUM:
                printf("    value: %lu\n", node->value->value.unum);
                break;
            case ST_FNUM:
                printf("    value: %0.3f\n", node->value->value.fnum);
                break;
            case ST_STRING:
                printf("    value: \"%s\"\n", node->value->value.str);
                break;
            case ST_BOOL:
                printf("    value: %s\n", node->value->value.boolean? "TRUE":"FALSE");
                break;
            default:
                fatal_error("value has unknown type: %02X", node->value->type);

        }
    }
    else
        printf("    node has no value assigned\n");
}

/*
 * Recursively dump the symbol table.
 */
static void recursive_dump(symbol_table_t* node) {

    if(node != NULL) {
        if(node->left != NULL) {
            recursive_dump(node->left);
        }

        if(node->right != NULL) {
            recursive_dump(node->right);
        }

        print_node(node);
    }
}

/*
 * Add a symbol to the tree. Note that the value is re-allocated to facilitate
 * using a locally defined data structure to initialize the data.
 */
symbols_error_t add_symbol(const char* name, symbol_data_t* val) {

    symbol_table_t* node = ALLOC_DS(symbol_table_t);
    node->name = DUPSTR(name);
    node->value = DUP_DS(val, symbol_data_t);
    node->line_no = get_line_no();
    node->col_no = get_col_no();

    if(root == NULL) {
        root = node;
        return SYM_NO_ERROR;
    }
    else
        return recursive_add(root, node);
}

/*
 * Update the data in the symbol using only one lookup.
 */
symbols_error_t update_symbol(const char* name, symbol_data_t* val) {

    symbol_table_t* sym = recursive_find(root, name);
    if(sym != NULL) {
        if(sym->value != NULL)
            FREE(sym->value);
        sym->value = DUP_DS(val, symbol_data_t);
        return SYM_NO_ERROR;
    }

    return SYM_NOT_FOUND;
}

/*
 * Find the name and fill out the value data structure. If the symbol is not
 * found, then return SYM_NOT_FOUND and do not change the data structure.
 */
symbols_error_t find_symbol(const char* name, symbol_data_t* val) {

    symbol_table_t* sym = recursive_find(root, name);
    if(sym != NULL) {
        if(sym->value != NULL) {
            memcpy(val, sym->value, sizeof(symbol_data_t));
            return SYM_NO_ERROR;
        }
        else
            return SYM_NOT_ASSIGNED;
    }

    return SYM_NOT_FOUND;
}

/*
 * Return SYM_TRUE is the symbol has been assigned a value. If it has not, then
 * return SYM_FALSE. Note that these return values are not the same as a
 * boolean value.
 */
symbols_error_t symbol_is_assigned(const char* name) {

    symbol_table_t* sym = recursive_find(root, name);
    if(sym != NULL) {
        if(sym->value != NULL)
            return sym->value->is_assigned == 0? SYM_FALSE: SYM_TRUE;
        else
            return SYM_NOT_ASSIGNED;
    }

    return SYM_NOT_FOUND;
}

/*
 * Return SYM_TRUE is the symbol is a constant value. If not, then
 * return SYM_FALSE. Note that these return values are not the same as a
 * boolean value.
 */
symbols_error_t symbol_is_const(const char* name) {

    symbol_table_t* sym = recursive_find(root, name);
    if(sym != NULL) {
        if(sym->value != NULL)
            return sym->value->is_const == 0? SYM_FALSE: SYM_TRUE;
        else
            return SYM_NOT_ASSIGNED;
    }

    return SYM_NOT_FOUND;
}

/*
 * Return SYM_TRUE is the symbol is a private scope. If not, then
 * return SYM_FALSE. Note that these return values are not the same as a
 * boolean value.
 */
symbols_error_t symbol_is_private(const char* name) {

    symbol_table_t* sym = recursive_find(root, name);
    if(sym != NULL) {
        if(sym->value != NULL)
            return sym->value->is_private == 0? SYM_FALSE: SYM_TRUE;
        else
            return SYM_NOT_ASSIGNED;
    }

    return SYM_NOT_FOUND;
}

/*
 * Create a symbol value data structure. Used mostly internally, but also part
 * of the API. The is_assigned flag is left false.
 */
symbol_data_t* create_symbol_data(symbol_type_t type,
                                    unsigned char is_const,
                                    unsigned char is_private) {

    symbol_data_t* data = ALLOC_DS(symbol_data_t);
    data->type = type;
    data->is_const = is_const;
    data->is_private = is_private;
    data->is_assigned = 0;

    return data;
}

/*
 * Create a symbol that has an object as it's value. If the value is not NULL,
 * then set the is_assigned flag.
 */
symbols_error_t add_obj_symbol(const char* name, object_t* obj,
                                    unsigned char is_const,
                                    unsigned char is_private) {

    symbol_data_t* data = create_symbol_data(ST_OBJECT, is_const, is_private);
    data->is_assigned = obj == NULL? 0: 1;
    data->value.obj = obj;
    return add_symbol(name, data);
}

/*
 * Create a signed number symbol and assign the value. The is_assigned flag
 * will be stored in the data along with the other attributes.
 */
symbols_error_t add_inum_symbol(const char* name, long inum,
                                    unsigned char is_assigned,
                                    unsigned char is_const,
                                    unsigned char is_private) {

    symbol_data_t* data = create_symbol_data(ST_INUM, is_const, is_private);
    data->is_assigned = is_assigned;
    data->value.inum = inum;
    return add_symbol(name, data);
}

/*
 * Create an unsigned number symbol and assign the value. The is_assigned flag
 * will be stored in the data along with the other attributes.
 */
symbols_error_t add_unum_symbol(const char* name, unsigned long unum,
                                    unsigned char is_assigned,
                                    unsigned char is_const,
                                    unsigned char is_private) {

    symbol_data_t* data = create_symbol_data(ST_UNUM, is_const, is_private);
    data->is_assigned = is_assigned;
    data->value.unum = unum;
    return add_symbol(name, data);
}

/*
 * Create a float number symbol and assign the value. The is_assigned flag
 * will be stored in the data along with the other attributes.
 */
symbols_error_t add_fnum_symbol(const char* name, double fnum,
                                    unsigned char is_assigned,
                                    unsigned char is_const,
                                    unsigned char is_private) {

    symbol_data_t* data = create_symbol_data(ST_FNUM, is_const, is_private);
    data->is_assigned = is_assigned;
    data->value.fnum = fnum;
    return add_symbol(name, data);
}

/*
 * Create a string symbol and assign the value. The is_assigned flag
 * will be stored in the data along with the other attributes.
 */
symbols_error_t add_str_symbol(const char* name, char* str,
                                    unsigned char is_assigned,
                                    unsigned char is_const,
                                    unsigned char is_private) {

    symbol_data_t* data = create_symbol_data(ST_STRING, is_const, is_private);
    data->is_assigned = is_assigned;
    data->value.str = str;
    return add_symbol(name, data);
}

/*
 * Create a boolean symbol and assign the value. The is_assigned flag
 * will be stored in the data along with the other attributes.
 */
symbols_error_t add_bool_symbol(const char* name, unsigned char boolean,
                                    unsigned char is_assigned,
                                    unsigned char is_const,
                                    unsigned char is_private) {

    symbol_data_t* data = create_symbol_data(ST_BOOL, is_const, is_private);
    data->is_assigned = is_assigned;
    data->value.boolean = boolean;
    return add_symbol(name, data);
}


void dump_symbols() {

    printf("Dump symbol table\n");
    recursive_dump(root);
}


#if 0
/*
 * Add a symbol to the tree. If it already exists, return !0, else
 * return 0. If the value is valid, then set the flag to true.
 */
symbols_error_t add_symbol(const char* name) { //, double val, bool flag) {

    symbol_table_t* node = ALLOC_DS(symbol_table_t);
    node->name = STRDUP(name);
    //node->value = val;
    //node->is_assigned = flag;

    if(root == NULL) {
        root = node;
        return SYM_NO_ERROR;
    }
    else
        return recursive_add(root, node);
}

/*
 * Assign a value to the symbol. If it is not found then return !0. Else
 * return 0.
 */
symbols_error_t assign_symbol(const char* name, symbol_data_t* val) {

    symbol_table_t* sym = recursive_find(root, name);
    if(sym != NULL) {
        sym->value = val;
        sym->is_assigned = true;
        return SYM_NO_ERROR;
    }

    return SYM_NOT_FOUND;
}

/*
 * Find a symbol in the tree. If it exists and has been assigned, then return
 * a pointer to the value associated with it. Otherwise, return NULL.
 */
symbols_error_t find_symbol(const char* name, symbol_data_t* val) {

    symbol_table_t* sym = recursive_find(root, name);
    if(sym != NULL) {
        if(val != NULL)
            *val = sym->value;
        return SYM_NO_ERROR;
    }

    return SYM_NOT_FOUND;
}

/*
 * Return whether the symbol has been assigned a value.
 */
symbols_error_t symbol_is_assigned(const char* name) {

    symbol_table_t* sym = recursive_find(root, name);
    if(sym != NULL) {
        if(sym->is_assigned)
            return SYM_TRUE;
        else
            return SYM_FALSE;
    }

    return SYM_NOT_FOUND;
}

/*
 * Traverse the tree and print each symbol with it's current value.
 */
void dump_symbols() {

    printf("Dump symbol table\n");
    recursive_dump(root);
}

#endif
