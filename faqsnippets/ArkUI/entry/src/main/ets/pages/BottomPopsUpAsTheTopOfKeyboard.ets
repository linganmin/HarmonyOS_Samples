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
* FAQ:输入框拉起键盘时，如何将底部布局弹起到键盘顶部
*/

// [Start bottom_pops_up_as_the_top_of_keyboard]
import { window } from '@kit.ArkUI';

@Entry
struct BottomPopsUpAsTheTopOfKeyboard {
  context = this.getUIContext();
  scroller: Scroller = new Scroller();
  private arr: number[] = [0, 1, 2, 3, 4, 5];
  @State scrollHeight: number = 0;
  @State isRebuild: boolean = false;
  @State keyHeight: number = 0;
  @State text: string = '';
  aboutToAppear() {
    window.getLastWindow(this.context.getHostContext()).then(currentWindow => {
      // Set the layout of the window to immersive layout
      currentWindow.setWindowLayoutFullScreen(true);
      let property = currentWindow.getWindowProperties();
      // Initialize window height
      let avoidArea = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD);
      this.scrollHeight = this.getUIContext().px2vp(property.windowRect.height - avoidArea.bottomRect.height);
      // Monitor the hiding and showing of the soft keyboard
      currentWindow.on('avoidAreaChange', data => {
        if (data.type == window.AvoidAreaType.TYPE_KEYBOARD) {
          this.keyHeight = this.getUIContext().px2vp(data.area.bottomRect.height);
          this.scrollHeight =
            this.getUIContext().px2vp(currentWindow.getWindowProperties().windowRect.height - data.area.bottomRect.height);
          return;
        }
      })
    })
  }
  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Scroll(this.scroller) {
          Column() {
            TextInput({ text: this.text, placeholder: 'input your word...' })
              .placeholderFont({
                size: 14,
                weight: 400
              })
              .width(320)
              .height(40)
              .margin(200)
              .fontSize(14)
              .fontColor(Color.Black)
              .backgroundColor(Color.White)
            ForEach(this.arr, (item: number) => {
              Text(item.toString())
                .width('90%')
                .height(150)
                .backgroundColor(0xFFFFFF)
                .borderRadius(15)
                .fontSize(16)
                .textAlign(TextAlign.Center)
                .margin({ top: 10 })
            })
          }
          .width('100%')
        }
        .width('100%')
        .height(this.scrollHeight)
        .layoutWeight(1)
        Text('This is a test text')
          .width('100%')
          .height(50)
          .backgroundColor(Color.Red)
          .margin({ bottom: this.keyHeight })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
  }
}
// [End bottom_pops_up_as_the_top_of_keyboard]