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

@Component
export struct GraphicTextFooter {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Consume('showSideBar') showSideBar: boolean;
  private iconList = [$r('app.media.v2_ic_public_edit'), $r('app.media.v2_ic_public_favor'),
    $r('app.media.v2_ic_public_collect'), $r('app.media.v2_ic_public_comments')];
  private textList = ['写评论', '267', '193', '1593'];

  build() {
    Row() {
      ForEach(this.iconList, ((item: Resource, index: number) => {
        Row() {
          Image(item)
            .width($r('app.float.common_image'))
            .aspectRatio(1)
            .margin({
              right: $r('app.float.filtering_padding_lr')
            })
          Text(this.textList[index])
            .fontSize($r('app.float.delivery_font'))
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
        }
        .alignItems(VerticalAlign.Center)

      }))
    }
    .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.showSideBar ?
    CommonConstants.FIFTY_PERCENT_STRING : CommonConstants.FULL_PERCENT)
    .justifyContent(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.showSideBar ?
    FlexAlign.SpaceBetween : FlexAlign.SpaceAround)
    .height($r('app.float.title_height'))
  }
}