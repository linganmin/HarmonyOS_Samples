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
* FAQ:如何将类Java语言的线程模型（内存共享）的实现方式转换成在ArkTS的线程模型下（内存隔离）的实现方式
 */

// [Start run1]
import { taskpool } from '@kit.ArkTS';

@Concurrent
function run(args: number) {
  // Do some independent tasks
}
let task: taskpool.Task = new taskpool.Task(run, 100); // 100: test number
taskpool.execute(task).then((res) => {
  // Return result
});
// [End run1]