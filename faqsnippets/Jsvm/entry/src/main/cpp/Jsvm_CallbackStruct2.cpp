/*
* FAQ:如何管理JSVM_CallbackStruct生命周期
*/

// [Start Jsvm_CallbackStruct2]
// ...

auto func = CreateFunction(env);
SomeFunction();

JSVM_Value undef = nullptr;
OH_JSVM_GetUndefined(env, &undef);

JSVM_Value result;
OH_JSVM_CallFunction(env, undef, func, 0, nullptr, &result);

// ...
// [End Jsvm_CallbackStruct2]

