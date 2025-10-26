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
* FAQ:Grid组件的scrollBar是否支持自定义
*/

// [Start does_rid_support_customization]
@Entry
@Component
struct Index {
  private scroller: Scroller = new Scroller()
  private arr: number[] = [];

  build() {
    Column() {
      Stack({ alignContent: Alignment.End }) {
        Grid(this.scroller) {
          ForEach(this.arr, (item: number) => {
            GridItem() {
              Text(item.toString())
                .width(100)
                .height(50)
                .backgroundColor('#3366CC')
                .borderRadius(15)
                .fontSize(16)
                .textAlign(TextAlign.Center)
            }
          })
        }
        .width('100%')
        .columnsTemplate("1fr 1fr 1fr")
        .columnsGap(5)
        .rowsGap(5)
        // Hide native scrollBar
        .scrollBar(BarState.Off)

        ScrollBar({ scroller: this.scroller, direction: ScrollBarDirection.Vertical, state: BarState.Auto }) {
          Text("A")
            .width(20)
            .height(50)
            .borderRadius(10)
            .backgroundColor('#C0C0C0')
        }
        .width(20)
        .backgroundColor('#ededed')
      }
    }
  }

  aboutToAppear() {
    for (let i = 0; i < 100; i++) {
      this.arr.push(i)
    }
  }
}
// [End does_rid_support_customization]