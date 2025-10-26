/*
* FAQ:如何管理JSVM_CallbackStruct生命周期
*/

// [Start Jsvm_CallbackStruct3]
JSVM_Value CreateFunction(JSVM_Env env) {
    JSVM_Callback cb = new JSVM_CallbackStruct;
    cb->data = nullptr;
    cb->callback = [](JSVM_Env env, JSVM_CallbackInfo info) -> JSVM_Value { return nullptr; };

    JSVM_Value result = nullptr;
    OH_JSVM_CreateFunction(env, "foo", JSVM_AUTO_LENGTH, cb, &result);
    OH_JSVM_AddFinalizer(
        env, result, reinterpret_cast<void *>(cb),
        [](JSVM_Env env, void *data, void *hint) -> void { 
            delete static_cast<JSVM_Callback>(data);
        }, nullptr, nullptr);

    return result;
}
// [End Jsvm_CallbackStruct3]

