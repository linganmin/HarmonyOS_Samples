/*
* FAQ:如何管理JSVM_CallbackStruct生命周期
*/

// [Start Jsvm_CallbackStruct]
JSVM_Value CreateFunction(JSVM_Env env) {
    JSVM_CallbackStruct callbackStruct;
    callbackStruct.data = nullptr;
    callbackStruct.callback = [](JSVM_Env env, JSVM_CallbackInfo info) -> JSVM_Value {
        return nullptr;
    };

    JSVM_Value result = nullptr;
    OH_JSVM_CreateFunction(env, "foo", JSVM_AUTO_LENGTH, &callbackStruct, &result);
    return result;
}
void SomeFunction() {
    char stack[] = "hello world";
}
// [End Jsvm_CallbackStruct]

