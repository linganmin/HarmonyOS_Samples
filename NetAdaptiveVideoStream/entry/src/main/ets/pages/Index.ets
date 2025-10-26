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
import { VideoPlayControl } from '../view/VideoPlayControl';
import { VideoProgressBar } from '../view/VideoProgressBar';
import { VideoResolutionSelector } from '../view/VideoResolutionSelector';
import { CustomConfigs } from '../common/CustomConfigs';
import { ViewConstants } from '../common/CommonConstants';
import { VideoPlayInfo } from '../view/VideoPlayInfo';
import { NetInfoViewModel } from '../viewmodel/NetInfoViewModel';

@Entry
@Component
struct Index {
  private xComponentController = new XComponentController();
  @State hlsPlayerController: AVPlayerController = new AVPlayerController();
  @State netInfoViewModel: NetInfoViewModel = new NetInfoViewModel();
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  aboutToAppear(): void {
    this.netInfoViewModel.setAllCallback((netScene) => this.hlsPlayerController.weakNetCallback(netScene));
  }

  aboutToDisappear(): void {
    this.hlsPlayerController.clearAllCallback();
    this.netInfoViewModel.clearAllCallback();
  }

  build() {
    Stack() {
      XComponent({
        id: CustomConfigs.X_COMPONENT_ID,
        type: XComponentType.SURFACE,
        controller: this.xComponentController
      })
        .onLoad(async () => {
          const xComponentId = this.xComponentController.getXComponentSurfaceId();
          await this.hlsPlayerController.initAVPlayer(
            xComponentId, CustomConfigs.MEDIA_SOURCE, CustomConfigs.PLAYBACK_STRATEGY);
        })
        .aspectRatio(ViewConstants.VIDEO_ASPECT_RATIO)

      RelativeContainer() {
        VideoPlayInfo({ hlsPlayerController: this.hlsPlayerController, netInfoViewModel: this.netInfoViewModel })
          .margin({
            left: $r('app.float.info_left_margin'),
            right: $r('app.float.info_right_margin'),
            top: this.topRectHeight
          })
          .alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End },
            top: { anchor: '__container__', align: VerticalAlign.Top },
          })
        VideoProgressBar({ hlsPlayerController: this.hlsPlayerController })
          .margin({
            bottom: $r('app.float.switch_top_margin')
          })
          .alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End },
            bottom: { anchor: 'ResolutionSelector', align: VerticalAlign.Top }
          })
        VideoPlayControl({ hlsPlayerController: this.hlsPlayerController })
          .margin({
            left: $r("app.float.control_left_margin"),
            bottom: $r('app.float.control_bottom_margin')
          })
          .alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          })
        VideoResolutionSelector({ hlsPlayerController: this.hlsPlayerController })
          .id('ResolutionSelector')
          .margin({
            right: $r('app.float.switch_right_margin'),
            bottom: $r('app.float.switch_bottom_margin')
          })
          .alignRules({
            right: { anchor: '__container__', align: HorizontalAlign.End },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          })
      }
    }
    .backgroundColor(Color.Black)
    .height(ViewConstants.FULL_SIZE)
    .width(ViewConstants.FULL_SIZE)
  }
}