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

import { EdgeBlur } from '../pages/EdgeBlur';
import { LoopScrolling } from '../pages/LoopScrolling';
import { MaintainVisibleAreaContent } from '../pages/MaintainVisibleAreaContent';
import { PullUpLoading } from '../pages/PullUpLoading';
import { RollingMonitoring } from '../pages/RollingMonitoring';
import { ScrollLeftAndRightToRefresh } from '../pages/ScrollLeftAndRightToRefresh';
import { ScrollToTheBottom } from '../pages/ScrollToTheBottom';
import { UnilateralRebound } from '../pages/UnilateralRebound';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string, param: string) {
    if (name === 'EdgeBlur') {
      EdgeBlur()
    } else if (name === 'LoopScrolling') {
      LoopScrolling()
    } else if (name === 'MaintainVisibleAreaContent') {
      MaintainVisibleAreaContent()
    } else if (name === 'PullUpLoading') {
      PullUpLoading()
    } else if (name === 'RollingMonitoring') {
      RollingMonitoring()
    } else if (name === 'ScrollLeftAndRightToRefresh') {
      ScrollLeftAndRightToRefresh()
    } else if (name === 'ScrollToTheBottom') {
      ScrollToTheBottom()
    } else if (name === 'UnilateralRebound') {
      UnilateralRebound()
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Column({ space: 12 }) {
          Button('EdgeBlur')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('EdgeBlur', '');
            })

          Button('LoopScrolling')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('LoopScrolling', '');
            })

          Button('MaintainVisibleAreaContent')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('MaintainVisibleAreaContent', '');
            })

          Button('PullUpLoading')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('PullUpLoading', '');
            })

          Button('RollingMonitoring')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('RollingMonitoring', '');
            })

          Button('ScrollLeftAndRightToRefresh')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('ScrollLeftAndRightToRefresh', '');
            })

          Button('ScrollToTheBottom')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('ScrollToTheBottom', '');
            })

          Button('UnilateralRebound')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .margin({ bottom: 16 })
            .onClick(() => {
              this.pageInfos.pushPathByName('UnilateralRebound', '');
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16
      })
      .justifyContent(FlexAlign.End)
    }
    .title('Simple ChatList')
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
    .navDestination(this.PageMap)
  }
}