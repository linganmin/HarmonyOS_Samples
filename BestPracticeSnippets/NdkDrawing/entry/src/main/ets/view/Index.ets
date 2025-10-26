/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

// [Start index_view]
import GlassCoverView from './GlassCoverView';

@Entry
@Component
struct Index {
  @State pointsToDraw: number[][] = [];

  /**
   * Make a list of 1000 0-1 positions and draw circles at the corresponding positions
   */
  startDraw(): void {
    this.pointsToDraw = [];
    for (let index = 0; index < 1000; index++) {
      this.pointsToDraw.push([Math.random(), Math.random()]);
    }
  }

  build() {
    Stack() {
      Image($r('app.media.layered_image'))
        .width('100%')
        .height('100%')
      // Transparent circle custom component, in which 1000 transparent circles are drawn
      GlassCoverView({ pointsToDraw: this.pointsToDraw })
        .width('100%')
        .height('100%')
      Row() {
        Button('Begin Draw')
          .width('100%')
          .height(40)
      }
      .padding({
        right: 16,
        bottom: 16,
        left: 16
      })
      .onClick(() => {
        this.startDraw();
      })
    }
    .alignContent(Alignment.Bottom)
    .width('100%')
    .height('100%')
  }
}
// [End index_view]