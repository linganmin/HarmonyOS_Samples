/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

#include "napi/native_api.h"
#include "NumberType.h"
#include "StringBoolType.h"
#include "ArrayType.h"
#include "ArraybufferType.h"
#include "ObjectType.h"
#include "DateType.h"

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    /* Associate the externally provided interface with the written method, for example, associate add with the Add
     * method.
    */
    napi_property_descriptor desc[] = {
        {"add", nullptr, NumberType::Add, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"strAdd", nullptr, StringBoolType::StrAdd, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"arrReverse", nullptr, ArrayType::ArrReverse, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"arrayBuf", nullptr, ArraybufferType::ArrayBuf, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"obj", nullptr, ObjectType::Obj, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"isDate", nullptr, DateType::IsDate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createDate", nullptr, DateType::CreateDate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDateValue", nullptr, DateType::GetDateValue, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    // napi_define_properties construct a return value that contains a list of methods that correspond.
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

// Configure the module description and set the Init method to the napi_module entry method.
static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,   // napi_module the entrance method.
    .nm_modname = "conversion", // napi_module module name.
    .nm_priv = ((void *)0),
    .reserved = {0}
};

extern "C" __attribute__((constructor)) void RegisterConversionModule(void) { napi_module_register(&demoModule); }