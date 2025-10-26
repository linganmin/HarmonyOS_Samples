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
* FAQ:如何设置分组列表的圆角和间距
*/

// [Start set_rounded_corners_and_spacing]
// xxx.ets
@Entry
@Component
struct ListItemGroupExample {
  private timeTable: TimeTable[] = [
    { projects: ['language'] },
    { projects: ['mathematics', 'English'] },
    { projects: ['physics', 'chemistry', 'biology'] },
    { projects: ['the fine arts', 'music', 'sport'] }
  ]

  build() {
    Column() {
      List({ space: 20 }) { // Set the spacing of the grouping list
        ForEach(this.timeTable, (item: TimeTable) => {
          ListItemGroup({ style: ListItemGroupStyle.CARD }) { // Set the rounded corners of the grouping list
            ForEach(item.projects, (project: string) => {
              ListItem() {
                Text(project)
                  .width("100%")
                  .height(100)
                  .fontSize(20)
                  .textAlign(TextAlign.Center)
                  .backgroundColor(0xFFFFFF)
              }
            }, (item: string) => item)
          }
        })
      }
      .width('90%')
      .sticky(StickyStyle.Header | StickyStyle.Footer)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
    .padding({ top: 5, bottom: 5 })
  }
}

interface TimeTable {
  projects: string[];
}
// [End set_rounded_corners_and_spacing]