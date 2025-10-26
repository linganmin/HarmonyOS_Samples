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
* 最佳实践: 应用并发设计 线程间通信 线程间不可变数据共享
*/
// [Start globalconfig]
import { hilog } from '@kit.PerformanceAnalysisKit';
import { worker } from '@kit.ArkTS';
import { freezeObj } from './freezeObj';
// [StartExclude globalconfig]
const DOMAIN = 0x0000;
const TAG = 'ConcurrencyCapabilitySelection4';
const FORMAT = '%{public}s';
// [EndExclude globalconfig]
@Sendable
export class GlobalConfig {
  // Some configuration properties and methods
  init() {
    // Initialization-related logic
    freezeObj(this) // Freeze the current object after initialization is completed.
  }
}

function executeTaskPool() {
  try {
    let globalConfig = new GlobalConfig();
    globalConfig.init();
    const workerInstance = new worker.ThreadWorker('entry/ets/workers/Worker.ets`', { name: 'Worker1' });
    workerInstance.postMessage(globalConfig);
    hilog.info(DOMAIN, TAG, FORMAT, `executeTaskPool success`);
  } catch (err) {
    hilog.error(DOMAIN, TAG, FORMAT, `postMessage failed. Cause code: ${err.code},message: ${err.message}`);
  }
}
// [End globalconfig]

@Component
export struct InterThreadCommunication4 {
  @Styles
  buttonStyles() {
    .width('100%')
    .height(40)
  }

  build() {
    NavDestination() {
      Column() {
        Button($r('app.string.immutable_data_sharing_title'))
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
    .title($r('app.string.immutable_data_sharing_title'))
  }
}