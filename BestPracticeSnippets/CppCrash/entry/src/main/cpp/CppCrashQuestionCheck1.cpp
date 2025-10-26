/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//
// Created on 2025/5/20.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

/**
 * 最佳实践：CppCrash问题排查方法
 */

// [Start getStackReference]
#include <iostream>

int &getStackReference() {
    int x = 5;
    return x; // Return the reference of x
}


int Run1() {
    int &ref = getStackReference(); // Obtain the reference of x
    // x is released after the getStackReference function returns
    // ref is now a dangling reference. Continuing to access it will result in undefined behavior
    std::cout << ref << std::endl; // Attempting to output the value of x is an undefined behavior
    return 0;
}
// [End getStackReference]