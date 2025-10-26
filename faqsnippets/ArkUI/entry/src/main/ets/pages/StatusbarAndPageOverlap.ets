/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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
* FAQ:状态栏与页面内容发生重叠，如何解决
*/

// [Start image_preview_example]
import { window } from '@kit.ArkUI';

@Entry
@Component
struct ImagePreviewExample {
  windowClass: window.Window = AppStorage.get<window.Window>('windowClass') as window.Window;
  @State visible: Visibility = Visibility.None;
  @State scaleValue: number = 1;
  @State pinchValue: number = 1;
  @State pinchX: number = 0;
  @State pinchY: number = 0;
  @State count: number = 0;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State positionX: number = 0;
  @State positionY: number = 0;

  build() {
    Stack() {
      Row() {
        Column() {
          Image($r('app.media.startIcon'))
            .width(100)
            .height(100)
            .onClick(() => {
              if (this.visible === Visibility.Visible) {
                this.visible = Visibility.None;
              } else {
                this.visible = Visibility.Visible;
                this.windowClass.setSpecificSystemBarEnabled('status', false);
              }
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .height('100%')

      Text('')
        .onClick(() => {
          if (this.visible === Visibility.Visible) {
            this.windowClass.setSpecificSystemBarEnabled('status', true);
            this.visible = Visibility.None;
          } else {
            this.visible = Visibility.Visible;
          }
        })
        .width('100%')
        .height('100%')
        .opacity(0.16)// opacity
        .backgroundColor(Color.Black)
        .visibility(this.visible)

      Column() {
        Image($r('app.media.startIcon'))
          .width(300)
          .height(300)
          .draggable(false)
          .visibility(this.visible)
          .scale({
            x: this.scaleValue,
            y: this.scaleValue,
            z: 1
          })
          .translate({
            x: this.offsetX,
            y: this.offsetY,
            z: 0
          })
          .gesture(
            GestureGroup(GestureMode.Parallel,
              PinchGesture({ fingers: 2 })
                .onActionUpdate((event?: GestureEvent) => {
                  if (event) {
                    this.scaleValue = this.pinchValue * event.scale;
                    this.pinchX = event.pinchCenterX;
                    this.pinchY = event.pinchCenterY;
                  }
                })
                .onActionEnd(() => {
                  this.pinchValue = this.scaleValue;
                }),
              PanGesture()
                .onActionUpdate((event?: GestureEvent) => {
                  if (event) {
                    this.offsetX = this.positionX + event.offsetX;
                    this.offsetY = this.positionY + event.offsetY;
                  }
                })
                .onActionEnd(() => {
                  this.positionX = this.offsetX;
                  this.positionY = this.offsetY;
                })
            )
          )
      }
    }
    .backgroundColor(Color.White)
    .height('100%')
    .width('100%')
  }
}
// [End image_preview_example]