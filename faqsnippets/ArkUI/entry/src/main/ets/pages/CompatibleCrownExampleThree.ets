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
* FAQ: arcSwiper如何适配表冠
*/

// [Start compatible_crown_example_three]
@Entry
@Component
struct Index {
  private arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  @State isLoading: boolean = true;

  onPageShow(): void {
    setTimeout(() => {
      this.isLoading = false;
    }, 3000)
  }

  build() {
    Column() {
      if (this.isLoading) {
        Text('数据加载中')
      } else {
        List({ space: 20, initialIndex: 0 }) {
          ForEach(this.arr, (item: number) => {
            ListItem() {
              Button('' + item)
                .width('100%')
                .height(100)
                .fontSize(16)
            }
            .onClick(() => {
            })
          }, (item: string) => item)
        }
        .onAppear(() => {
          try {
            this.getUIContext().getFocusController().requestFocus('test');
          } catch (error) {
            console.error('requestFocus failed code is ' + error.code + 'message is ' + error.message);
          }
        })
        .id('test')
        .focusable(true)
        .defaultFocus(true)
        .focusOnTouch(true) // After the list component is focused, it can respond to the sliding control of the rotating crown
        .width('90%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
    .padding({ top: 5 })
  }
}

// [End compatible_crown_example_three]