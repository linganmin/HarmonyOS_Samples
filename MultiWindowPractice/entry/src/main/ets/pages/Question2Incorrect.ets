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

import { display } from '@kit.ArkUI';
import { AVPlayerUtil } from '../common/AVPlayerUtil';

@Builder
export function Question2IncorrectBuilder() {
  Question2Incorrect()
}
// [Start Question2Incorrect]
@Component
export struct Question2Incorrect {
  @State aspect: number = 9 / 16; // default video height/width ratio value
  @State xComponentWidth: number = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
  @State xComponentHeight: number = this.getUIContext().px2vp(display.getDefaultDisplaySync().width * this.aspect);
  // [StartExclude  Question2Incorrect]
  private xComponentController: XComponentController = new XComponentController();
  private player?: AVPlayerUtil;

  aboutToDisappear(): void {
    this.player?.stopPlay();
  }
  // [EndExclude  Question2Incorrect]

  build() {
    NavDestination() {
      Stack() {
        XComponent({ id: 'video_player_id', type: XComponentType.SURFACE, controller: this.xComponentController })
          // [StartExclude  Question2Incorrect]
          .onLoad(() => {
            this.player = new AVPlayerUtil();
            this.player.setSurfaceId(this.xComponentController.getXComponentSurfaceId());
            this.player.initPlayer('testVideo2.mp4', (aspect: number) => {
              this.aspect = aspect;
              this.xComponentHeight = this.getUIContext().px2vp(display.getDefaultDisplaySync().height);
              this.xComponentWidth = this.getUIContext().px2vp(display.getDefaultDisplaySync().height * aspect);
            });
          })
            // [EndExclude  Question2Incorrect]
          .width(this.xComponentWidth)
          .height(this.xComponentHeight)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }
    .hideTitleBar(true)
  }
}
// [End Question2Incorrect]