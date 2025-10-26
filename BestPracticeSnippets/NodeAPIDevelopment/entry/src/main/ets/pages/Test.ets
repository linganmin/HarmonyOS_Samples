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
 *Node-API开发规范
 */
// [Start create_my_external]
// application code
import testNapi from 'libentry.so';
import { worker } from '@kit.ArkTS';

const mWorker = new worker.ThreadWorker('../workers/Worker');

{
  const mExternalObj = testNapi.createMyExternal();

  mWorker.postMessage(mExternalObj);

}

// Close the worker thread
// The application may crash at this step or during subsequent engine GC
mWorker.terminate();
// The implementation of Worker is the default template, omitted here
// [End create_my_external]