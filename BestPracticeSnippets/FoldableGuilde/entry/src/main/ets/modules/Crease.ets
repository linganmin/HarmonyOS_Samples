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

// [Start crease]
import { display } from '@kit.ArkUI';

@Component
export struct Crease {
  @State status: string = '1';

  // Register for monitoring at startup
  aboutToAppear() {
    let callback: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
      console.info('Listening enabled. Data: ' + JSON.stringify(data));
      // Get the folding crease area, the left and top attributes are the left and upper boundaries of the rectangular area, and the width and height attributes are the width and height of the rectangular area。
      this.status = data.toString() + '  ' + display.getCurrentFoldCreaseRegion().creaseRects[0].left + '  ' +
      display.getCurrentFoldCreaseRegion().creaseRects[0].top
        + '  ' + display.getCurrentFoldCreaseRegion().creaseRects[0].width + '  ' +
      display.getCurrentFoldCreaseRegion().creaseRects[0].height;
    };
    try {
      display.on('foldStatusChange', callback);
    } catch (exception) {
      console.error('Failed to register callback. Code: ' + JSON.stringify(exception));
    }
  }

  build() {
    Column() {
      Text(this.status)
        .height(50)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontSize(25)
        .backgroundColor(Color.Red)
    }
    .height('100%')
    .width('100%')
    .borderWidth(1)
    .backgroundColor(Color.Pink)
    .justifyContent(FlexAlign.Start)
  }
}

// [End crease]