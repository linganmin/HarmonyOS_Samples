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
 * FAQ:如何利用worker子线程调用napi实现loop改写变量
 */
// [Start worker_call_napi_loop_cpp]
#include "WorkerCallNapiLoop.h" 
#include <thread> 
#include <uv.h> 
 
void WorkerCallNapiLoop::SubThread(CallbackContext *context) { 
    uv_loop_s *loop = nullptr; 
    napi_get_uv_event_loop(context->env, &loop); 
    // Uvw_ork_t is the structure that associates loop and thread pool callback functions
    uv_work_t *work = new uv_work_t; 
    work->data = (CallbackContext *)context; 
    uv_queue_work( 
        loop, work, [](uv_work_t *work) {}, 
        [](uv_work_t *work, int status) { 
            CallbackContext *context = (CallbackContext *)work->data; 
            napi_handle_scope scope = nullptr; 
            // Manage the lifecycle of napi_value to prevent memory leaks
            napi_open_handle_scope(context->env, &scope); 
            if (scope == nullptr) { 
                return; 
            } 
            napi_value callback = nullptr; 
            napi_get_reference_value(context->env, context->callbackRef, &callback); 
            while (context->retData < 100) { 
                context->retData += 1; 
                napi_value retArg; 
                napi_create_int32(context->env, context->retData, &retArg); 
                napi_value ret; 
                napi_call_function(context->env, nullptr, callback, 1, &retArg, &ret); 
                std::this_thread::sleep_for(std::chrono::milliseconds(100)); 
            } 
            napi_close_handle_scope(context->env, scope); 
            if (context->retData > 99) { 
                napi_delete_reference(context->env, context->callbackRef); 
                if (work != nullptr) { 
                    delete work; 
                } 
            } 
        }); 
}; 
napi_value WorkerCallNapiLoop::MainThread(napi_env env, napi_callback_info info) { 
        size_t argc = 1; 
    napi_value args[1] = {0}; 
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); 
    auto asyncContext = new CallbackContext(); 
    asyncContext->env = env; 
    napi_create_reference(env, args[0], 1, &asyncContext->callbackRef); 
    auto func = [](void *asyncContext) { 
        delete asyncContext; 
    }; 
    napi_add_env_cleanup_hook(asyncContext->env, func, asyncContext); 
    uv_loop_s *loop = nullptr; 
    napi_get_uv_event_loop(env, &loop); 
    // Start sub thread 
    std::thread testThread(SubThread, asyncContext); 
    testThread.detach(); 
    return nullptr; 
}
// [End worker_call_napi_loop_cpp]