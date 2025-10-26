/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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

// [Start gestures_conflictScene1]
@Entry
@Component
struct GesturesConflictScene1 {
  build() {
    Scroll() {
      Column() {
        Column()
          .height('30%')
          .width('100%')
          .backgroundColor(Color.Blue)
        List() {
          ForEach([1, 2, 3, 4, 5, 6], (item: string) => {
            ListItem() {
              Text(item.toString())
                .height(300)
                .fontSize(50)
                .fontWeight(FontWeight.Bold)
            }
          }, (item: number) => item.toString())
        }
        .edgeEffect(EdgeEffect.None)
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST
        })
        .height('100%')
        .width('100%')
      }
    }
    .height('100%')
    .width('100%')
  }
}

// [End gestures_conflictScene1]