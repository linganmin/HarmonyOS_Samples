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

import { CreateIDComponent } from '../view/CreateIDComponent';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string, param: string) {
    CreateIDComponent({ typeId: param })
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Column({ space: 12 }) {
          Button($r('app.string.ODID'))
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('default', 'ODID');
            })

          Button($r('app.string.AAID'))
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('default', 'AAID');
            })

          Button($r('app.string.OAID'))
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .margin({ bottom: 16 })
            .onClick(() => {
              this.pageInfos.pushPathByName('default', 'OAID');
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
    .title($r('app.string.Title'))
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
    .navDestination(this.PageMap)
  }
}