#ifndef PROJECT5_CUSTOMOBJECT_H
#define PROJECT5_CUSTOMOBJECT_H
#include "napi/native_api.h"
class CustomObject {
    public:
    static napi_value Test(napi_env env, napi_callback_info info);
    static napi_value Test1(napi_env env, napi_callback_info info);
};
#endif // PROJECT5_CUSTOMOBJECT_H
