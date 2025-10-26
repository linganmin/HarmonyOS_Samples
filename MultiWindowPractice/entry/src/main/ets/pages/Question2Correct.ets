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

import { AVPlayerUtil } from '../common/AVPlayerUtil';

@Builder
export function Question2CorrectBuilder() {
  Question2Correct()
}

// [Start Question2_correct]
@Component
export struct Question2Correct {
  @State aspect: number = 9 / 16; // default video width/height ratio value
  // [StartExclude  Question2_correct]
  private xComponentController: XComponentController = new XComponentController();
  private player?: AVPlayerUtil;

  aboutToDisappear(): void {
    this.player?.stopPlay();
  }
  // [EndExclude  Question2_correct]

  build() {
    NavDestination() {
      Stack() {
        XComponent({ id: 'video_player_id', type: XComponentType.SURFACE, controller: this.xComponentController })
          // [StartExclude  Question2_correct]
          .onLoad(() => {
            this.player = new AVPlayerUtil();
            this.player.setSurfaceId(this.xComponentController.getXComponentSurfaceId());
            this.player.initPlayer('testVideo2.mp4', (aspect: number) => {
              this.aspect = aspect;
            });
          })
            // [EndExclude  Question2_correct]
          .aspectRatio(this.aspect)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }
    // [StartExclude  Question2_correct]
    .hideTitleBar(true)
    // [EndExclude  Question2_correct]
  }
}
// [End Question2_correct]