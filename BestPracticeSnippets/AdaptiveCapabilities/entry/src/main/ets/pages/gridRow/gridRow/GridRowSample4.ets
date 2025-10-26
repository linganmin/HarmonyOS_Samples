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

// [Start GridRowSample4]
@Entry
@Component
struct GridRowSample4 {
  @State gridMargin: number = 0;

  build() {
    Column() {
      Row()
        .width('100%')
        .height(30)

      // Control the left and right spacing of the grid using padding.
      GridRow() {
        GridCol({ span: { sm: 12, md: 12, lg: 12 } }) {
          Row() {
            Text('padding')
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .height('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.comp_background_secondary'))
        }
      }
      .height(50)
      .borderWidth(2)
      .borderColor('#F1CCB8')
      .padding({
        left: this.gridMargin,
        right: this.gridMargin
      })
      // Configure the left and right spacing values of grid components at different breakpoints using breakpoint change events.
      .onBreakpointChange((currentBreakpoint: string) => {
        if (currentBreakpoint === 'xs' || currentBreakpoint === 'sm') {
          this.gridMargin = 12;
        } else {
          this.gridMargin = 24;
        }
      })

      Row()
        .width('100%')
        .height(30)

      // Control the left and right spacing of the grid using margin.
      GridRow() {
        GridCol({ span: { sm: 12, md: 12, lg: 12 } }) {
          Row() {
            Text('margin')
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .height('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.comp_background_secondary'))
        }
      }
      .height(50)
      .borderWidth(2)
      .borderColor('#F1CCB8')
      .margin({
        left: this.gridMargin,
        right: this.gridMargin
      })
    }
  }
}
// [End GridRowSample4]