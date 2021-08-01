
#include <stdio.h>

#include "memory.h"
#include "errors.h"
#include "object.h"


object_t* create_list_obj() {

    object_t* obj = ALLOC_DS(object_t);
    obj->type = OT_LIST;
    obj->value.list = ALLOC_DS(obj_list_t);
    // list stuff here

    return obj;
}

object_t* create_dict_obj() {

    object_t* obj = ALLOC_DS(object_t);
    obj->type = OT_DICT;
    obj->value.dict = ALLOC_DS(obj_dict_t);
    // dict stuff here

    return obj;
}

object_t* create_struc_obj() {

    object_t* obj = ALLOC_DS(object_t);
    obj->type = OT_STRUCT;
    obj->value.struc = ALLOC_DS(obj_struc_t);
    // struc stuff here

    return obj;
}

object_t* create_namesp_obj() {

    object_t* obj = ALLOC_DS(object_t);
    obj->type = OT_NAMESPACE;
    obj->value.namesp = ALLOC_DS(obj_namesp_t);
    // namespace stuff here

    return obj;
}


void destroy_obj(object_t* obj) {

    if(obj != NULL) {
        switch(obj->type) {
            case OT_LIST:
                if(obj->value.list != NULL)
                    FREE(obj->value.list);
                break;
            case OT_DICT:
                if(obj->value.dict != NULL)
                    FREE(obj->value.dict);
                break;
            case OT_STRUCT:
                if(obj->value.struc != NULL)
                    FREE(obj->value.struc);
                break;
            case OT_NAMESPACE:
                if(obj->value.namesp != NULL)
                    FREE(obj->value.namesp);
                break;
            default:
                fatal_error("Unknown object type in destroy_obj(): %02X", obj->type);
        }
    }
}

void print_obj(int indent, object_t* obj) {

    if(obj != NULL) {
        printf("%*s%s\n", indent, " ", OT_TOSTR(obj->type));
        switch(obj->type) {
            case OT_LIST:
                if(obj->value.list != NULL)
                    printf("%*s    value: %p\n",indent, " ", obj->value.list);
                else
                    printf("%*s    value: NULL\n",indent, " ");
                break;
            case OT_DICT:
                if(obj->value.dict != NULL)
                    printf("%*s    value: %p\n",indent, " ", obj->value.dict);
                else
                    printf("%*s    value: NULL\n",indent, " ");
                break;
            case OT_STRUCT:
                if(obj->value.struc != NULL)
                    printf("%*s    value: %p\n",indent, " ", obj->value.struc);
                else
                    printf("%*s    value: NULL\n",indent, " ");
                break;
            case OT_NAMESPACE:
                if(obj->value.namesp != NULL)
                    printf("%*s    value: %p\n",indent, " ", obj->value.namesp);
                else
                    printf("%*s    value: NULL\n",indent, " ");
                break;
            default:
                fatal_error("Unknown object type in destroy_obj(): %02X", obj->type);
        }
    }
}
