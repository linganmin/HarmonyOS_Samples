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
* FAQ:如何实现List的折叠动画效果
*/

// [Start list_collapse_expand]
@Entry
@Component
struct ListCollapseExpand {
  private numberList: number[] = [0, 1, 2, 3, 4, 5, 6];
  @State isContentShow: boolean = true;
  @State selectItem: number = 0;

  build() {
    Column() {
      List({ initialIndex: 0 }) {
        ForEach(this.numberList, (item: number, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Text(item.toString())
                Button(this.isContentShow && this.selectItem === item ? 'Collapse' : 'Expand')
                  .onClick(() => {
                    this.getUIContext().animateTo({
                      duration: 300,
                      onFinish: () => {
                        console.info('animation end');
                      }
                    }, () => {
                      this.isContentShow = !this.isContentShow;
                      this.selectItem = item;
                    })
                  })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              // Display the content area only when the current item is selected and is in an expanded state.
              if (this.isContentShow && this.selectItem === item) {
                Text('This is the content area')
                  .backgroundColor(Color.Gray)
                  .width('100%')
                  .height(100)
              }
            }
            .backgroundColor(0xFFFFFF)
            .width('100%')
            .padding({
              top: 12,
              bottom: 12
            })
            .margin({ top: 10 })
          }
        }, (item: string) => item.toString())
      }
      .scrollBar(BarState.Off)
      .height('100%')
      .width('100%')
    }
    .backgroundColor(0xF1F3F5)
    .padding(12)
  }
}

// [End list_collapse_expand]