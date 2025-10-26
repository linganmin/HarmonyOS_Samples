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

import { BreakpointConstants } from '../../constants/BreakpointConstants';
import { CommonConstants } from '../../constants/CommonConstants';
import { WaterFlowDescriptionView } from './WaterFlowDescriptionView';

@Component
@Reusable
export struct WaterFlowImageView {
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @Link waterFlowItemWidth: number;
  @State source: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State title: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State titleEn: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State userImage: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State userName: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State collectionsCount: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @State type: string = CommonConstants.WATER_FLOW_IMAGE_TYPE;
  @State vipSign: string = CommonConstants.STRING_DEFAULT_VALUE;
  @State imageWidth: number = 0;
  @State imageHeight: number = 0;

  aboutToReuse(params: Record<string, string>): void {
    this.source = params.source;
    this.title = params.title;
    this.titleEn = params.titleEn;
    this.userImage = params.userImage;
    this.userName = params.userName;
    this.type = params.type;
    this.vipSign = params.vipSign;
    this.collectionsCount = parseInt(params.collectionsCount, CommonConstants.NUMBER_DEFAULT_VALUE);
    this.imageWidth = parseInt(params.imageWidth, CommonConstants.NUMBER_DEFAULT_VALUE);
    this.imageHeight = parseInt(params.imageHeight, CommonConstants.NUMBER_DEFAULT_VALUE);
  }

  build() {
    Column() {
      Image(this.source)
        .alt($r('app.media.default_image'))
        .width($r('app.string.full_screen'))
        .aspectRatio(this.imageHeight / this.imageWidth)
      WaterFlowDescriptionView({
        title: this.title,
        titleEn: this.titleEn,
        userImage: this.userImage,
        userName: this.userName,
        type: this.type,
        collectionsCount: this.collectionsCount,
        vipSign: this.vipSign
      })
    }
    .width($r('app.string.full_screen'))
  }
}