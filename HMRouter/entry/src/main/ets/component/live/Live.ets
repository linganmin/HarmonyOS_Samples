/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { CommonConstants } from '../common/constants/CommonConstants';
import { CommentInput } from './CommentInput';
import { LiveMaskLayer } from './LiveMaskLayer';
import { LiverHeader } from './LiverHeader';
import { LiveVideo } from './LiveVideo';

@Component
export struct Live {
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @Prop currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Link detailType: string;
  @Link isMoreDetail: boolean;

  build() {
    Column() {
      Stack({alignContent: Alignment.TopStart}) {
        Column() {
          LiveVideo();
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);

        Column() {
          LiverHeader();
          LiveMaskLayer({
            currentBreakpoint: this.currentBreakpoint,
            detailType: this.detailType,
            isMoreDetail: this.isMoreDetail
          });
        }
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .width(CommonConstants.FULL_PERCENT)
      .height('90%');

      CommentInput();
    }
    .backgroundColor($r('app.color.live_background_color'))
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}