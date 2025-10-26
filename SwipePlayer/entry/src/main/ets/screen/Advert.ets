/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { PlayerSession, SwipePlayerController } from '@hadss/swipeplayer';
import { AdvertConstants } from '../constant/AdvertConstants';
import { CommonConstant } from '../constant/CommonConstant';

@Component
export struct Advert {
  @StorageLink('displayWidth') displayWidth: number = 0;

  build() {
    Column() {
      Column() {
        Flex({
          direction: FlexDirection.Column,
          justifyContent: this.displayWidth < CommonConstant.PHONE_WIDTH ? FlexAlign.Start : FlexAlign.Center,
          alignItems: this.displayWidth < CommonConstant.PHONE_WIDTH ? ItemAlign.Start : ItemAlign.Center
        }) {
          Text(AdvertConstants.getAdvertTitle(this.getUIContext()))
            .margin({
              top: AdvertConstants.ADVERT_TITLE_MARGIN_TOP_OR_BOTTOM,
              bottom: AdvertConstants.ADVERT_TITLE_MARGIN_TOP_OR_BOTTOM
            })
            .fontSize(AdvertConstants.ADVERT_TITLE_FONT_SIZE)
            .fontWeight(CommonConstant.CUSTOM_FONT_WEIGHT);
          Text() {
            ImageSpan(AdvertConstants.ADVERT_HUAWEI_ICON)
              .width(AdvertConstants.ADVERT_HUAWEI_ICON_WIDTH);
            Span(' ')
              .letterSpacing(AdvertConstants.ADVERT_HUAWEI_ICON_LETTER_SPACING);
            Span(AdvertConstants.getAdvertTextPublicize(this.getUIContext()))
              .fontWeight(CommonConstant.CUSTOM_FONT_WEIGHT);
          }
          .textAlign(TextAlign.Center);


          if (this.displayWidth > CommonConstant.PHONE_WIDTH && this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH) {
            Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
              Image(AdvertConstants.ADVERT_FOLD_LEFT_MASK_IMAGE)
                .width(AdvertConstants.ADVERT_FOLD_MASK_IMAGE_WIDTH)
                .height(AdvertConstants.ADVERT_FOLD_MASK_IMAGE_HEIGHT);

              Image(AdvertConstants.ADVERT_PUBLICIZE_IMAGE)
                .width(AdvertConstants.ADVERT_FOLD_PUBLICIZE_IMAGE_WIDTH)
                .border({
                  width: AdvertConstants.ADVERT_PUBLICIZE_IMAGE_BORDER[0],
                  color: CommonConstant.CUSTOM_FONT_COLOR,
                  radius: AdvertConstants.ADVERT_PUBLICIZE_IMAGE_BORDER[1]
                });

              Image(AdvertConstants.ADVERT_FOLD_RIGHT_MASK_IMAGE)
                .width(AdvertConstants.ADVERT_FOLD_MASK_IMAGE_WIDTH)
                .height(AdvertConstants.ADVERT_FOLD_MASK_IMAGE_HEIGHT);
            }
            .width(AdvertConstants.ADVERT_PLACE_HOLD_WIDTH)
            .height(AdvertConstants.ADVERT_PLACE_HOLD_HEIGHT);
          } else {
            Image(AdvertConstants.ADVERT_PUBLICIZE_IMAGE)
              .height(AdvertConstants.ADVERT_PLACE_HOLD_HEIGHT)
              .margin({
                top: AdvertConstants.ADVERT_IMAGE_PUBLICIZE_TOP_MARGIN,
                bottom: AdvertConstants.ADVERT_IMAGE_PUBLICIZE_BOTTOM_MARGIN
              })
              .border({
                width: AdvertConstants.ADVERT_PUBLICIZE_IMAGE_BORDER[0],
                color: CommonConstant.CUSTOM_FONT_COLOR,
                radius: AdvertConstants.ADVERT_PUBLICIZE_IMAGE_BORDER[1]
              });
          }

          Text(){
            Span(AdvertConstants.getAdvertPublicizeImageIntroText(this.getUIContext())[0])
              .fontSize(AdvertConstants.ADVERT_PUBLICIZE_IMAGE_INTRO_TEXT_FONT_SIZE)
              .fontWeight(CommonConstant.CUSTOM_FONT_WEIGHT)
            Span(AdvertConstants.getAdvertPublicizeImageIntroText(this.getUIContext())[1])
              .fontSize(AdvertConstants.ADVERT_PUBLICIZE_IMAGE_INTRO_TEXT_OFFICIAL_FONT_SIZE)
              .fontWeight(CommonConstant.CUSTOM_FONT_WEIGHT)
          }
          .margin({ bottom: AdvertConstants.ADVERT_PUBLICIZE_IMAGE_INTRO_TEXT_MARGIN_BOTTOM });

          Row() {
            Text() {
              Span(AdvertConstants.getAdvertBottomText(this.getUIContext())[0])
                .fontSize(AdvertConstants.ADVERT_PUBLICIZE_IMAGE_INTRO_TEXT_FONT_SIZE);
              Span(AdvertConstants.getAdvertBottomText(this.getUIContext())[1]);
            }
            .fontColor(AdvertConstants.ADVERT_BOTTOM_TEXT_PRICE_FONT_COLOR)
            .fontWeight(CommonConstant.CUSTOM_FONT_WEIGHT);

            Text(AdvertConstants.getAdvertBottomText(this.getUIContext())[2])
              .margin({
                left: AdvertConstants.ADVERT_BOTTOM_TEXT_MARGIN[0],
                right: AdvertConstants.ADVERT_BOTTOM_TEXT_MARGIN[1]
              });

            Text() {
              Span(AdvertConstants.getAdvertBottomText(this.getUIContext())[3]);
              Span(' ')
                .letterSpacing(AdvertConstants.ADVERT_HUAWEI_ICON_LETTER_SPACING);
              ImageSpan(AdvertConstants.ADVERT_BOTTOM_MORE_ICON)
                .width(AdvertConstants.ADVERT_BOTTOM_MORE_ICON_WIDTH);
            }
            .textAlign(TextAlign.Center);
          }
          .margin({ bottom: AdvertConstants.ADVERT_IMAGE_PUBLICIZE_TOP_MARGIN });

          Flex({ justifyContent: FlexAlign.Center }) {
            Button(AdvertConstants.getButtonNoInterestText(this.getUIContext()))
              .width(this.displayWidth < CommonConstant.PHONE_WIDTH ? AdvertConstants.BUTTON_WIDTH :
              AdvertConstants.FOLD_BUTTON_WIDTH)
              .margin({ right: AdvertConstants.BUTTON_NO_INTEREST_MARGIN_RIGHT })
              .backgroundColor(AdvertConstants.BUTTON_NO_INTEREST_BACKGROUND_COLOR)
              .fontColor(AdvertConstants.BUTTON_NO_INTEREST_FONT_COLOR);
            Button(AdvertConstants.getButtonLookDetailText(this.getUIContext()))
              .width(this.displayWidth < CommonConstant.PHONE_WIDTH ? AdvertConstants.BUTTON_WIDTH :
              AdvertConstants.FOLD_BUTTON_WIDTH)
              .backgroundColor(AdvertConstants.BUTTON_LOOK_DETAIL_BACKGROUND_COLOR)
              .fontColor(AdvertConstants.BUTTON_LOOK_DETAIL_FONT_COLOR);
          }
          .margin({ bottom: AdvertConstants.BUTTON_MARGIN_BOTTOM });
        }
        .borderRadius(AdvertConstants.ADVERT_PUBLICIZE_IMAGE_BORDER[1])
        .padding({
          left: AdvertConstants.ADVERT_PADDING,
          right: AdvertConstants.ADVERT_PADDING
        })
        .backgroundColor(AdvertConstants.ADVERT_BACKGROUND_COLOR)
        .width(CommonConstant.FULL_PERCENT_WIDTH)
        .height(CommonConstant.FULL_PERCENT_HEIGHT);
      }
      .offset({ y: AdvertConstants.ADVERT_OFFSET })
      .width(this.displayWidth < CommonConstant.PHONE_WIDTH ? CommonConstant.NINETY_FIVE_PERCENT_WIDTH :
      CommonConstant.EIGHTY_PERCENT_WIDTH)
      .height(CommonConstant.SEVENTY_FIVE_PERCENT_HEIGHT)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.SpaceEvenly);
    }
    .width(CommonConstant.FULL_PERCENT_WIDTH)
    .height(CommonConstant.FULL_PERCENT_HEIGHT)
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [
        [AdvertConstants.ADVERT_FULL_BACKGROUND_COLOR[1], 0],
        [AdvertConstants.ADVERT_FULL_BACKGROUND_COLOR[0], 1]
      ]
    });
  }
}

@Builder
export function advertBuilder(_dataObj: ESObject, _playerSession: PlayerSession | undefined,
  _swipePlayerController: SwipePlayerController) {
  Advert();
}