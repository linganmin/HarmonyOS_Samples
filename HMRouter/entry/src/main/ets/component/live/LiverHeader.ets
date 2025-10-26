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

import { HMRouterMgr } from '@hadss/hmrouter';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ResourceUtil } from '../common/utils/ResourceUtil';
import { LiveConstants } from '../common/constants/LiveConstants'

@Component
export struct LiverHeader {
  @Prop currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @BuilderParam liveCloseButton: () => void = this.liveCloseBuilder;

  @Builder
  liveCloseBuilder() {
  };

  build() {
    Row() {
      Row() {
        Row() {
          Image($r('app.media.live_vmall'))
            .width($r('app.float.live_store_map_size'))
            .aspectRatio(1)
            .margin({right: $r('app.float.live_store_map_margin')});
          Column() {
            Text(LiveConstants.LIVING_TITLE_TOP)
              .fontSize($r('app.float.store_name_font_size'))
              .fontColor($r('app.color.live_header_font_color'));
            Text(LiveConstants.LIVING_TITLE_BOTTOM)
              .fontSize($r('app.float.number_of_viewers_font_size'))
              .fontColor($r('app.color.live_header_font_color'));
          }
          .alignItems(HorizontalAlign.Start)
          .margin({right: $r('app.float.store_margin_right')});
        }
        .height($r('app.float.store_height'))
        .backgroundColor($r('app.color.store_background_color'))
        .border({radius: $r('app.float.store_border_radius')});

        Image($r('app.media.icon_close_1'))
          .width(ResourceUtil.getCommonImgSize()[0])
          .height(ResourceUtil.getCommonImgSize()[0]);
      };

      Image($r('app.media.icon_close_white'))
        .width(20)
        .onClick(() => {
          HMRouterMgr.pop();
        });
    }
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.store_height'))
    .padding(10)
    .margin({top: $r('app.float.store_margin_top')})
    .justifyContent(FlexAlign.SpaceBetween);
  }
}