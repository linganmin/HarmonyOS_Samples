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
import { BasicVideoPlayer } from '../view/BasicVideoPlayer';

@Component
export struct UrlPlayer {
  @Consume('pageStack') pageStack: NavPathStack;
  @State durationTime: number = 0
  @Prop videoData: VideoData;
  @State private avPlayerController: AvPlayerController = new AvPlayerController();


  build() {
    NavDestination() {
      Column() {
        BasicVideoPlayer({
          avPlayerController: this.avPlayerController,
          videoData: this.videoData
        });
      }
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Black)
    .hideBackButton(true)
    .hideToolBar(true)
    .onReady((context: NavDestinationContext) => {
      let param: VideoData = context.pathInfo.param as VideoData;
      this.videoData = param;
    })
  }
}
