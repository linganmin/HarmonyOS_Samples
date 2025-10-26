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
* FAQ:Scroll中嵌套List，可否设置事件响应顺序，让List不响应滚动事件，让外层的Scroll滚动整个布局?
*/

// [Start the_outer_scroll_scrolls_the_entire_layout]
@Component
export struct ScrollNestingList {
  build() {
    Scroll() {
      Column() {
        Text('This is the title')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        List() {
          ForEach(['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'], (item: string) => {
            ListItem() {
              Text(item)
                .fontSize(50)
                .height(150)
            }
          }, (item: string) => item)
        }
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST, // Triggering the parent scroll first when scrolling down
          scrollBackward: NestedScrollMode.SELF_FIRST  // When scrolling up, the current List is triggered first
        })
        .divider({
          strokeWidth: 1,
          color: Color.Gray
        })
        .edgeEffect(EdgeEffect.None)
        .height('100%')
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
// [End the_outer_scroll_scrolls_the_entire_layout]