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

import { AVPlayerController } from '../viewmodel/AVPlayerController';

@Component
export struct VideoPlayControl {
  @ObjectLink hlsPlayerController: AVPlayerController;

  build() {
    Image(this.hlsPlayerController.isPlaying ? $r('sys.media.ohos_ic_public_pause') :
    $r('sys.media.ohos_ic_public_play'))
      .width($r('app.float.play_switch_width'))
      .height($r('app.float.play_switch_height'))
      .fillColor(Color.White)
      .onClick(() => {
        if (!this.hlsPlayerController.isPlaying) {
          this.hlsPlayerController.play();
        } else {
          this.hlsPlayerController.pause();
        }
      })
  }
}