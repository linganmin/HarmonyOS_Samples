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

@Component
@Reusable
export struct WaterFlowVideoView {
  @State source: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State thumbnails: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State playStatus: boolean = false;
  @State currentBreakpoint: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State title: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State userImage: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State userName: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State collectionsCount: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @State type: string = CommonConstants.WATER_FLOW_VIDEO_TYPE;
  @State vipSign: string = CommonConstants.STRING_DEFAULT_VALUE;
  @Link waterFlowItemWidth: number;
  @State videoWidth: number = 0;
  @State videoHeight: number = 0;

  aboutToReuse(params: Record<string, string>): void {
    this.thumbnails = params.thumbnails;
    this.title = params.title;
    this.videoWidth = parseInt(params.videoWidth, CommonConstants.NUMBER_DEFAULT_VALUE);
    this.videoHeight = parseInt(params.videoHeight, CommonConstants.NUMBER_DEFAULT_VALUE);
    this.userImage = params.userImage;
    this.userName = params.userName;
    this.type = params.type;
    this.vipSign = params.vipSign;
    this.collectionsCount = parseInt(params.collectionsCount, CommonConstants.NUMBER_DEFAULT_VALUE);
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(this.thumbnails)
          .alt($r('app.media.default_image'))
          .width($r('app.string.full_screen'))
          .height(this.videoHeight / this.videoWidth * this.waterFlowItemWidth);
        Row() {
          if (!this.playStatus) {
            Image($r('app.media.arrow_right_play'))
              .width($r('app.float.arrow_size'))
              .height($r('app.float.arrow_size'));
          }
        }
        .margin($r('app.float.margin_10'))
        .zIndex(CommonConstants.LARGE_INDEX);
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