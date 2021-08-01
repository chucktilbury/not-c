
#ifndef __OBJECT_H__
#define __OBJECT_H__

typedef enum {
    OT_LIST,
    OT_DICT,
    OT_STRUCT,
    OT_NAMESPACE,
} object_type_t;

#define OT_TOSTR(t) (\
    ((t) == OT_LIST)? "LIST": \
    ((t) == OT_DICT)? "DICT": \
    ((t) == OT_NAMESPACE)? "NAMESPACE": \
    ((t) == OT_STRUCT)? "STRUCT": "UNKNOWN"\
    )

typedef struct {
    // stub
} obj_list_t;

typedef struct {
    // stub
} obj_dict_t;

typedef struct {
    // stub
} obj_struc_t;

typedef struct {
    // stub
} obj_namesp_t;

/*
 * These value structs have a pointer to an entry in the AST.
 */
typedef struct {
    object_type_t type;
    union {
        obj_list_t* list;
        obj_dict_t* dict;
        obj_struc_t* struc;
        obj_namesp_t* namesp;
    } value;
} object_t;

object_t* create_list_obj();
object_t* create_dict_obj();
object_t* create_struc_obj();
object_t* create_namesp_obj();

void destroy_obj(object_t* obj);
void print_obj(int indent, object_t* obj);

#endif
