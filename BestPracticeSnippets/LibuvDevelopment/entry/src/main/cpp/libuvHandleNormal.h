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

#ifndef LIBUVDEVELOPMENT_LIBUVHANDLENORMAL_H
#define LIBUVDEVELOPMENT_LIBUVHANDLENORMAL_H
// [Start libuv_handle_normal]
/* Handle representing an event loop */
typedef struct uv_loop_s uv_loop_t;
/* The parent structure of all handles */
typedef struct uv_handle_s uv_handle_t;
/* Handle used to represent timer tasks */
typedef struct uv_timer_s uv_timer_t;
/* Handle used to represent communication between threads */
typedef struct uv_async_s uv_async_t;
// [End libuv_handle_normal]
#endif //LIBUVDEVELOPMENT_LIBUVHANDLENORMAL_H
