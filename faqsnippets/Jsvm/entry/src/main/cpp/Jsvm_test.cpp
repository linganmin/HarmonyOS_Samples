//
// Created on 2025/5/21.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
//FAQ:如何正确使用OH_JSVM_Init
//FAQ:如何正确使用OH_JSVM_GetValueStringUtf8获取字符串

#include "ark_runtime/jsvm.h"
#include <string>

// [Start jsvm_init]
#include "jsvm_types.h"
#include "jsvm.h"

void Init(const JSVM_InitOptions* options) {
  static bool initialized = false;
  if (initialized) {
    return;
  }
  OH_JSVM_Init(options);
  initialized = true;
}
int main() {
  Init(nullptr);
  Init(nullptr);
}
// [End jsvm_init]

// [Start get_value_string_utf8]
JSVM_EXTERN JSVM_Status OH_JSVM_GetValueStringUtf8(JSVM_Env env,
                                                   JSVM_Value value,
                                                   char* buf,
                                                   size_t bufsize,
                                                   size_t* result);
// [End get_value_string_utf8]

// [Start get_value_string]
std::string GetValueString(JSVM_Env env, JSVM_Value value) {
    constexpr size_t PREALLOC_SIZE = 256;
    char preallocMemory[PREALLOC_SIZE];


    char *buff = preallocMemory;
    
    // Obtain length
    size_t totalLen = 0;
    OH_JSVM_GetValueStringUtf8(env, value, nullptr, 0, &totalLen);
    size_t needed = totalLen + 1;


    if (needed > PREALLOC_SIZE) {
        // Allocate space, size must include termination character
        buff = new char[needed];
    }
    // get string
    OH_JSVM_GetValueStringUtf8(env, value, buff, needed, nullptr);


    std::string ret(buff, totalLen);


    if (needed > PREALLOC_SIZE) {
        delete[] buff;
    }
    return ret;
}
// [End get_value_string]
