/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// [Start PinchImage]
@Component
export struct PinchImage {
  list: string[] = ['image1', 'image2', 'image3', 'image4', 'image5', 'image6'];
  @State GridColumn: string = '1fr 1fr 1fr';
  @State GridRow: string = '1fr 1fr';

  build() {
    Column() {
      Grid() {
        ForEach(this.list, (item: string) => {
          GridItem() {
            Text(item)
          }.backgroundColor(Color.Grey)
        }, (item: string) => item)
      }
      .columnsTemplate(this.GridColumn)
      .rowsTemplate(this.GridRow)
      .rowsGap(12)
      .columnsGap(12)
    }
    // Change the layout of the Grid when two-finger scaling is triggered
    .gesture(PinchGesture({ fingers: 2 }).onActionUpdate((event: GestureEvent) => {
      if (event.scale > 1) {
        // Increase animation effect
        this.getUIContext().animateTo({
          duration: 500
        }, () => {
          // When the two-finger scaling ratio is > 1, the number of Grid columns becomes 2
          this.GridColumn = '1fr 1fr';
        })
      } else {
        this.getUIContext().animateTo({
          duration: 500
        }, () => {
          // When the two-finger scaling ratio is < =1, the number of Grid columns becomes 3
          this.GridColumn = '1fr 1fr 1fr';
        })
      }
    }))
  }
}

// [End PinchImage]