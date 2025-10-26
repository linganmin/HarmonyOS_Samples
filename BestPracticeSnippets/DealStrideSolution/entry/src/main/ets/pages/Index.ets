/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@Entry
@Component
struct Index {
  @State childNavStack: NavPathStack = new NavPathStack();
  @State isShowStridePixel: boolean = false;
  @State imageWidth: number = 1080;
  @State imageHeight: number = 1080;

  @Builder
  ParentTitle() {
    Text($r('app.string.total_title'))
      .width('100%')
      .fontSize(30)
      .fontWeight(700)
      .lineHeight(40)
      .padding({
        left: 12,
        right: 20
      })
      .textAlign(TextAlign.Start)
  }

  build() {
    Navigation(this.childNavStack) {
      Column() {
        this.ParentTitle()
        Column() {
          Button($r('app.string.btn_three'), { stateEffect: true, type: ButtonType.Capsule })
            .width('100%')
            .height(40)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.childNavStack.pushPath({ name: 'pageThree' });
            })
          Button($r('app.string.btn_one'), { stateEffect: true, type: ButtonType.Capsule })
            .width('100%')
            .height(40)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.childNavStack.pushPath({ name: 'pageOne' });
            })
          Button($r('app.string.btn_two'), { stateEffect: true, type: ButtonType.Capsule })
            .width('100%')
            .height(40)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.childNavStack.pushPath({ name: 'pageTwo' });
            })
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        top: 92,
        bottom: 44
      })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor('#F1F1F1')
    .height('100%')
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}