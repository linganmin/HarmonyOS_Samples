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

@Component
export struct SourceView {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: number = WidthBreakpoint.WIDTH_SM;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: number = HeightBreakpoint.HEIGHT_SM;

  build() {
    Column() {
      // [Start small_window_way_1]
      Image($r('app.media.icon_arrow_right'))
        .height(this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_SM &&
          this.currentHeightBreakpoint === HeightBreakpoint.HEIGHT_MD ? 24 : 48)
        .aspectRatio(1)
      // [End small_window_way_1]

      // [Start small_window_way_2]
      // Scheme No.1
      Column() {
        // What the small window layout shows
      }
      .visibility(this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_SM &&
        this.currentHeightBreakpoint === HeightBreakpoint.HEIGHT_MD ? Visibility.Visible :
      Visibility.None)

      // Scheme No.2
      if (this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_SM &&
        this.currentHeightBreakpoint === HeightBreakpoint.HEIGHT_MD) {
        Column() {
          // What the small window layout shows
        }
      }
      // [End small_window_way_2]
    }
    .width('100%')
    .height('100%')
  }
}