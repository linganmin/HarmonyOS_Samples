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
* 最佳实践: 应用并发设计 并发任务管理 多任务关联执行（串行顺序依赖）
*/
// [Start seq_runner]
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { taskpool } from '@kit.ArkTS';
// [StartExclude seq_runner]
const DOMAIN = 0x0000;
const TAG = 'ConcurrentTaskManagement1';
const FORMAT = '%{public}s';
// [EndExclude seq_runner]
@Concurrent
function additionDelay(delay: number): void {
  let start: number = new Date().getTime();
  while (new Date().getTime() - start < delay) {
    continue;
  }
}

@Concurrent
function waitForRunner(resString: string): string {
  return resString;
}

async function seqRunner() {
  let result: string = '';
  let task1: taskpool.Task = new taskpool.Task(additionDelay, 300);
  let task2: taskpool.Task = new taskpool.Task(additionDelay, 200);
  let task3: taskpool.Task = new taskpool.Task(additionDelay, 100);
  let task4: taskpool.Task = new taskpool.Task(waitForRunner, 50);

  let runner: taskpool.SequenceRunner = new taskpool.SequenceRunner();
  runner.execute(task1).then(() => {
    result += 'a';
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, FORMAT, `taskpool execute error. Cause code: ${err.code},message: ${err.message}`);
  });

  runner.execute(task2).then(() => {
    result += 'b';
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, FORMAT, `taskpool execute error. Cause code: ${err.code},message: ${err.message}`);
  });

  runner.execute(task3).then(() => {
    result += 'c';
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, FORMAT, `taskpool execute error. Cause code: ${err.code},message: ${err.message}`);
  });

  await runner.execute(task4).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, FORMAT, `taskpool execute error. Cause code: ${err.code},message: ${err.message}`);
  });
  hilog.info(DOMAIN, TAG, FORMAT, 'SequenceRunner: result is :' + result);
}
// [End seq_runner]

@Component
export struct ConcurrentTaskManagement1 {
  @Styles
  buttonStyles() {
    .width('100%')
    .height(40)
  }

  build() {
    NavDestination() {
      Column() {
        Button($r('app.string.multitasking_title'))
          .buttonStyles()
          .margin({
            bottom: 16
          })
          .onClick(() => {
            seqRunner();
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
    .title($r('app.string.multitasking_title'))
  }
}