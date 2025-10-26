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
import { BreakpointType } from '../utils/BreakpointType';
import { CommentsDataList, CommentsData } from '../viewmodel/DishDetailViewModel';
import { DishDetailConstants } from '../constants/DishDetailConstants';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct DishComments {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @Consume('ifShowSides') ifShowSides: boolean;
  private commentsDataList: CommentsData[] = new CommentsDataList().getCommentsDataList();

  build() {
    Column() {
      Row() {
        Text($r('app.string.product_evaluation'))
          .fontSize($r('app.float.amounts_font'))
          .fontWeight(CommonConstants.FONT_WEIGHT_700)
        Blank()
        Text($r('app.string.reviews_string'))
          .fontColor($r('app.color.sixty_black'))
          .fontSize($r('app.float.reviews_font'))
        Image($r('app.media.icon_more'))
          .width($r('app.float.more_width'))
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
      .padding({
        left: this.ifShowSides ? new BreakpointType($r("app.float.twelves_padding"), $r("app.float.twelves_padding"),
          $r('app.float.dish_lg')).getValue(this.currentBreakpoint) :
        new BreakpointType($r("app.float.twelves_padding"), $r('app.float.padding_small'),
          $r("app.float.twelves_padding")).getValue(this.currentBreakpoint),
        right: this.ifShowSides ? new BreakpointType($r("app.float.twelves_padding"), $r("app.float.twelves_padding"),
          $r('app.float.dish_lg')).getValue(this.currentBreakpoint) :
        new BreakpointType($r("app.float.twelves_padding"), $r('app.float.padding_small'),
          $r("app.float.twelves_padding")).getValue(this.currentBreakpoint),
        top: $r("app.float.twelves_padding"),
        bottom: $r('app.float.dish_bottom')
      })
      .border({
        color: $r('app.color.five_white'),
        width: {
          bottom: $r('app.float.dish_border_bottom')
        }
      })

      Row() {
        ForEach(DishDetailConstants.COMMENT_FILTERING_LIST, (item: string) => {
          Text(item)
            .backgroundColor($r('app.color.background_filtering'))
            .fontColor($r('app.color.filtering_font'))
            .fontSize($r('app.float.filtering_font'))
            .padding({
              top: $r('app.float.filtering_padding_tb'),
              bottom: $r('app.float.filtering_padding_tb'),
              left: $r('app.float.filtering_padding_lr'),
              right: $r('app.float.filtering_padding_lr')
            })
            .margin({
              right: $r('app.float.filtering_margin_right')
            })
        }, (item: string, index: number) => JSON.stringify(index))
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
      .padding({
        left: this.ifShowSides ? new BreakpointType($r("app.float.twelves_padding"), $r("app.float.twelves_padding"),
          $r('app.float.dish_lg')).getValue(this.currentBreakpoint) :
        new BreakpointType($r("app.float.twelves_padding"), $r('app.float.padding_small'),
          $r("app.float.twelves_padding")).getValue(this.currentBreakpoint),
        bottom: $r("app.float.twelves_padding"),
        top: $r("app.float.twelves_padding")
      })

      List() {
        ForEach(this.commentsDataList, (item: CommentsData, index: number) => {
          if (index < (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.ifShowSides ?
          CommonConstants.DISH_LG_INDEX : CommonConstants.DISH_INDEX)) {
            ListItem() {
              Row() {
                Image(item.getAvatar())
                  .width($r('app.float.avatar_width'))
                  .borderRadius($r('app.float.avatar_border'))
                  .aspectRatio(1)
                Column() {
                  Text(item.getName())
                    .fontColor($r('app.color.sixty_black'))
                    .fontSize($r('app.float.reviews_font'))
                    .margin({
                      bottom: $r('app.float.avatar_margin_bottom')
                    })

                  Text(item.getValue())
                    .fontSize($r('app.float.reviews_font'))
                    .margin({
                      bottom: $r('app.float.text_margin_bottom')
                    })
                    .width(CommonConstants.FULL_PERCENT)
                  Text(item.getDate())
                    .fontColor($r('app.color.forty_black'))
                    .fontSize($r('app.float.reviews_font'))
                    .margin({
                      bottom: $r('app.float.date_margin_bottom')
                    })
                }
                .layoutWeight(1)
                .padding({
                  left: $r('app.float.avatar_padding_left')
                })
                .alignItems(HorizontalAlign.Start)
              }
              .alignItems(VerticalAlign.Top)
            }
          }
        }, (item: CommentsData, index: number) => JSON.stringify(index))
      }
      .width('auto')
      .height('auto')
      .scrollBarWidth(0)
      .layoutWeight(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG && !this.ifShowSides ? 1 : 0)
      .padding({
        left: this.ifShowSides ? new BreakpointType($r("app.float.twelves_padding"), $r("app.float.twelves_padding"),
          $r('app.float.dish_lg')).getValue(this.currentBreakpoint) :
        new BreakpointType($r("app.float.twelves_padding"), $r('app.float.padding_small'),
          $r("app.float.twelves_padding")).getValue(this.currentBreakpoint),
        bottom: $r('app.float.dish_bottom'),
        top: $r("app.float.twelves_padding")
      })

      Row() {
        Text($r('app.string.view_all_reviews'))
          .fontColor($r('app.color.sixty_black'))
          .fontSize($r('app.float.reviews_font'))
        Image($r('app.media.icon_more'))
          .width($r('app.float.more_width'))
      }
      .height($r('app.float.view_height'))
    }
    .margin({
      left: this.ifShowSides ? new BreakpointType($r('app.float.margin_small'), $r('app.float.margin_small'),
        $r('app.float.common_margin')).getValue(this.currentBreakpoint) :
      new BreakpointType($r('app.float.margin_small'), $r('app.float.common_margin'),
        $r('app.float.zero_margin')).getValue(this.currentBreakpoint),
      right: this.ifShowSides ? new BreakpointType($r('app.float.margin_small'), $r('app.float.margin_small'),
        $r('app.float.common_margin')).getValue(this.currentBreakpoint) :
      new BreakpointType($r('app.float.margin_small'), $r('app.float.common_margin'),
        $r('app.float.common_margin')).getValue(this.currentBreakpoint),
      bottom: $r('app.float.margin_twelves')
    })
    .borderRadius($r('app.float.dish_border'))
    .backgroundColor(Color.White)
  }
}