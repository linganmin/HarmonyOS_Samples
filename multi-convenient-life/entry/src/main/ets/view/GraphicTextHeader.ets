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

import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointType } from '../utils/BreakpointType';
import { router } from '@kit.ArkUI';


@Component
export struct GraphicTextHeader {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Consume('upDownStructure') upDownStructure: boolean;
  @StorageLink('pageShow') pageShow: string = 'button';

  build() {
    Row() {
      Image($r('app.media.v2_ic_public_back'))
        .width($r('app.float.common_image'))
        .aspectRatio(1)
        .margin({
          right: $r('app.float.common_margin')
        })
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })
      Image($r('app.media.tx1_img'))
        .width($r('app.float.tx1_width'))
        .aspectRatio(1)
        .margin({
          right: $r('app.float.filtering_margin_right')
        })
      Text($r('app.string.lee_look'))
        .fontSize($r('app.float.delicious_font'))
        .fontWeight(CommonConstants.FONT_WEIGHT_700)
      Blank()
      Button($r('app.string.follows'))
        .margin({
          right: $r('app.float.common_margin')
        })
      Image($r('app.media.v2_ic_public_share'))
        .width($r('app.float.common_image'))
        .aspectRatio(1)
        .margin({
          right: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD ? $r('app.float.common_margin') : 0
        })
      Image($r('app.media.v2_ic_public_view_list'))
        .width($r('app.float.common_image'))
        .aspectRatio(1)
        .visibility(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD && this.upDownStructure ?
        Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.upDownStructure = false;
        })
      Image($r('app.media.v2_qieHuang'))
        .width($r('app.float.common_image'))
        .aspectRatio(1)
        .visibility(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD && !this.upDownStructure ?
        Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.upDownStructure = true;
        })
    }
    .padding({
      left: new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
        $r('app.float.padding_header')).getValue(this.currentBreakpoint),
      right: new BreakpointType($r('app.float.padding_small'), $r('app.float.common_padding'),
        $r('app.float.padding_header')).getValue(this.currentBreakpoint)
    })
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.float.title_height'))
  }
}