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

/**
 * libuv使用规范及案例
 */
#include "napi/native_api.h"
#include <mutex>
#include <queue>
#include <thread>
#include <uv.h>
#ifndef LIBUVDEVELOPMENT_NAPITASKRUNNER_H
#define LIBUVDEVELOPMENT_NAPITASKRUNNER_H
class Task {};
class ExceptionHandler { };
ExceptionHandler defaultExceptionHandler;

class AbstractTaskRunner{
    public:
    virtual ~AbstractTaskRunner();
    virtual void runAsyncTask(Task&& task) = 0;
    virtual void runSyncTask(Task&& task)  = 0;
    virtual bool isOnCurrentThread() const  = 0;
    virtual void setExceptionHandler (ExceptionHandler handler) = 0;
};

// [Start napi_task_runner]
class NapiTaskRunner : public AbstractTaskRunner {
public:
    NapiTaskRunner (
        napi_env env,
        ExceptionHandler exceptionHandler = defaultExceptionHandler);
    ~NapiTaskRunner() override;
    NapiTaskRunner(const NapiTaskRunner&) = delete;
    NapiTaskRunner& operator=(const NapiTaskRunner&) = delete;
    void runAsyncTask(Task&& task) override;
    void runSyncTask(Task&& task) override;
    bool isOnCurrentThread() const override;
    void setExceptionHandler (ExceptionHandler handler) override;
private:
    napi_env env;
    uv_loop_t* getLoop() const;
    uv_async_t*    asyncHandle;
    std::mutex tasksMutex;
    std::queue<Task> tasksQueue;
    std::thread::id threadId;
    std::condition_variable cv;
    std::shared_ptr<std::atomic_bool> running = std::make_shared<std::atomic_bool>(true);
    ExceptionHandler exceptionHandler;
};


//Constructor code section
NapiTaskRunner::NapiTaskRunner (napi_env env, ExceptionHandler exceptionHandler)
    : env(env), exceptionHandler(std::move (exceptionHandler)) {
    threadId = std::this_thread::get_id();
    auto loop = getLoop() ;
    asyncHandle = new uv_async_t;
    asyncHandle->data = static_cast<void*>(this);
    uv_async_init(loop, asyncHandle, [](auto handle) {});
}


//Destructor section code
NapiTaskRunner::~NapiTaskRunner() {
    running->store(false);
    cv.notify_all();
    uv_close(reinterpret_cast<uv_handle_t*>(asyncHandle), [](uv_handle_t* handle) {
        delete (uv_async_t*)handle;
    });
}
// [End napi_task_runner]


// [Start napi_task_runner_uv_loop]
uv_loop_t* loop;

bool g_done = false;
uv_work_t *work = new uv_work_t;
void ExecuteCB(uv_work_t *work) {
    // Business Logic
}


void CompleteCB(uv_work_t *work, int status) {
    // Business Logic
    if (!g_done) {
        uv_queue_work(work->loop, work, ExecuteCB, CompleteCB);
    } else {
        delete work;
    }
}
// [End napi_task_runner_uv_loop]

void doWork(uv_loop_t* loop, uv_work_t *work) {
    // [Start napi_task_runner_uv_loop]
    uv_queue_work(loop, work, ExecuteCB, CompleteCB);
    // [End napi_task_runner_uv_loop]
} 

#endif //LIBUVDEVELOPMENT_NAPITASKRUNNER_H
