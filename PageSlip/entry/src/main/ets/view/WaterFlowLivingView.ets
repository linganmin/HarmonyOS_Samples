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

import { CommonConstants } from '../constants/CommonConstants';
import { WaterFlowDescriptionView } from './WaterFlowDescriptionView';
import { componentUtils } from '@kit.ArkUI';

@Component
@Reusable
export struct WaterFlowLivingView {
  @State source: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State thumbnails: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State currentBreakpoint: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State windowsHeight: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @State title: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State userImage: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State userName: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State collectionsCount: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @State type: string = CommonConstants.WATER_FLOW_LIVING_TYPE;
  @State vipSign: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State itemIndex: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @Link waterFlowItemWidth: number;
  @State livingWidth: number = 0;
  @State livingHeight: number = 0;
  videoController: VideoController = new VideoController();

  aboutToReuse(params: Record<string, object>): void {
    if (typeof params.itemIndex === 'number') {
      this.itemIndex = params.itemIndex;
    }
    if (typeof params.source === 'string') {
      this.source = params.source;
    }
    if (typeof params.thumbnails === 'string') {
      this.thumbnails = params.thumbnails;
    }
    if (typeof params.title === 'string') {
      this.title = params.title;
    }
    if (typeof params.userImage === 'string') {
      this.userImage = params.userImage;
    }
    if (typeof params.vipSign === 'string') {
      this.vipSign = params.vipSign;
    }
    if (typeof params.userName === 'string') {
      this.userName = params.userName;
    }
    if (typeof params.type === 'string') {
      this.type = params.type;
    }
    if (typeof params.collectionsCount === 'number') {
      this.collectionsCount = params.collectionsCount;
    }
    if (typeof params.livingWidth === 'number') {
      this.livingWidth = params.livingWidth;
    }
    if (typeof params.livingHeight === 'number') {
      this.livingHeight = params.livingHeight;
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Video({ src: this.source, previewUri: this.thumbnails, controller: this.videoController })
          .id(CommonConstants.WATER_FLOW_LIVING_STRUCT_ID + this.itemIndex)
          .controls(false)
          .muted(true)
          .loop(true)
          .width($r('app.string.full_screen'))
          .height(this.livingHeight / this.livingWidth * this.waterFlowItemWidth)
          .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
            if (isVisible && currentRatio >= 1.0) {
              this.videoController.start();
            } else {
              this.videoController.pause();
            }
          })
          .onAppear(() => {
            let videoPos =
              this.getUIContext().getComponentUtils().getRectangleById(CommonConstants.WATER_FLOW_LIVING_STRUCT_ID + this.itemIndex);
            if (this.getUIContext().px2vp(videoPos.windowOffset.y) + this.getUIContext().px2vp(videoPos.size.height) < this.windowsHeight) {
              setTimeout(() => {
                this.videoController.start();
              }, 1000);
            }
          });
        Row() {
          Image($r('app.media.arrow_right_living_play'))
            .width($r('app.float.live_view_image_size'))
            .height($r('app.float.live_view_image_size'));
        }
        .margin($r('app.float.live_view_image_margin'))
        .zIndex(1);
      };

      WaterFlowDescriptionView({
        title: this.title,
        userImage: this.userImage,
        userName: this.userName,
        type: this.type,
        collectionsCount: this.collectionsCount,
        vipSign: this.vipSign
      })
    }
    .width($r('app.string.full_screen'))
    .height($r('app.string.full_screen'));
  }
}
