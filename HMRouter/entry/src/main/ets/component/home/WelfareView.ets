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
import { ResourceUtil } from '../common/utils/ResourceUtil';
import { BreakpointType } from '../common/utils/BreakpointType';
import { HomeConstants } from '../common/constants/HomeConstants';
import { IconInfo, IconInfoViewModel } from '../viewmodel/IconInfoViewModel';
import { HomeButton } from './CommonView';

@Component
export struct WelfareView {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  private welfareList: IconInfo[] = new IconInfoViewModel().getWelfareList();

  build() {
    Column() {
      Flex({justifyContent: FlexAlign.Start}) {
        Text(HomeConstants.HOME_TITLES[0])
          .fontSize($r('app.float.title_font'))
          .lineHeight($r('app.float.title_line'))
          .fontWeight(CommonConstants.FONT_WEIGHT_500);

        Blank();

        HomeButton({buttonText: HomeConstants.BUTTON_TEXTS[0]});
      }
      .height($r('app.float.title_height'));

      Flex({justifyContent: FlexAlign.SpaceBetween}) {
        ForEach(this.welfareList.slice(0, 3), (item: IconInfo) => {
          Column() {
            Image(item.getIcon())
              .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
              $r('app.float.welfare_image_size_sm') : $r('app.float.welfare_image_size'))
              .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
              $r('app.float.welfare_image_size_sm') : $r('app.float.welfare_image_size'));
            Text(HomeConstants.TIP_TEXTS[0])
              .fontSize($r('app.float.welfare_tip_font'))
              .fontWeight(FontWeight.Normal)
              .lineHeight($r('app.float.welfare_tip_line'))
              .width($r('app.float.welfare_tip_width'))
              .borderRadius(ResourceUtil.getCommonBorderRadius()[5])
              .backgroundColor($r('app.color.welfare_tip_background'))
              .textAlign(TextAlign.Center);
            Text(item.getInfo())
              .fontSize($r('app.float.welfare_info_font'))
              .lineHeight($r('app.float.welfare_info_line'))
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
              .margin({top: $r('app.float.welfare_info_margin')});
          }
          .height(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Start)
          .backgroundColor($r('app.color.welfare_column_background_color'));
        }, (item: IconInfo, index: number) => index + JSON.stringify(item));
      }
      .height(new BreakpointType($r('app.float.welfare_row_height_sm'), $r('app.float.welfare_row_height_md'),
        $r('app.float.welfare_row_height_lg')).getValue(this.currentBreakpoint))
      .borderRadius(ResourceUtil.getCommonBorderRadius()[6])
      .backgroundColor($r('app.color.welfare_flex_background_color'))
      .padding({
        left: new BreakpointType($r('app.float.welfare_row_padding_sm'), $r('app.float.welfare_row_padding_md'),
          $r('app.float.welfare_row_padding_lg')).getValue(this.currentBreakpoint),
        right: new BreakpointType($r('app.float.welfare_row_padding_sm'), $r('app.float.welfare_row_padding_md'),
          $r('app.float.welfare_row_padding_lg')).getValue(this.currentBreakpoint)
      });
    }
    .padding({
      top: 10,
      bottom: 10,
      left: $r('app.float.welfare_col_padding'),
      right: $r('app.float.welfare_col_padding')
    })
    .borderRadius(ResourceUtil.getCommonBorderRadius()[6])
    .linearGradient({
      direction: GradientDirection.Right,
      repeating: false,
      colors: [[HomeConstants.GRADIENT_COLORS[0], 0.0], [HomeConstants.GRADIENT_COLORS[1], 1.0]]
    });
  }
}