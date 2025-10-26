/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

#ifndef FOUNDATION_ACE_JSVM_INTERFACES_KITS_JSVM_NATIVE_COMMON_H
#define FOUNDATION_ACE_JSVM_INTERFACES_KITS_JSVM_NATIVE_COMMON_H

#define DEPRECATED __attribute__((__deprecated__))

#define JSVM_VERSION 8

#define JSVM_RETVAL_NOTHING

#define GET_AND_THROW_LAST_ERROR(env)                                                                                  \
    do {                                                                                                               \
        const JSVM_ExtendedErrorInfo *errorInfo = nullptr;                                                             \
        OH_JSVM_GetLastErrorInfo((env), &errorInfo);                                                                   \
        bool isPending = false;                                                                                        \
        OH_JSVM_IsExceptionPending((env), &isPending);                                                                 \
        if (!isPending && errorInfo != nullptr) {                                                                      \
            const char *errorMessage =                                                                                 \
                errorInfo->errorMessage != nullptr ? errorInfo->errorMessage : "empty error message";                  \
            OH_JSVM_ThrowError((env), nullptr, errorMessage);                                                          \
        }                                                                                                              \
    } while (0)

#define JSVM_ASSERT_BASE(env, assertion, message, retVal)                                                              \
    do {                                                                                                               \
        if (!(assertion)) {                                                                                            \
            OH_JSVM_ThrowError((env), nullptr, "assertion (" #assertion ") failed: " message);                         \
            return retVal;                                                                                             \
        }                                                                                                              \
    } while (0)

#define JSVM_ASSERT(env, assertion, message) JSVM_ASSERT_BASE(env, assertion, message, nullptr)

#define JSVM_ASSERT_RETURN_VOID(env, assertion, message) JSVM_ASSERT_BASE(env, assertion, message, JSVM_RETVAL_NOTHING)

#define JSVM_CALL_BASE(env, theCall, retVal)                                                                           \
    do {                                                                                                               \
        if ((theCall) != JSVM_OK) {                                                                                    \
            GET_AND_THROW_LAST_ERROR((env));                                                                           \
            return retVal;                                                                                             \
        }                                                                                                              \
    } while (0)

#define JSVM_CALL(env, theCall) JSVM_CALL_BASE(env, theCall, nullptr)

#define NODE_API_CALL(env, the_call) NODE_API_CALL_BASE(env, the_call, NULL)

#define JSVM_CALL_RETURN_VOID(env, theCall) JSVM_CALL_BASE(env, theCall, JSVM_RETVAL_NOTHING)

#define DECLARE_JSVM_PROPERTY(name, val)                                                                               \
    { (name), nullptr, nullptr, nullptr, nullptr, val, napi_default, nullptr }

#define DECLARE_JSVM_STATIC_PROPERTY(name, val)                                                                        \
    { (name), nullptr, nullptr, nullptr, nullptr, val, napi_static, nullptr }

#define DECLARE_JSVM_FUNCTION(name, func)                                                                              \
    { (name), nullptr, (func), nullptr, nullptr, nullptr, napi_default, nullptr }

#define DECLARE_JSVM_FUNCTION_WITH_DATA(name, func, data)                                                              \
    { (name), nullptr, (func), nullptr, nullptr, nullptr, napi_default, data }

#define DECLARE_JSVM_STATIC_FUNCTION(name, func)                                                                       \
    { (name), nullptr, (func), nullptr, nullptr, nullptr, napi_static, nullptr }

#define DECLARE_JSVM_GETTER(name, getter)                                                                              \
    { (name), nullptr, nullptr, (getter), nullptr, nullptr, napi_default, nullptr }

#define DECLARE_JSVM_SETTER(name, setter)                                                                              \
    { (name), nullptr, nullptr, nullptr, (setter), nullptr, napi_default, nullptr }

#define DECLARE_JSVM_GETTER_SETTER(name, getter, setter)                                                               \
    { (name), nullptr, nullptr, (getter), (setter), nullptr, napi_default, nullptr }

#endif /* FOUNDATION_ACE_JSVM_INTERFACES_KITS_JSVM_NATIVE_COMMON_H */