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

@Component
export struct CarControlView {
  @State isWindowOpen: boolean = false;
  @Link pathStack: NavPathStack;

  @Builder
  buttonBuilder(imageResource: Resource | undefined, clickMethod: () => void, buttonName: ResourceStr) {
    Column() {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        if (imageResource !== undefined) {
          Image(imageResource)
            .width(30)
            .height(30)
        } else {
          Text('24℃')
            .fontSize(15)
            .fontColor('#ffffffff')
        }
      }
      .width(55)
      .height(55)
      .backgroundColor('#40ffffff')
      .onClick(() => {
        clickMethod();
      })

      Text(buttonName)
        .fontSize(13)
        .fontColor($r('sys.color.font_on_secondary'))
        .margin({ top: 5 })
    }
  }

  build() {
    Column() {
      Text($r('app.string.car_control'))
        .fontSize(19)
        .fontWeight(700)
        .fontColor($r('sys.color.white'))
        .margin({ top: 20 })
      Row() {
        this.buttonBuilder($r('app.media.lock'), () => {
          this.pathStack.pushPathByName('SafeCodePage', null);
        }, $r('app.string.car_lock'));

        Column() {
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Image($r('app.media.window'))
              .width(30)
              .height(30)
          }
          .width(55)
          .height(55)
          .backgroundColor(this.isWindowOpen ? '#1F69FF' : '#40ffffff')
          .onClick(() => {
            this.isWindowOpen = !this.isWindowOpen;
          })

          Text($r('app.string.car_window'))
            .fontSize(12)
            .fontColor('#ff838282')
            .margin({ top: 5 })
        }

        this.buttonBuilder(undefined, () => {
          this.pathStack.pushPathByName('ConditionerPage', null);
        }, $r('app.string.car_conditioner'));
      }
      .width('90%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ top: 20 })

      Row() {
        this.buttonBuilder($r('app.media.trunk_open'), () => {
          this.pathStack.pushPathByName('TrunkPage', null);
        }, $r('app.string.car_trunk'));

        this.buttonBuilder($r('app.media.find_car'), () => {
          this.pathStack.pushPathByName('FindCarPage', null);
        }, $r('app.string.find_car'));
      }
      .width('70%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 5 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}