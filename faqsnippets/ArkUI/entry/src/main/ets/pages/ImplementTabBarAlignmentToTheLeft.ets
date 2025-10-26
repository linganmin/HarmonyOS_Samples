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
* FAQ:如何实现Tabs组件的TabBar居左对齐
*/

// [Start implement_tabBar_alignment_to_the_left]
// xxx.ets
@Entry
@Component
struct TabsExample {
  @State tabArray: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  @State focusIndex: number = 0;
  private controller: TabsController = new TabsController();

  build() {
    Column() {
      // Use custom tab components
      Scroll() {
        Row() {
          ForEach(this.tabArray, (item: number, index: number) => {
            Row({ space: 20 }) {
              Text('tab' + item)
                .fontWeight(index === this.focusIndex ? FontWeight.Bold : FontWeight.Normal)
            }
            .padding({ left: 10, right: 10 })
            .onClick(() => {
              this.controller.changeIndex(index);
              this.focusIndex = index;
            })
          })
        }
      }
      .align(Alignment.Start)
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      //The tabs component hides the tab bar
      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        ForEach(this.tabArray, (item: number, index: number) => {
          TabContent() {
            Text('I am the page ' + item + " the content")
              .fontSize(30)
          }
        })
      }.barHeight(0)
    }
    .height('100%')
    .width('100%')
  }
}
// [End implement_tabBar_alignment_to_the_left]