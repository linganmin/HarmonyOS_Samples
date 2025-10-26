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
* FAQ:如何实现Scroll、List单边回弹效果
*/

// [Start scroll_list_unilateral_rebound_effect]
// Single side rebound effect of Scroll component
@Entry
@Component
struct ScrollSideRebound {
  @State yOffset: number = 0;
  scroller: Scroller = new Scroller();
  private arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];


  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Scroll(this.scroller) {
        Column() {
          ForEach(this.arr, (item: number) => {
            Text(item.toString())
              .width('90%')
              .height(150)
              .backgroundColor(0xFFFFFF)
              .borderRadius(15)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .margin({ top: 10 })
          }, (item: string) => item)
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical) // Rolling direction vertically
      .scrollBar(BarState.On) // Scroll bar permanent display
      .scrollBarColor(Color.Gray) // Scroll bar color
      .scrollBarWidth(2) // Scroll bar width
      .friction(0.6)
      .edgeEffect(this.yOffset <= 0 ? EdgeEffect.Spring : EdgeEffect.None) // Rebound after rolling to the edge
      .onDidScroll(() => {
        this.yOffset = this.scroller.currentOffset().yOffset;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
  }
}
// [End scroll_list_unilateral_rebound_effect]