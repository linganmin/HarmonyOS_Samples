#ifndef PROJECT5_REVARKTSOBJ_H
#define PROJECT5_REVARKTSOBJ_H
#include "napi/native_api.h"
class RevArkTSObj {
public:
    static napi_value ModifyObject(napi_env env, napi_callback_info info);
};
#endif // PROJECT5_REVARKTSOBJ_H
