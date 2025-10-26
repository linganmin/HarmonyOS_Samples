/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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
* 最佳实践: 应用并发设计 并发任务管理 多任务关联执行（树状依赖）
*/
// [Start updatesab]
import { taskpool } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

// [StartExclude updatesab]
const DOMAIN = 0x0000;
const TAG = 'ConcurrentTaskManagement2';
const FORMAT = '%{public}s';
// [EndExclude updatesab]
@Concurrent
function updateSAB(args: Uint32Array) {
  if (args[0] == 0) {
    args[0] = 100;
    return 100;
  } else if (args[0] == 100) {
    args[0] = 200;
    return 200;
  } else if (args[0] == 200) {
    args[0] = 300;
    return 300;
  }
  return 0;
}

function executeTaskPool() {
  let sab = new SharedArrayBuffer(20);
  let typedArray = new Uint32Array(sab);
  let task1 = new taskpool.Task(updateSAB, typedArray);
  let task2 = new taskpool.Task(updateSAB, typedArray);
  let task3 = new taskpool.Task(updateSAB, typedArray);
  try {
    task1.addDependency(task2);
    task2.addDependency(task3);
  } catch (err) {
    hilog.error(DOMAIN, TAG, FORMAT, `sendData failed. Cause code: ${err.code},message: ${err.message}`);
  }

  taskpool.execute(task1).then((res: object) => {
    hilog.info(DOMAIN, TAG, FORMAT, 'taskpool:: execute task1 res: ' + res);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, FORMAT, `taskpool execute error. Cause code: ${err.code},message: ${err.message}`);
  });

  taskpool.execute(task2).then((res: object) => {
    hilog.info(DOMAIN, TAG, FORMAT, 'taskpool:: execute task2 res: ' + res);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, FORMAT, `taskpool execute error. Cause code: ${err.code},message: ${err.message}`);
  });

  taskpool.execute(task3).then((res: object) => {
    hilog.info(DOMAIN, TAG, FORMAT, 'taskpool:: execute task3 res: ' + res);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, FORMAT, `taskpool execute error. Cause code: ${err.code},message: ${err.message}`);
  });
}

// [End updatesab]

@Component
export struct ConcurrentTaskManagement2 {
  @Styles
  buttonStyles() {
    .width('100%')
    .height(40)
  }

  build() {
    NavDestination() {
      Column() {
        Button($r('app.string.tree_like_dependency_title'))
          .buttonStyles()
          .margin({
            bottom: 16
          })
          .onClick(() => {
            executeTaskPool();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .padding({
        right: 24,
        bottom: 16,
        left: 24
      })
    }
    .title($r('app.string.tree_like_dependency_title'))
  }
}