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
* FAQ:如何解决List组件在不设置高度的情况下滑动不到底的问题
*/

// [Start list_does_not_set_height]
// xxx.ets
@Entry
@Component
struct ListExample {
  @State arr: string[] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'];
  scroller: Scroller = new Scroller();

  build() {
    Column() {
      RichText('')
        .width('90%')
        .height(300)
        .backgroundColor(0XBDDB69)
      List({ space: 22, initialIndex: 0, scroller: this.scroller }) {
        ForEach(this.arr, (item: string) => {
          ListItem() {
            Text(item)
              .width('100%')
              .height(100)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .borderRadius(10)
              .backgroundColor(0xFFFFFF)
          }
        }, (item: string) => item)
      }
      .layoutWeight(1) // Adaptive occupancy of remaining space
      .listDirection(Axis.Vertical) // Arrangement direction
      .divider({ strokeWidth: 2, color: 0xFFFFFF, startMargin: 20, endMargin: 20 }) // The boundary line between each row
      .edgeEffect(EdgeEffect.Spring) // Sliding to the edge has no effect
      .scrollBar(BarState.Off) // Set scrollbar
      .margin({ top: 20 })
      .width('90%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
  }
}
// [End list_does_not_set_height]