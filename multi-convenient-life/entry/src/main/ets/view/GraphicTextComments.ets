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
export struct GraphicTextComments {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('windowTop') windowTop: number = 0;
  @Consume('showSideBar') showSideBar: boolean;
  private TagList: ResourceStr[] = [$r('app.string.free_parking'), $r('app.string.recent_orders'),
    $r('app.string.positive_feedback')]
  private CommentsList: ResourceStr[] = ['有图/视频', '好评', '差评', '其他'];

  build() {
    Scroll() {
      Column() {
        Stack() {
          Image($r('app.media.slt_img'))
            .width(CommonConstants.FULL_PERCENT)
            .height($r('app.float.slt_height'))
          Image($r('app.media.icon_cancel'))
            .width($r('app.float.common_image'))
            .aspectRatio(1)
            .position({
              top: CommonConstants.ICON_IMAGE_POSITION + this.windowTop,
              left: $r('app.float.common_padding')
            })
            .onClick(() => {
              this.showSideBar = false;
            })
        }

        Column() {
          Column() {
            Row() {
              Text($r('app.string.seabird_park'))
                .fontSize($r('app.float.delicious_font'))
                .fontWeight(CommonConstants.FONT_WEIGHT_700)
              Blank()
              Column() {
                Image($r('app.media.v2_ic_public_collect'))
                  .width($r('app.float.more_width'))
                  .aspectRatio(1)
                Text($r('app.string.collections_text'))
                  .fontColor($r('app.color.sixty_black'))
                  .fontSize($r('app.float.delivery_font'))
              }
            }
            .width(CommonConstants.FULL_PERCENT)
            .margin({
              bottom: $r('app.float.margin_twelves')
            })

            Row() {
              ForEach(this.TagList, (item: ResourceStr) => {
                Text(item)
                  .fontSize($r('app.float.filtering_font'))
                  .backgroundColor($r('app.color.background_filtering'))
                  .fontColor($r('app.color.currency_symbol'))
                  .padding({
                    top: $r('app.float.orange_padding'),
                    bottom: $r('app.float.orange_padding'),
                    left: $r('app.float.tabs_padding_tb'),
                    right: $r('app.float.tabs_padding_tb')
                  })
                  .margin({
                    right: $r('app.float.tag_margin_right')
                  })
                  .borderRadius($r('app.float.tag_radius'))
              })
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)
            .margin({
              bottom: $r('app.float.margin_twelves')
            })

            Text($r('app.string.address_text'))
              .fontColor($r('app.color.sixty_black'))
              .fontSize($r('app.float.delivery_font'))
              .margin({
                bottom: $r('app.float.margin_twelves')
              })
              .width(CommonConstants.FULL_PERCENT)
            Row() {
              Text($r('app.string.currency_symbol'))
                .fontSize($r('app.float.delivery_font'))
                .fontColor($r('app.color.currency_symbol'))
                .margin({
                  right: $r('app.float.filtering_padding_lr')
                })
              Text($r('app.string.price_text'))
                .fontSize($r('app.float.delicious_font'))
                .fontColor($r('app.color.currency_symbol'))
                .margin({
                  right: $r('app.float.price_margin_right')
                })
              Text($r('app.string.tickets_are'))
                .fontSize($r('app.float.filtering_font'))
                .fontColor($r('app.color.forty_black'))
              Blank()
              if (this.currentBreakpoint !== BreakpointConstants.BREAKPOINT_MD) {
                Button($r('app.string.add_cart'))
                  .height($r('app.float.add_cart_height'))
              }
            }
            .width(CommonConstants.FULL_PERCENT)
          }
          .borderRadius($r('app.float.dish_border'))
          .padding({
            top: $r('app.float.nine_padding'),
            left: $r('app.float.twelves_padding'),
            right: $r('app.float.twelves_padding'),
            bottom: $r('app.float.twelves_padding')
          })
          .width(CommonConstants.FULL_PERCENT)
          .backgroundColor(Color.White)
          .margin({
            bottom: $r('app.float.margin_small')
          })

          Column() {
            Row() {
              Text($r('app.string.attraction_details'))
                .fontWeight(CommonConstants.FONT_WEIGHT_700)
                .fontSize($r('app.float.attraction_details_font'))
              Blank()
              Text($r('app.string.introduction_pictures'))
                .fontColor($r('app.color.sixty_black'))
                .fontSize($r('app.float.tabs_font'))
              Image($r('app.media.ic_public_arrow_right_gray'))
                .width($r('app.float.more_width'))
                .aspectRatio(1)
            }
            .width(CommonConstants.FULL_PERCENT)
            .margin({
              bottom: $r('app.float.nine_margin')
            })

            Divider()
              .width(CommonConstants.FULL_PERCENT)
              .margin({
                bottom: $r('app.float.margin_twelves')
              })
            Row() {
              Text($r('app.string.opening_hours'))
                .fontSize($r('app.float.delivery_font'))
                .fontColor($r('app.color.sixty_black'))
                .width($r('app.float.opening_width'))
                .textAlign(TextAlign.Start)
              Text($r('app.string.last_admission'))
                .fontSize($r('app.float.delivery_font'))
                .fontColor($r('app.color.sixty_black'))
                .layoutWeight(1)
            }
            .margin({
              bottom: $r('app.float.margin_twelves')
            })

            Row() {
              Text($r('app.string.tickets_key'))
                .fontSize($r('app.float.delivery_font'))
                .fontColor($r('app.color.sixty_black'))
                .width($r('app.float.opening_width'))
                .textAlign(TextAlign.Start)
              Text($r('app.string.tickets_value'))
                .fontSize($r('app.float.delivery_font'))
                .fontColor($r('app.color.sixty_black'))
                .layoutWeight(1)
            }
            .margin({
              bottom: $r('app.float.margin_twelves')
            })

            Row() {
              Text($r('app.string.policy_key'))
                .fontSize($r('app.float.delivery_font'))
                .fontColor($r('app.color.sixty_black'))
                .width($r('app.float.opening_width'))
                .textAlign(TextAlign.Start)
              Text($r('app.string.policy_value'))
                .fontSize($r('app.float.delivery_font'))
                .fontColor($r('app.color.sixty_black'))
                .layoutWeight(1)
            }
            .margin({
              bottom: $r('app.float.margin_twelves')
            })

            Row() {
              Text($r('app.string.tel_key'))
                .fontSize($r('app.float.delivery_font'))
                .fontColor($r('app.color.sixty_black'))
                .width($r('app.float.opening_width'))
                .textAlign(TextAlign.Start)
              Text($r('app.string.tel_value'))
                .fontSize($r('app.float.delivery_font'))
                .fontColor($r('app.color.sixty_black'))
                .layoutWeight(1)
            }
            .margin({
              bottom: $r('app.float.margin_twelves')
            })

          }
          .width(CommonConstants.FULL_PERCENT)
          .backgroundColor(Color.White)
          .borderRadius($r('app.float.dish_border'))
          .padding({
            top: $r('app.float.nine_padding'),
            left: $r('app.float.twelves_padding'),
            right: $r('app.float.twelves_padding'),
            bottom: $r('app.float.twelves_padding')
          })
          .margin({
            bottom: $r('app.float.margin_small')
          })

          Column() {
            Row() {
              Text($r('app.string.product_evaluation'))
                .fontSize($r('app.float.amounts_font'))
                .fontWeight(CommonConstants.FONT_WEIGHT_700)
              Blank()
              Text($r('app.string.reviews_string'))
                .fontColor($r('app.color.sixty_black'))
                .fontSize($r('app.float.reviews_font'))
              Image($r('app.media.ic_public_arrow_right_gray'))
                .width($r('app.float.more_width'))
            }
            .width(CommonConstants.FULL_PERCENT)
            .margin({
              bottom: $r('app.float.nine_margin')
            })

            Divider()
              .color($r('app.color.five_white'))
              .margin({
                bottom: $r('app.float.text_margin_bottom')
              })
            Row() {
              ForEach(this.CommentsList, (item: ResourceStr) => {
                Text(item)
                  .fontSize($r('app.float.filtering_font'))
                  .backgroundColor($r('app.color.background_filtering'))
                  .fontColor($r('app.color.currency_symbol'))
                  .padding({
                    top: $r('app.float.orange_padding'),
                    bottom: $r('app.float.orange_padding'),
                    left: $r('app.float.tabs_padding_tb'),
                    right: $r('app.float.tabs_padding_tb')
                  })
                  .margin({
                    right: $r('app.float.tag_margin_right')
                  })
                  .borderRadius($r('app.float.tag_radius'))
              })
            }
            .width(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.Start)
            .margin({
              bottom: $r('app.float.margin_twelves')
            })

            Row() {
              Image($r('app.media.tx2_img'))
                .width($r('app.float.tx2_width'))
                .aspectRatio(1)
                .margin({
                  right: $r('app.float.back_image_right')
                })
              Column() {
                Text($r('app.string.sanger'))
                  .fontColor($r('app.color.forty_black'))
                  .fontSize($r('app.float.delivery_font'))
                  .margin({
                    bottom: $r('app.float.sanger_bottom')
                  })
                Text($r('app.string.nice_comment'))
                  .fontSize($r('app.float.delivery_font'))
              }
              .alignItems(HorizontalAlign.Start)
              .padding({
                top: $r('app.float.text_margin_bottom')
              })
              .layoutWeight(1)

              Column() {
                Image($r('app.media.v2_ic_public_favor'))
                  .width($r('app.float.more_width'))
                  .aspectRatio(1)
                  .margin({
                    bottom: $r('app.float.favor_bottom')
                  })
                Text($r('app.string.two_number'))
                  .fontColor($r('app.color.forty_black'))
                  .fontSize($r('app.float.filtering_font'))
              }
              .margin({
                left: $r('app.float.favor_margin_left')
              })
            }
            .width(CommonConstants.FULL_PERCENT)
            .margin({
              bottom: $r('app.float.margin_small')
            })

            Row() {
              Text($r('app.string.view_all_reviews'))
                .fontColor($r('app.color.sixty_black'))
                .fontSize($r('app.float.tabs_font'))
              Image($r('app.media.icon_more'))
                .width($r('app.float.more_width'))
                .aspectRatio(1)
            }
            .height($r('app.float.all_comments'))
          }
          .borderRadius($r('app.float.dish_border'))
          .padding({
            top: $r('app.float.nine_padding'),
            left: $r('app.float.twelves_padding'),
            right: $r('app.float.twelves_padding'),
            bottom: $r('app.float.twelves_padding')
          })
          .backgroundColor(Color.White)
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding($r('app.float.padding_small'))
      }
    }
    .scrollBarWidth(0)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor('#F1F3F5')
    .height(CommonConstants.FULL_PERCENT)
    .align(Alignment.Top)
  }
}