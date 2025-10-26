//
// Created on 2025/5/29.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
/**
 * FAQ:多so相互依赖场景下如何解耦
 */
// [Start demo_so]
// a.cpp
extern "C" {     // Be sure to enclose it with extern 'C' {}
#include "a.h"
#include <dlfcn.h>
#include "stdio.h"
typedef int (*FUNC_SUB)(int, int);
int add(int a, int b) { return a + b; }
int getb(char *path, int a, int b) {       // Path:The sandbox path for passing So files from ArkTS side (note that the path should be passed from ArkTS side, otherwise it may not be found, and the specific code will be listed later)
    void *handle = dlopen(path, RTLD_LAZY);  // Open the dynamic link library with path as path
    if (!handle) {
        return 0;
    }
    FUNC_SUB sub_func = (FUNC_SUB)dlsym(handle, "sub"); // Get the function named sub
    int res = sub_func(a, b);                           // caller function
    dlclose(handle);                                    // Close dynamic link library
    return res;
}
}
// [End demo_so]