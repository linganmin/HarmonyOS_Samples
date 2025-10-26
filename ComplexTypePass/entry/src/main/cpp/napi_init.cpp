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
#include <multimedia/image_framework/image_pixel_map_mdk.h>
#include <multimedia/image_framework/image_pixel_map_napi.h>
#include <nlohmann/json.hpp>
#include <sstream>
#include <string>
using namespace std;
// [Start napi_init1]
// entry\src\main\cpp\napi_init.cpp
static std::string value2String(napi_env env, napi_value value) {
    size_t string_size = 0;
    // Get string length
    napi_get_value_string_utf8(env, value, nullptr, 0, &string_size);
    std::string result_string;
    result_string.resize(string_size + 1);
    // Convert to string based on length
    napi_get_value_string_utf8(env, value, &result_string[0], string_size + 1, &string_size);
    return result_string;
}
// [End napi_init1]

// [Start napi_init2]
// entry\src\main\cpp\napi_init.cpp
static napi_value string2value(napi_env env, string str) {
    int length = str.length();

    napi_value output_string;
    napi_create_string_utf8(env, str.c_str(), length, &output_string);

    return output_string;
}
// [End napi_init2]

// [Start napi_init3]
// entry\src\main\cpp\napi_init.cpp
napi_value uint8ArrayPassingNapi2Ts(napi_env env, vector<uint8_t> &output_array) {
    // Number of data
    int num = output_array.size();

    // create output_buffer
    napi_value output_buffer;
    void *output_ptr = NULL;
    napi_create_arraybuffer(env, num * sizeof(uint8_t), &output_ptr, &output_buffer);

    // output_array
    napi_value output_array_napi;
    napi_create_typedarray(env, napi_uint8_array, num, output_buffer, 0, &output_array_napi);

    // Assign values to output_ptr and output_buffer
    uint8_t *output_bytes = (uint8_t *)output_ptr;
    for (int i = 0; i < num; i++) {
        output_bytes[i] = output_array[i];
    }

    return output_array_napi;
}
// [End napi_init3]

// [Start napi_init4]
// entry\src\main\cpp\napi_init.cpp
void uint8ArrayPassingTs2Napi(napi_env env, napi_callback_info info, vector<uint8_t> &input_array) {
    // Obtain parameters transmitted from the TS layer
    size_t argc = 1;
    napi_value args;
    // Gets detailed information about the function call, such as input parameters.
    napi_get_cb_info(env, info, &argc, &args, NULL, NULL);
    napi_value input_array_napi = args;

    // Retrieve the input array typedarray and generate input_buffer
    napi_typedarray_type type;
    napi_value input_buffer;
    size_t byte_offset;
    size_t length;
    napi_get_typedarray_info(env, input_array_napi, &type, &length, NULL, &input_buffer, &byte_offset);

    // Retrieve array data
    void *data;
    size_t byte_length;
    napi_get_arraybuffer_info(env, input_buffer, &data, &byte_length);

    if (type == napi_uint8_array) {
        uint8_t *data_bytes = (uint8_t *)(data);
        int num = length / sizeof(uint8_t);

        for (int i = 0; i < num; i++) {
            input_array.push_back(*((uint8_t *)(data_bytes) + i));
        }
    }

    return;
}
// [End napi_init4]

// [Start napi_init5]
// entry\src\main\cpp\napi_init.cpp
static napi_value uint8ArrayPassing(napi_env env, napi_callback_info info) {
    vector<uint8_t> num_array = {};
    uint8ArrayPassingTs2Napi(env, info, num_array);
    return uint8ArrayPassingNapi2Ts(env, num_array);
}
// [End napi_init5]

// [Start napi_init6]
// entry\src\main\cpp\napi_init.cpp
napi_value objectPassingTs2Napi(napi_env env, napi_callback_info info) {
    // Obtain parameters transmitted from the TS layer
    size_t argc = 1;
    napi_value args;
    // Gets detailed information about the function call, such as input parameters.
    napi_get_cb_info(env, info, &argc, &args, NULL, NULL);

    return args;
}
// [End napi_init6]

// [Start napi_init7]
// entry\src\main\cpp\napi_init.cpp
napi_value objectPassingNapi2Ts(napi_env env, napi_value inputObj) {
    static int32_t codeChild = 1;
    static int32_t codeAdult = 1;

    napi_value input_age;
    napi_value input_name;
    napi_get_named_property(env, inputObj, "age", &input_age);
    napi_get_named_property(env, inputObj, "name", &input_name);

    napi_value output_obj;
    napi_value output_is_adult;
    napi_value output_code;
    napi_value output_age = input_age;
    napi_value output_name = input_name;
    int32_t age;
    napi_get_value_int32(env, input_age, &age);
    napi_get_boolean(env, age >= 18, &output_is_adult);
    if (age < 18) {
        napi_create_int32(env, codeChild++, &output_code);
    } else {
        napi_create_int32(env, codeAdult++, &output_code);
    }

    const char *keysArray[] = {"isAdult", "code", "age", "name"};
    const napi_value outputArray[] = {output_is_adult, output_code, output_age, output_name};

    napi_create_object_with_named_properties(env, &output_obj, 4, keysArray, outputArray);

    return output_obj;
}
// [End napi_init7]

// [Start napi_init8]
// entry\src\main\cpp\napi_init.cpp
static napi_value objectPassing(napi_env env, napi_callback_info info) {
    return objectPassingNapi2Ts(env, objectPassingTs2Napi(env, info));
}
// [End napi_init8]

// [Start napi_init9]
// entry\src\main\cpp\napi_init.cpp
map<string, int> hashMapPassingTs2Napi(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args;
    // Gets detailed information about the function call, such as input parameters.
    napi_get_cb_info(env, info, &argc, &args, nullptr, nullptr);

    return nlohmann::json::parse(value2String(env, args).c_str());
}
// [End napi_init9]

// [Start napi_init10]
// entry\src\main\cpp\napi_init.cpp
napi_value hashMapPassingNapi2Ts(napi_env env, map<string, int> inputMap) {
    static map<string, int> points_table;
    std::map<string, int>::iterator iter;
    for (iter = inputMap.begin(); iter != inputMap.end(); ++iter) {
        points_table[iter->first] += iter->second;
    }

    string dump_string = nlohmann::ordered_json(points_table).dump();
    return string2value(env, dump_string);
}
// [End napi_init10]

// [Start napi_init11]
static napi_value hashMapPassing(napi_env env, napi_callback_info info) {
    return hashMapPassingNapi2Ts(env, hashMapPassingTs2Napi(env, info));
}
// [End napi_init11]

// [Start napi_init12]
// entry\src\main\cpp\napi_init.cpp
static napi_value pixelMapPassing(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value ts_pixel_map;
    // Gets detailed information about the function call, such as input parameters.
    napi_get_cb_info(env, info, &argc, &ts_pixel_map, nullptr, nullptr);

    // Initialize the NativePixelMap object.
    // NativePixelMap and ArkTSPixelMap share memory space.
    // That is, modifications to NativePixelMap also affect ArkTSPixelMap.
    NativePixelMap *native_pixel_map = OH_PixelMap_InitNativePixelMap(env, ts_pixel_map);

    float opacity = 0.5;
    OH_PixelMap_SetOpacity(native_pixel_map, opacity);

    return nullptr;
}
// [End napi_init12]

// [Start napi_init13]
// entry\src\main\cpp\napi_init.cpp
napi_value classPassingTs2Napi(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args;
    // Gets detailed information about the function call, such as input parameters.
    napi_get_cb_info(env, info, &argc, &args, nullptr, nullptr);

    // Retrieve the method named "add" from the parameter object and store it in the "add" variable.
    napi_value add;
    napi_get_named_property(env, args, "add", &add);

    // Create parameter array
    napi_value arr[2];
    napi_create_int32(env, 114, &arr[0]);
    napi_create_int32(env, 514, &arr[1]);
    // Call the "add" method of the parameter object, pass this array as a parameter,
    // and store the result in the funcResult variable.
    napi_value func_result;
    napi_call_function(env, args, add, 2, arr, &func_result);

    // Retrieve the property values named "result" from the parameter object
    // using the napi_get_named_property function, and store them in the param_result variables.
    napi_value param_result;
    napi_get_named_property(env, args, "result", &param_result);

    string resultStr = value2String(env, func_result) + value2String(env, param_result);
    return string2value(env, resultStr);
}
// [End napi_init13]

// [Start napi_init14]
// entry\src\main\cpp\napi_init.cpp
class SampleClassNapi2Ts {
public:
    std::string hint_str;
    SampleClassNapi2Ts(string str) { this->hint_str = str; };
    std::string times(int a, int b) {
        std::ostringstream ost;
        ost << a << " × " << b << " = " << a * b;
        return ost.str();
    };
};
// [End napi_init14]

// [Start napi_init15]
// entry\src\main\cpp\napi_init.cpp
static napi_value TsConstructor(napi_env env, napi_callback_info info) {
    // Create Napi object
    napi_value ts_class_obj;
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    // Gets detailed information about the function call, such as input parameters.
    napi_get_cb_info(env, info, &argc, args, &ts_class_obj, nullptr);
    string hint_str = value2String(env, args[0]);
    // Create C++ object
    SampleClassNapi2Ts *c_class_obj = new SampleClassNapi2Ts(hint_str);
    // Set the JS object hintStr attribute
    napi_set_named_property(env, ts_class_obj, "hintStr", args[0]);
    // Binding JS objects with C++objects
    napi_wrap(
        env, ts_class_obj, c_class_obj,
        // Define callback function for recycling JS objects, used to destroy C++objects and prevent memory leaks
        [](napi_env env, void *finalize_data, void *finalize_hint) {
            SampleClassNapi2Ts *c_class_obj = (SampleClassNapi2Ts *)finalize_data;
            delete c_class_obj;
            c_class_obj = nullptr;
        },
        nullptr, nullptr);
    return ts_class_obj;
}
// [End napi_init15]

// [Start napi_init16]
// entry\src\main\cpp\napi_init.cpp
static napi_value getHintStr(napi_env env, napi_callback_info info) {
    napi_value ts_class_obj;
    // Gets detailed information about the function call, such as input parameters.
    napi_get_cb_info(env, info, nullptr, nullptr, &ts_class_obj, nullptr);

    SampleClassNapi2Ts *c_class_obj;
    // Retrieve and manipulate the C++object previously bound to jsThis using napi_unwrap
    napi_unwrap(env, ts_class_obj, reinterpret_cast<void **>(&c_class_obj));
    if (c_class_obj) {
        return string2value(env, c_class_obj->hint_str);
    } else {
        return nullptr;
    }
}
// [End napi_init16]

// [Start napi_init17]
// entry\src\main\cpp\napi_init.cpp
static napi_value setHintStr(napi_env env, napi_callback_info info) {
    // Obtain parameters transmitted from the TS layer
    size_t argc = 1;
    napi_value value;
    napi_value ts_class_obj;
    // Gets detailed information about the function call, such as input parameters.
    napi_get_cb_info(env, info, &argc, &value, &ts_class_obj, nullptr);

    SampleClassNapi2Ts *c_class_obj;
    // Retrieve and manipulate the C++object previously bound to jsThis using napi_unwrap
    napi_unwrap(env, ts_class_obj, reinterpret_cast<void **>(&c_class_obj));

    if (c_class_obj) {
        c_class_obj->hint_str = value2String(env, value);
    }

    return nullptr;
}
// [End napi_init17]

// [Start napi_init18]
// entry\src\main\cpp\napi_init.cpp
static napi_value TSTimes(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_value ts_class_obj = nullptr;
    // Gets detailed information about the function call, such as input parameters.
    napi_get_cb_info(env, info, &argc, args, &ts_class_obj, nullptr);
    SampleClassNapi2Ts *c_class_obj = nullptr;
    // Convert ArkTS object to C++ object
    napi_unwrap(env, ts_class_obj, (void **)&c_class_obj);
    // Get parameters passed by ArkTS
    int value0;
    napi_get_value_int32(env, args[0], &value0);
    int value1;
    napi_get_value_int32(env, args[1], &value1);
    string c_result = c_class_obj->times(value0, value1);
    return string2value(env, c_result);
}
// [End napi_init18]

// [Start napi_init20]
// entry\src\main\cpp\napi_init.cpp
EXTERN_C_START
// [Start napi_init19]
static napi_value Init(napi_env env, napi_value exports) {
    // [StartExclude napi_init20]
    napi_property_descriptor desc[] = {
        {"uint8ArrayPassing", nullptr, uint8ArrayPassing, nullptr, nullptr, nullptr, napi_default, nullptr},
        // [StartExclude napi_init19]
        {"objectPassing", nullptr, objectPassing, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"hashMapPassing", nullptr, hashMapPassing, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"pixelMapPassing", nullptr, pixelMapPassing, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"classPassingTs2Napi", nullptr, classPassingTs2Napi, nullptr, nullptr, nullptr, napi_default, nullptr},
        // [EndExclude napi_init19]
    };
    // [StartExclude napi_init19]
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);

    // [EndExclude napi_init20]
    napi_property_descriptor class_prop[] = {
        {"hintStr", 0, 0, getHintStr, setHintStr, 0, napi_default, 0},
        {"times", nullptr, TSTimes, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_value sample_class = nullptr;
    const char *class_name = "SampleClassNapi2Ts";
    // Establish the association between ArkTS constructor and C++ methods
    napi_define_class(env, class_name, sizeof(class_name), TsConstructor, nullptr,
                      sizeof(class_prop) / sizeof(class_prop[0]), class_prop, &sample_class);
    napi_set_named_property(env, exports, class_name, sample_class);

    return exports;
    // [EndExclude napi_init19]
}
// [End napi_init19]
EXTERN_C_END
// [End napi_init20]

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
