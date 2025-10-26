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
* FAQ:List组件如何设置两端的渐变效果
*/

// [Start list_setting_gradient_effect]
@Entry
@Component
struct ListExample {
  @State arr: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  private scroller: Scroller = new Scroller()

  build() {
    Stack() {
      List({ space: 10 }) {
        ForEach(this.arr, (item: string) => {
          ListItem() {
            Text("Hello World")
              .width(100)
              .height(64)
              .fontColor(Color.White)
              .backgroundColor(Color.Black)
              .textAlign(TextAlign.Center)
          }
        }, (item: string) => item)
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ top: 20, bottom: 20 })
      .width("80%")
      .height("100%")

      Stack() {

      }
      .linearGradient({
        angle: 90,
        colors: [[0x000000, 0.0], ['rgba(0,0,0,0)', 0.1], ['rgba(0,0,0,0)', 0.9], [0x000000, 1.0]]
      })
      .width("80%")
      .height("100%")
      .hitTestBehavior(HitTestMode.None)
    }.height(100).width('100%').backgroundColor(Color.Black)
  }
}
// [End list_setting_gradient_effect]