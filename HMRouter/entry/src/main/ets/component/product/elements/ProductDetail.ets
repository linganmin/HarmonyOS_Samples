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
import { CommonConstants } from '../../common/constants/CommonConstants';
import { DetailConstants } from '../../common/constants/DetailConstants';
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import { ProductMsg } from './ProductUtilView';

@Component
export struct ProductPicture {
  @StorageLink('topRectHeight') topRectHeight: number = 0;
  @StorageLink('isSplitMode') isSplitMode: boolean = false;
  @State currentSwiperIndex: number = 0;

  build() {
    Column() {
      Stack({ alignContent: Alignment.End }) {
        Swiper() {
          ForEach(DetailConstants.PRODUCT_DETAIL_RESOURCES, (item: Resource) => {
            Image(item)
              .width(CommonConstants.FULL_PERCENT);
          }, (item: Resource, index: number) => index + JSON.stringify(item));
        }
        .align(Alignment.Center)
        .indicator(false)
        .displayCount(1)
        .nextMargin(175)
        .prevMargin(175)
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .onChange((index: number) => {
          this.currentSwiperIndex = index;
        });

        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
          Image($r('app.media.ic_back'))
            .height(ResourceUtil.getCommonImgSize()[1])
            .width(ResourceUtil.getCommonImgSize()[1])
            .margin({ right: $r('app.float.picture_icon_margin') })
            .onClick(() => {
              HMRouterMgr.popAsync({ navigationId: this.queryNavigationInfo()?.navigationId });
            });
          Image($r('app.media.ic_more'))
            .height(ResourceUtil.getCommonImgSize()[1])
            .width(ResourceUtil.getCommonImgSize()[1])
            .visibility(Visibility.Visible);
        }
        .width(CommonConstants.FULL_PERCENT)
        .position({ x: 0, y: DetailConstants.LIVE_ROW_Y_POSITION })
        .padding({
          left: 16,
          right: 16
        });

        Column() {
          Image($r('app.media.ic_public_living'))
            .width(ResourceUtil.getCommonImgSize()[0])
            .height(ResourceUtil.getCommonImgSize()[0])
            .borderRadius(ResourceUtil.getCommonBorderRadius()[4]);
          Text(DetailConstants.LIVING)
            .fontSize($r('app.float.picture_live_font'))
            .lineHeight($r('app.float.picture_live_line'))
            .fontWeight(FontWeight.Normal);
        }
        .margin({
          top: 0,
          right: 16
        })
        .borderWidth(1)
        .borderRadius(ResourceUtil.getCommonBorderRadius()[3])
        .borderColor($r('app.color.living_border_color'))
        .backgroundColor($r('app.color.living_background'))
        .justifyContent(FlexAlign.SpaceEvenly)
        .height($r('app.float.picture_live_col_height'))
        .width($r('app.float.picture_live_col_width'))
        .onClick(() => {
          HMRouterMgr.to('liveHome')
            .withNavigation(this.queryNavigationInfo()?.navigationId)
            .pushAsync()
        })
        .id('liveHome');
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(-1);

      Row() {
        Column() {
          Text(JSON.stringify(this.currentSwiperIndex + 1) + DetailConstants.PICTURE_INDICATOR[0])
            .fontSize($r('app.float.picture_number_font'))
            .fontWeight(FontWeight.Normal)
            .fontColor($r('app.color.product_font_color_1'));
        }
        .width($r('app.float.picture_number_row_width'))
        .height($r('app.float.picture_number_row_height'))
        .backgroundColor($r('app.color.swiper_indicator_background'))
        .borderRadius(ResourceUtil.getCommonBorderRadius()[3])
        .justifyContent(FlexAlign.Center);
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.End)
      .padding({ right: 24 });

      // image
      Row() {
        List({
          space: 12
        }) {
          ForEach(DetailConstants.PRODUCT_SMALL_RESOURCES, (item: Resource, index: number) => {
            ListItem() {
              Image(item)
                .width(36)
                .height(36)
                .borderRadius(ResourceUtil.getCommonBorderRadius()[3])
                .borderWidth(index === this.currentSwiperIndex ? 1 : 0);
            };
          }, (item: Resource, index: number) => JSON.stringify(item) + index);
        }
        .width('auto')
        .height('auto')
        .scrollBar(BarState.Off)
        .listDirection(Axis.Horizontal)
        .margin({
          top: $r('app.float.small_picture_margin'),
          bottom: $r('app.float.small_picture_margin')
        });
      }
      .height(60)
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: 16,
        right: 16
      });
    }
    .width('100%')
    .height('55%')
    .backgroundColor($r('app.color.product_background_color_1'))
    .alignItems(HorizontalAlign.Center);

  }
}

@Component
export struct ProductInfo {
  @Link product: ProductMsg;

  build() {
    Column() {
      Column() {
        Text('[官方旗舰店] HUAWEI Mate X5 ' + this.product.color + ' ' + this.product.memory)
          .fontSize($r('app.float.discount_text_font_1'))
          .lineHeight($r('app.float.discount_text_line'))
          .fontWeight(CommonConstants.FONT_WEIGHT_500)
          .margin({ bottom: $r('app.float.discount_text_margin_1') });
        Row() {
          Text(DetailConstants.PRODUCT_PRICE_NAMES[0])
            .fontSize($r('app.float.product_price_font_1'))
            .lineHeight($r('app.float.product_price_line_1'))
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
            .fontColor($r('app.color.product_font_color_2'))
            .displayPriority(4);
          Text(this.product.price)
            .fontSize($r('app.float.product_price_font_2'))
            .lineHeight($r('app.float.product_price_line_2'))
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
            .fontColor($r('app.color.product_font_color_2'))
            .displayPriority(4);
        };

        Row() {
          Image($r('app.media.ic_public_gps'))
            .opacity(CommonConstants.TEXT_OPACITY[2])
            .width(ResourceUtil.getCommonImgSize()[6])
            .height(ResourceUtil.getCommonImgSize()[6])
            .margin({ right: $r('app.float.price_position_margin') });
          Column() {
            Row() {
              Text('官方发货  HUAWEI Mate X5 ' + this.product.color + ' ' + this.product.memory)
                .fontSize($r('app.float.product_price_font_3'))
                .fontWeight(FontWeight.Normal)
                .lineHeight($r('app.float.product_price_line_3'))
                .opacity(CommonConstants.TEXT_OPACITY[2]);
            }
            .width(CommonConstants.FULL_PERCENT);

            Text(DetailConstants.PRODUCT_PRICE_NAMES[15])
              .fontSize($r('app.float.product_price_font_3'))
              .lineHeight($r('app.float.product_price_line_3'))
              .margin({ top: $r('app.float.price_position_margin') });
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);

          Image(ResourceUtil.getArrowRight())
            .width($r('app.float.right_arrow_width'))
            .height($r('app.float.right_arrow_height'));
        }
        .alignItems(VerticalAlign.Top)
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.price_position_row_height'))
        .borderRadius(ResourceUtil.getCommonBorderRadius()[5])
        .width(CommonConstants.FULL_PERCENT);
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor($r('app.color.product_background_color_1'))
      .width(CommonConstants.FULL_PERCENT)
      .borderRadius(ResourceUtil.getCommonBorderRadius()[6])
      .padding($r('app.float.discount_col_padding'))
      .margin({
        bottom: 16
      });

      PhonePicture();
    }
    .backgroundColor($r('app.color.products_info'))
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: 16,
      left: 16,
      right: 16,
      bottom: $r('app.float.product_info_padding_bottom')
    });
  }
}

@Component
export struct PhonePicture {
  build() {
    Column() {
      ForEach(DetailConstants.PRODUCT_DETAIL_RESOURCES, (item: Resource) => {
        Image(item)
          .width(CommonConstants.FULL_PERCENT);
      }, (item: Resource, index: number) => index + JSON.stringify(item));
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.product_background_color_1'))
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius(ResourceUtil.getCommonBorderRadius()[6])
    .padding($r('app.float.discount_col_padding'))
    .margin({
      bottom: 16
    });
  }
}
