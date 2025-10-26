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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ConcurrencyCapabilitySelection1 } from './ConcurrencyCapabilitySelection1';
import { ConcurrencyCapabilitySelection2 } from './ConcurrencyCapabilitySelection2';
import { ConcurrentTaskManagement1 } from './ConcurrentTaskManagement1';
import { ConcurrentTaskManagement2 } from './ConcurrentTaskManagement2';
import { ConcurrentTaskManagement3 } from './ConcurrentTaskManagement3';
import { ConcurrentTaskManagement4 } from './ConcurrentTaskManagement4';
import { ConcurrentTaskManagement5 } from './ConcurrentTaskManagement5';
import { InterThreadCommunication1 } from './InterThreadCommunication1';
import { InterThreadCommunication2 } from './InterThreadCommunication2';
import { InterThreadCommunication3 } from './InterThreadCommunication3';
import { InterThreadCommunication4 } from './InterThreadCommunication4';

const DOMAIN = 0x0000;
const TAG = 'Index';
const FORMAT = '%{public}s';

@Entry
@Component
struct Index {
  private pageStack: NavPathStack = new NavPathStack();
  private scroller: Scroller = new Scroller();

  getResourceString(resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = this.getUIContext().getHostContext()?.resourceManager.getStringSync(resource.id) as string;
    } catch (error) {
      hilog.error(DOMAIN, TAG, FORMAT, `getResourceString error. Cause code: ${error.code},message: ${error.message}`);
    }
    return resourceString;
  }

  @Styles
  buttonStyles() {
    .width('100%')
    .height(40)
  }

  @Builder
  pageMap(pageName: string): void {
    if (pageName === 'ConcurrencyCapabilitySelection1') {
      ConcurrencyCapabilitySelection1()
    } else if (pageName === 'ConcurrencyCapabilitySelection2') {
      ConcurrencyCapabilitySelection2()
    } else if (pageName === 'ConcurrentTaskManagement1') {
      ConcurrentTaskManagement1()
    } else if (pageName === 'ConcurrentTaskManagement2') {
      ConcurrentTaskManagement2()
    } else if (pageName === 'ConcurrentTaskManagement3') {
      ConcurrentTaskManagement3()
    } else if (pageName === 'ConcurrentTaskManagement4') {
      ConcurrentTaskManagement4()
    } else if (pageName === 'ConcurrentTaskManagement5') {
      ConcurrentTaskManagement5()
    } else if (pageName === 'InterThreadCommunication1') {
      InterThreadCommunication1()
    } else if (pageName === 'InterThreadCommunication2') {
      InterThreadCommunication2()
    } else if (pageName === 'InterThreadCommunication3') {
      InterThreadCommunication3()
    } else if (pageName === 'InterThreadCommunication4') {
      InterThreadCommunication4()
    }
  }

  build() {
    Navigation(this.pageStack) {
      Scroll(this.scroller) {
        Column() {
          Button($r('app.string.time_consuming_task_title'))
            .buttonStyles()
            .margin({
              bottom: 12
            })
            .onClick(() => {
              this.pageStack.pushDestinationByName('ConcurrencyCapabilitySelection1', null, true)
                .catch((err: BusinessError) => {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
                });
            })

          Button($r('app.string.long_term_task_title'))
            .buttonStyles()
            .margin({
              bottom: 12
            })
            .onClick(() => {
              this.pageStack.pushDestinationByName('ConcurrencyCapabilitySelection2', null, true)
                .catch((err: BusinessError) => {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
                });
            })

          Button($r('app.string.multitasking_title'))
            .buttonStyles()
            .margin({
              bottom: 12
            })
            .onClick(() => {
              this.pageStack.pushDestinationByName('ConcurrentTaskManagement1', null, true)
                .catch((err: BusinessError) => {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
                });
            })

          Button($r('app.string.tree_like_dependency_title'))
            .buttonStyles()
            .margin({
              bottom: 12
            })
            .onClick(() => {
              this.pageStack.pushDestinationByName('ConcurrentTaskManagement2', null, true)
                .catch((err: BusinessError) => {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
                });
            })

          Button($r('app.string.task_set_title'))
            .buttonStyles()
            .margin({
              bottom: 12
            })
            .onClick(() => {
              this.pageStack.pushDestinationByName('ConcurrentTaskManagement3', null, true)
                .catch((err: BusinessError) => {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
                });
            })

          Button($r('app.string.priority_scheduling_title'))
            .buttonStyles()
            .margin({
              bottom: 12
            })
            .onClick(() => {
              this.pageStack.pushDestinationByName('ConcurrentTaskManagement4', null, true)
                .catch((err: BusinessError) => {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
                });
            })

          Button($r('app.string.task_delay_scheduling_title'))
            .buttonStyles()
            .margin({
              bottom: 12
            })
            .onClick(() => {
              this.pageStack.pushDestinationByName('ConcurrentTaskManagement5', null, true)
                .catch((err: BusinessError) => {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
                });
            })


          Button($r('app.string.multithreaded_communication_title'))
            .buttonStyles()
            .margin({
              bottom: 12
            })
            .onClick(() => {
              this.pageStack.pushDestinationByName('InterThreadCommunication1', null, true)
                .catch((err: BusinessError) => {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
                });
            })

          Button($r('app.string.singleton_pattern_title'))
            .buttonStyles()
            .margin({
              bottom: 12
            })
            .onClick(() => {
              this.pageStack.pushDestinationByName('InterThreadCommunication2', null, true)
                .catch((err: BusinessError) => {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
                });
            })
          Button($r('app.string.singleton_solution_two_title'))
            .buttonStyles()
            .margin({
              bottom: 12
            })
            .onClick(() => {
              this.pageStack.pushDestinationByName('InterThreadCommunication3', null, true)
                .catch((err: BusinessError) => {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
                });
            })
          Button($r('app.string.immutable_data_sharing_title'))
            .buttonStyles()
            .margin({
              bottom: 32
            })
            .onClick(() => {
              this.pageStack.pushDestinationByName('InterThreadCommunication4', null, true)
                .catch((err: BusinessError) => {
                  hilog.error(DOMAIN, TAG, FORMAT,
                    `pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
                });
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
        .padding({
          right: 24,
          left: 24
        })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .margin({ top: 28 })
    .title('UseSendable')
    .navDestination(this.pageMap)
    .hideToolBar(true)
  }
}