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

/*
* Best Practices: Enhancing Performance with Custom Drawing Capabilities
* Use the custom component GlassCoverView to implement a transparent circle. On the homepage, click the "Begin Draw" button to randomly generate a list of 1000 positions ranging from 0 to 1.
*/
// [Start index]
// entry\src\main\ets\pages\Index.ets
import GlassCoverView from '../view/GlassCoverView';

@Entry
@Component
struct Index {
  @State pointsToDraw: number[][] = [];

  /**
   * Generate a list of 1000 random positions between 0 and 1, and draw circles at the corresponding positions.
   */
  startDraw(): void {
    this.pointsToDraw = [];
    for (let index = 0; index < 1000; index++) {
      this.pointsToDraw.push([Math.random(), Math.random()]);
    }
  }

  build() {
    Stack() {
      Image($r('app.media.drawImage'))
        .width('100%')
        .height('100%')
      // "Transparent circle custom component, draw 1000 transparent circles in this component."
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
// [End index]