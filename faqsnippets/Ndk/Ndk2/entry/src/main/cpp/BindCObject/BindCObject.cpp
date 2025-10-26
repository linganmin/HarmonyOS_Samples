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
/**
 * FAQ: ArkTS侧如何释放绑定的C++侧对象
 */
#include "BindCObject.h"
#include "hilog/log.h"
#include "interface/MyDemo.h"
#include "napi/native_api.h"

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200 // 全局domain宏，标识业务领域
#define LOG_TAG "MY_TAG"  // 全局tag宏，标识模块日志tag

// ArkTS对象构造函数
napi_value BindCObject::ArkTSConstructor(napi_env env, napi_callback_info info) {
    // 创建napi对象
    napi_value ArkTSDemo = nullptr;
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    // 获取构造函数入参
    napi_get_cb_info(env, info, &argc, args, &ArkTSDemo, nullptr);

    // args[0] js传入的参数
    char name[1024];
    size_t res = 0;
    napi_get_value_string_utf8(env, args[0], name, sizeof(name) + 1, &res);

    // 创建C++对象
    MyDemo *CDemo = new MyDemo(name);
    OH_LOG_INFO(LOG_APP, "%{public}s", (CDemo->name).c_str());

    // 设置js对象name属性
    napi_set_named_property(env, ArkTSDemo, "name", args[0]);

    // 绑定ArkTS对象ArkTSDemo与C++对象CDemo
    // [Start bind_c_object_cpp]
    napi_wrap(
        env, ArkTSDemo, CDemo,
        // Define a callback function for ArkTS object recycling to destroy C++objects and prevent memory leaks
        [](napi_env env, void *finalize_data, void *finalize_hint) {
            MyDemo *cDemo = (MyDemo *)finalize_data;
            delete cDemo;
            cDemo = nullptr;
        },
        nullptr, nullptr);
    // [End bind_c_object_cpp]
    return ArkTSDemo;
}
