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
* FAQ:如何实现上下切换的页面间跳转动画
*/

// [Start realize_adaptive_height]
interface Item {
  text: string
  img: Resource
}

@Entry
@Component
struct Index {
  data: Item[] = [
    { text: 'aaa', img: $r('app.media.app_icon') },
    { text: 'bbb', img: $r('app.media.app_icon') },
    { text: 'ccc', img: $r('app.media.app_icon') },
    { text: 'ddd', img: $r('app.media.app_icon') },
    { text: 'eee', img: $r('app.media.app_icon') },
    { text: 'fff', img: $r('app.media.app_icon') },
    { text: 'ggg', img: $r('app.media.app_icon') },
    { text: 'hhh', img: $r('app.media.app_icon') },
    { text: 'jjj', img: $r('app.media.app_icon') },
    { text: 'kkk', img: $r('app.media.app_icon') }]
  // Calculate the number of rows in the grid
  getCategoryRowCount() {
    return Math.ceil(this.data.length / 4);
  }
  // Calculate the height of the grid based on the height of the item
  getCategoryViewHeight() {
    return `${68.33 * this.getCategoryRowCount()}vp`;
  }

  build() {
    Column() {
      Grid() {
        ForEach(this.data, (item: Item) => {
          GridItem() {
            Column() {
              Image(item.img)
                .width(40)
                .height(40)
              Text(item.text)
                .margin({ top: 2 })
                .fontSize(14)
                .textAlign(TextAlign.Center)
            }
          }
        }, (item: Item) => item.text)
      }
      .height(this.getCategoryViewHeight())
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .margin({ top: 10 })
    }
    .padding(10)
    .width('100%')
  }
}
// [End realize_adaptive_height]