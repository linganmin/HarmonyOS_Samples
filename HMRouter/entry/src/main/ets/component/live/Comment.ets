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
import { LiveConstants } from '../common/constants/LiveConstants';
import { BreakpointType } from '../common/utils/BreakpointType';

@Component
export struct Comment {
  @Prop currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;

  build() {
    Column() {
      ForEach(LiveConstants.LIVE_COMMENTS_LIST, (item: string, index: number) => {
        Row() {
          Text($r('app.string.official_review'))
            .fontColor($r('app.color.comment_text_font_color'))
            .fontSize($r('app.float.live_comment_font_size'))
            .linearGradient({
              angle: 0,
              direction: GradientDirection.Left,
              colors: [[$r('app.color.comment_text_linear_gradient_color_start'), 0],
                [$r('app.color.comment_text_linear_gradient_color_end'), 1]]
            })
            .border({radius: $r('app.float.official_review_border_radius')})
            .padding($r('app.float.official_review_padding'))
            .margin({right: $r('app.float.official_review_margin')})
            .visibility(index === 0 ? Visibility.Visible : Visibility.None);
          Text(item)
            .layoutWeight(new BreakpointType(LiveConstants.COMMENTS_WIDTH[0], LiveConstants.COMMENTS_WIDTH[1],
              LiveConstants.COMMENTS_WIDTH[2]).getValue(this.currentBreakpoint))
            .fontColor($r('app.color.comment_text_font_color'))
            .lineHeight($r('app.float.comments_line_height'))
            .fontSize($r('app.float.live_comment_font_size'));
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)
        .margin({bottom: $r('app.float.live_comment_margin_bottom')})
        .border({radius: $r('app.float.live_comment_border_radius')})
        .backgroundColor($r('app.color.comment_background_color'))
        .padding({
          left: $r('app.float.live_comment_padding_left'),
          top: $r('app.float.live_comment_padding'),
          bottom: $r('app.float.live_comment_padding'),
          right: $r('app.float.live_comment_padding')
        });
      }, (item: string, index: number) => item + index);
    }
    .constraintSize({minWidth:'80%'})
    .alignItems(HorizontalAlign.Start)
    .alignSelf(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? ItemAlign.End : ItemAlign.Start);
  }
}