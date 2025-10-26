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

// [Start GridRowSample2]
@Entry
@Component
struct GridRowSample2 {
  @State currentBreakpoint: string = 'md';

  build() {
    // Users can adjust the width of the sidebar and content area by dragging the divider in the sidebar component.
    SideBarContainer(SideBarContainerType.Embed) {
      // Sidebar, with a resizable range of [100vp, 600vp].
      Column() {
      }
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_secondary'))

       // Content area.
      GridRow({
        breakpoints: {
          value: ['320vp', '600vp', '840vp', '1440vp'],
          reference: BreakpointsReference.ComponentSize
        }
      }) {
        GridCol({
          span: {
            xs: 12,
            sm: 12,
            md: 12,
            lg: 12,
            xl: 12
          }
        }) {
          Row() {
            Text(this.currentBreakpoint)
              .fontSize(50)
              .fontWeight(FontWeight.Bolder)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }
      }
      .onBreakpointChange((currentBreakpoint: string) => {
        this.currentBreakpoint = currentBreakpoint;
      })
      .width('100%')
    }
    // The sidebar does not auto-hide when dragged to its minimum width.
    .autoHide(false)
    .sideBarWidth(100)
    // Minimum width of the sidebar.
    .minSideBarWidth(100)
    // Maximum width of the sidebar.
    .maxSideBarWidth(600)
  }
}
// [End GridRowSample2]