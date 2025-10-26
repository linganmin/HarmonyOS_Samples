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
#include "UintArr/UintArr.h"
#include "CGetArkTSObject/CGetArkTSObject.h"
#include "CreatBuffer/CreatBuffer.h"
#include "CharToArrBuffer/CharToArrBuffer.h"
#include "CustomObject/CustomObject.h"
#include "RevArkTSObj/RevArkTSObj.h"
#include "BindCObject/BindCObject.h"
#include "IsMainThread/IsMainThread.h"
#include "HashMap/HashMap.h"
#include "ScreenBrightness/ScreenBrightness.h"
#include "WriteFile/WriteFile.h"
#include "CGetAppPackageName/CGetAppPackageName.h"
#include "CallSystemModule/CallSystemModule.h"
#include "WorkerCallNapiLoop/WorkerCallNapiLoop.h"

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"uintArr", nullptr, Demo1::UintArr, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"cal", nullptr, CGetArkTSObject::Cal, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testBuffer", nullptr, CreatBuffer::TestBuffer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testCharBuf", nullptr, CharToArrBuffer::TestCharBuf, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"test", nullptr, CustomObject::Test, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"test1", nullptr, CustomObject::Test1, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"arkTSConstructor", nullptr, BindCObject::ArkTSConstructor, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"modifyObject", nullptr, RevArkTSObj::ModifyObject, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"MainThread", nullptr, IsMainThread::MainThread, nullptr, nullptr, nullptr, napi_default, nullptr},
        { "tsPutMap", nullptr, HashMap::TsPutMap, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "mapJson", nullptr, HashMap::MapJson, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "napiLoadModule", nullptr, ScreenBrightness::NapiLoadModule, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "writeTemporaryFile", nullptr, WriteFile::WriteTemporaryFile, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "getCurrentApplicationPackageName", nullptr, CGetAppPackageName::GetCurrentApplicationPackageName, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "getDisplaySize", nullptr, CallSystemModule::GetDisplaySize, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "mainThread", nullptr, WorkerCallNapiLoop::MainThread, nullptr, nullptr, nullptr, napi_default, nullptr },
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }
