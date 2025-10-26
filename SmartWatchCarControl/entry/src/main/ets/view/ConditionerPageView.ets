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

import { CommonConstants } from '../common/constants/CommonConstants'

@Builder
export function conditionerPageBuilder() {
  ConditionerPageView()
}

/**
 * Conditioner Control Page View
 */
@Component
struct ConditionerPageView {
  @State isConditionerOpen: boolean = false;
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Text($r('app.string.temperature'))
          .fontSize(19)
          .fontWeight(700)
          .fontColor($r('sys.color.white'))
          .margin({ top: 20 })
        TextPicker({ range: CommonConstants.TEM_RANGE, selected: 20 })
          .disappearTextStyle({ font: { size: 15 } })
          .textStyle({ font: { size: 15 } })
          .selectedTextStyle({ color: '#5EA1FF', font: { size: 30 } })
          .divider(null)
          .gradientHeight(50)
          .width('100%')
          .height('65%')
          .margin({ top: 5 })
        Stack({ alignContent: Alignment.Top }) {
          Circle({
            width: 250,
            height: 250
          })
            .fill(this.isConditionerOpen ? '#1F69FF' : '#FF838282')
          Text(this.isConditionerOpen ? $r('app.string.close_conditioner') : $r('app.string.open_conditioner'))
            .fontSize(20)
            .fontColor('#FFFFFFFF')
            .margin({
              top: 8,
              left: 6
            })
        }
        .onClick(() => {
          this.isConditionerOpen = !this.isConditionerOpen;
          this.pathStack.pushPathByName('SafeCodePage', null);
        })
      }
      .width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .borderRadius('50%')
    .backgroundColor(Color.Black)
  }
}
