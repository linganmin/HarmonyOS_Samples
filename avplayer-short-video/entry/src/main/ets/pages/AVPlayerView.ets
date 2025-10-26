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

import { AvPlayerController } from '../controller/AvPlayerController';
import { VideoData } from '../model/VideoData';
import { VideoPlayer } from '../component/VideoPlayer'

@Component
export struct AVPlayerView {
  @Prop @Watch('onIndexChange') curIndex: number = -1;
  @Prop @Watch('onPageShowWatch') isPageShow: boolean = false;
  public curSource?: VideoData;
  public index: number = 0;
  @State avPlayerController: AvPlayerController = new AvPlayerController();
  private xComponentController: XComponentController = new XComponentController();

  //Video page monitoring function
  // [Start IndexFunc]
  async onIndexChange() {
    if (this.curIndex !== this.index) {
      this.avPlayerController.videoPause();
    } else {
      if (this.avPlayerController.isReady === true) {
        this.avPlayerController.languageChange(AppStorage.get('currentLanguageType'))
        this.avPlayerController.videoPlay();
      }
    }
  }
  // [End IndexFunc]

  onPageShowWatch() {
    if (this.curIndex === this.index) {
      if (!this.isPageShow) {
        this.avPlayerController.videoPause();
      } else {
        this.avPlayerController.videoPlay();
      }
    }
  }

  build() {
    Stack() {
      VideoPlayer({
        avPlayerController: this.avPlayerController,
        videoData: this.curSource,
        xComponentController: this.xComponentController
      })
        .height('100%')
        .width('100%')
    }
  }
}