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

// [Start determine_whether_the_list_data_exceeds_one_screen_one]
@Entry
@Component
struct AllListItemHeight {
  private itemHeightArr = [100, 150, 200, 130, 120, 110.130];
  private listHeight = 700;
  scroller = new ListScroller();


  build() {
    Column() {
      Button('Is it more than one screen')
        .height(50)
        .width('100%')
        .onClick(() => {
          let result = 0;
          for (let i = 0; i < this.itemHeightArr.length; i++) {
            result += this.itemHeightArr[i];
          }
          console.info(result > this.listHeight ? 'More than one screen' : 'Not exceeding one screen');
        })
      List({ scroller: this.scroller }) {
        ForEach(this.itemHeightArr, (_: number, index: number) => {
          ListItem() {
            Text(index.toString())
              .width('100%')
              .textAlign(TextAlign.Center)
          }
          .height(this.itemHeightArr[index])
          .align(Alignment.Center)
        }, (item: number) => JSON.stringify(item))
      }
      .height(this.listHeight)
      .width('100%')
    }
  }
}
// [End determine_whether_the_list_data_exceeds_one_screen_one]