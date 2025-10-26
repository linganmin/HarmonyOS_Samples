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

import { taskpool } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import napi from 'libpreloadso.so';
import Constants from './Constants';
import { Logger } from './Logger';

/**
 * Enable the taskpool subthread to preload .so files.
 * @param
 * @returns string[] Loaded so library.
 */
@Concurrent
function preloadSO(): string[] {
  return napi.preload(Constants.LIBRARY_PATH_ARRAY);
}

/**
 * Starts the taskpool sub-thread.
 * @param
 * @returns Promise<string[]> Asynchronously return the loaded so library.
 */
export function preloadSOByTaskPool(): void {
  // Use new taskpool.Task () to create a task item and input the task execution function and required parameters.
  const task: taskpool.Task = new taskpool.Task(preloadSO);
  try {
    // Use taskpool.execute to put the function to be executed into the internal task queue of TaskPool for execution.
    taskpool.execute(task, taskpool.Priority.HIGH)
      .then((res: Object) => {
        // Processing after the so library is preloaded.
        Logger.info('PreloadSOByTaskPool：' + JSON.stringify(res));
      })
      .catch((error: BusinessError) => {
        Logger.error('PreloadSOByTaskPool: execute failed, ' + error.toString());
      });
  } catch (err) {
    Logger.error('PreloadSOByTaskPool: execute failed, ' + (err as BusinessError).toString());
  }
}