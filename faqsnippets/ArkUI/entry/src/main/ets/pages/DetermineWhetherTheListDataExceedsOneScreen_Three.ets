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
* FAQ:List控件加载的数据如何判断是否超过一屏
*/

// [Start determine_whether_the_list_data_exceeds_one_screen_three]
@Entry
@Component
struct GetLastGroup {
  private groupItemHeightArr =
    [[30, 50, 60, 40, 90, 80.60],
      [50, 40, 50, 55, 77, 88.44],];
  private listHeight = 700;
  // Scroll controller for obtaining the position information of list items
  scroller = new ListScroller();

  build() {
    Column() {
      Button('Is it more than one screen')
        .height(50)
        .width('100%')
        .onClick(() => {
          let lastGroupIndex = this.groupItemHeightArr.length - 1;
          let lastItemIndex = this.groupItemHeightArr[lastGroupIndex].length - 1;
          let result = this.scroller.getItemRectInGroup(lastGroupIndex, lastItemIndex);
          let flag = result.y + result.height > this.listHeight;
          console.info(flag ? 'More than one screen' : 'Not exceeding one screen')
        })
      List({ scroller: this.scroller }) {
        ForEach(this.groupItemHeightArr, (itemHeight: number[], index: number) => {
          ListItemGroup() {
            ForEach(itemHeight, (height: number) => {
              ListItem() {
                Text(index.toString())
                  .width('100%')
                  .textAlign(TextAlign.Center)
              }
              .height(height)
              .align(Alignment.Center)
            }, (item: number, index: number) => JSON.stringify(item) + index)
          }
        }, (item: number[]) => JSON.stringify(item))
      }
      .height(this.listHeight)
      .width('100%')
    }
  }
}

// [End determine_whether_the_list_data_exceeds_one_screen_three]