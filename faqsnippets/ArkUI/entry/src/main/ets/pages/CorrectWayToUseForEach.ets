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
* FAQ:绑定类型的组件和ForEach的正确连用方式
*/

// [Start correct_way_to_use_forEach]
@Entry
@Component
export struct BindSheetAndForEach {
  @State isShow: boolean = false;
  @State arr: number[] = [1, 2, 3, 4];
  @State isSheetVisible: Array<boolean> = new Array<boolean>(this.arr.length).fill(false);



  @Builder
  myBuilder() {
    Column() {
      Button('content1')
        .margin(10)
        .fontSize(20)
    }
    .width('100%')
  }

  // Each array item corresponds to an independent pop-up window displaying the status, which is index bound
  build() {
    Column() {
      ForEach(this.arr, (item: number, idx: number) => {
        Row() {
          Text('item')
          Button('Bullet Frame')
            .onClick(() => {
              this.isSheetVisible[idx] = true;
            })
            .fontSize(15)
            .margin(10)
            .bindSheet(this.isSheetVisible[idx], this.myBuilder(), {
              backgroundColor: Color.Gray,
              height: SheetSize.MEDIUM,
              showClose: true,
              onWillDisappear: () => {
                this.isSheetVisible[idx] = false;
              }
            })
          Checkbox()
        }
        .border({ width: 1, radius: 5 })
      })
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
  }
}

// [End correct_way_to_use_forEach]