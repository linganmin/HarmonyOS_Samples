#ifndef PROJECT5_BINDCOBJECT_H
#define PROJECT5_BINDCOBJECT_H
#include "napi/native_api.h"
class BindCObject {
public:
    static napi_value ArkTSConstructor(napi_env env, napi_callback_info info);
};
#endif //PROJECT5_BINDCOBJECT_H
