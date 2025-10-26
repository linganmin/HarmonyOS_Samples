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
* 最佳实践: 应用并发设计 线程间通信 跨语言多线程通信（C++与ArkTS）
*/
// [Start inter_thread_communication1]
import { hilog } from '@kit.PerformanceAnalysisKit';
import nativeModule from 'libentry.so';
// [StartExclude inter_thread_communication1]
const DOMAIN = 0x0000;
const TAG = 'InterThreadCommunication1';
const FORMAT = '%{public}s';
// [EndExclude inter_thread_communication1]
@Component
export struct InterThreadCommunication1 {
  build() {
    NavDestination() {
      Column() {
        Button($r('app.string.multithreaded_communication_title'))
          .width('100%')
          .onClick(() => {
            nativeModule.nativeCall((a: number) => {
              hilog.info(DOMAIN, TAG, FORMAT, 'Received data from thread-function: %{public}d', a);
            })
            hilog.info(DOMAIN, TAG, FORMAT, `click nativeCall success`);
          })
      }
      // [StartExclude inter_thread_communication1]
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Center)
      .padding({
        right: 24,
        bottom: 32,
        left: 24
      })
      // [EndExclude inter_thread_communication1]
    }
    .title($r('app.string.multithreaded_communication_title'))
  }
}
// [End inter_thread_communication1]