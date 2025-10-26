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

import { BusinessError } from '@kit.BasicServicesKit';
import { ProducerConsumerPage } from '../producerConsumer/ProducerConsumerPage';
import { DownLoadFilePage } from '../downLoadFilePage/DownLoadFilePage';
import { Constants } from '../constants/Constants';
import Logger from '../utils/Logger';

@Entry
@Component
struct Index {
  private pageStack: NavPathStack = new NavPathStack();

  @Styles
  buttonStyles() {
    .width(Constants.FULL_PERCENT)
    .height($r('app.integer.comm_button_height'))
  }

  @Builder
  pageMap(pageName: string): void {
    if (pageName === 'DownLoadFilePage') {
      DownLoadFilePage()
    } else if (pageName === 'ProducerConsumerPage') {
      ProducerConsumerPage()
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Button($r('app.string.sendable_thread_share'))
          .buttonStyles()
          .margin({
            bottom: $r('app.integer.comm_padding_margin12')
          })
          .onClick(() => {
            this.pageStack.pushDestinationByName('DownLoadFilePage', null, true).catch((err: BusinessError) => {
              Logger.error(`pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
            });
          })

        Button($r('app.string.producer_consumer_model'))
          .buttonStyles()
          .margin({
            bottom: $r('app.integer.comm_padding_margin16')
          })
          .onClick(() => {
            this.pageStack.pushDestinationByName('ProducerConsumerPage', null, true).catch((err: BusinessError) => {
              Logger.error(`pushDestinationByName failed. Code: ${err.code}, message: ${err.message}`);
            });
          })
      }
      .width(Constants.FULL_PERCENT)
      .height(Constants.FULL_PERCENT)
      .justifyContent(FlexAlign.End)
      .padding({
        right: $r('app.integer.comm_padding_margin24'),
        left: $r('app.integer.comm_padding_margin24')
      })
    }
    .title($r('app.string.use_sendable'))
    .navDestination(this.pageMap)
    .hideToolBar(true)
  }
}