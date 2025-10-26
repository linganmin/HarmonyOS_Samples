/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:ModuleManager模块加载流程是什么样的？
*/

// [Start demoModule]
static napi_module demoModule = {
  .nm_version = 1, // Nm version number, default value is 1, type is int
  .nm_flags = 0, // Nm identifier, type unsigned int
  .nm_filename = nullptr, // File name, not currently paid attention to, use default value, type is char*
  .nm_register_func = Init, // Specify the entry function for nm, type napi_addon_register_func
  .nm_modname = "entry", // Specify the module name for TS page import, type char*
  .nm_priv = ((void*)0),  // Not paying attention for now, just use the default, type is void*
  .reserved = { 0 } // Not paying attention for now, just use the default value, type is void*
};
// [End demoModule]

