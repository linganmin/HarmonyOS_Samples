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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { SwipePlayerController } from '@hadss/swipeplayer';
import { PlayerSpeed } from '../model/CommonModel';
import { CommonConstant } from '../constant/CommonConstant';

@Component
export struct FastSpeed {
  @State speedNum: number = 0;
  @State timeOutId: number = 0;
  @State clickSpeedDialogId: number = 0;
  @StorageLink('isSelected') isSelected: number = 1;
  @StorageLink('displayWidth') displayWidth: number = 0;
  @StorageLink('playerSpeed') playerSpeed: number = 1;
  private swipeData: SwipeData = null!;
  private closeDialog: () => void = null!;

  // Double speed prompt window
  @Builder
  clickSpeedBuilder() {
    Column() {
      Text(CommonConstant.getVideoFastSpeedToast(this.getUIContext())[0] + this.speedNum + CommonConstant.getVideoFastSpeedToast(this.getUIContext())[1]);
    }
    .width(CommonConstant.FULL_PERCENT_WIDTH)
    .height(CommonConstant.FULL_PERCENT_HEIGHT)
    .backgroundColor(CommonConstant.SYSTEM_CUSTOM_BACKGROUND_COLOR)
    .margin({
      left: CommonConstant.VIDEO_FAST_SPEED_TOAST_MARGIN,
      right: CommonConstant.VIDEO_FAST_SPEED_TOAST_MARGIN
    })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center);
  }

  aboutToDisappear(): void {
    this.getUIContext().getPromptAction().closeCustomDialog(this.clickSpeedDialogId);
  }

  build() {
    RelativeContainer() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
        // Top Text
        Flex({
          justifyContent: this.displayWidth > CommonConstant.PHONE_WIDTH &&
            this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH ? FlexAlign.Center : FlexAlign.SpaceBetween,
          alignItems: ItemAlign.Center
        }) {
          Text(CommonConstant.getFastSpeedTopText(this.getUIContext()))
            .textAlign(this.displayWidth > CommonConstant.PHONE_WIDTH &&
              this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH ? TextAlign.Center : TextAlign.Start)
            .fontWeight(CommonConstant.FAST_SPEED_TEXT_FONT_WEIGHT)
            .margin({ top: CommonConstant.TEXT_TEXT_MARGIN[1] })
            .fontSize(CommonConstant.FAST_SPEED_TOP_TEXT_FONT_SIZE);
          Image(CommonConstant.IMAGE_CLOSE)
            .width(CommonConstant.IMAGE_CLOSE_WIDTH)
            .visibility(this.displayWidth > CommonConstant.PHONE_WIDTH &&
              this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH ? Visibility.None : Visibility.Visible)
            .onClick(() => {
              this.closeDialog();
            });
        };

        // Double speed zone
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
          Image(CommonConstant.SPEED_IMAGE)
            .margin({ right: CommonConstant.ICON_TEXT_MARGIN })
            .width(CommonConstant.SPEED_IMAGE_WIDTH);
          Text(CommonConstant.getFastSpeedText(this.getUIContext()))
            .margin({ right: CommonConstant.TEXT_TEXT_MARGIN[1] })
            .fontSize(CommonConstant.FAST_SPEED_FONT_SIZE)
            .fontWeight(CommonConstant.FAST_SPEED_TEXT_FONT_WEIGHT);
          Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceEvenly, alignItems: ItemAlign.Center }) {
            ForEach(CommonConstant.VIDEO_FAST_SPEED, (item: PlayerSpeed, commonIndex: number) => {
              Text(item.text + 'x')
                .fontWeight(CommonConstant.CUSTOM_FONT_WEIGHT)
                .fontColor(this.isSelected === commonIndex ? CommonConstant.SPEED_TEXT_CLICK_FONT_COLOR :
                CommonConstant.SPEED_TEX_FONT_COLOR)
                .onClick(() => {
                  this.isSelected = commonIndex;
                  this.playerSpeed = item.playbackSpeed;
                  this.swipeData.swipePlayerController.setSpeed(this.playerSpeed);
                  if (this.isSelected === commonIndex) {
                    this.speedNum = item.text;
                  }
                  this.getUIContext().getPromptAction().closeCustomDialog(this.clickSpeedDialogId);
                  clearTimeout(this.timeOutId);
                  this.getUIContext().getPromptAction().openCustomDialog({
                    builder: () => this.clickSpeedBuilder(),
                    isModal: false,
                    width: this.displayWidth > CommonConstant.PHONE_WIDTH &&
                      this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH ? CommonConstant.FOLD_FAST_SPEED_WIDTH[0] :
                    CommonConstant.FOLD_FAST_SPEED_WIDTH[1],
                    height: CommonConstant.FOLD_FAST_SPEED_HEIGHT,
                    alignment: DialogAlignment.Center,
                    offset: {
                      dx: CommonConstant.FOLD_FAST_SPEED_OFFSET[0],
                      dy: this.displayWidth < CommonConstant.PHONE_WIDTH ? CommonConstant.FOLD_FAST_SPEED_OFFSET[1] :
                      CommonConstant.FOLD_FAST_SPEED_OFFSET[2],
                    },
                    backgroundColor: CommonConstant.SPEED_TEXT_CLICK_BACKGROUND,
                    cornerRadius: this.displayWidth > CommonConstant.PHONE_WIDTH &&
                      this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH ?
                    CommonConstant.FOLD_FAST_SPEED_CORNER_RADIUS[0] : CommonConstant.FOLD_FAST_SPEED_CORNER_RADIUS[1]
                  }).then((dialogId: number) => {
                    this.clickSpeedDialogId = dialogId;
                  });
                  if (this.timeOutId === 0) {
                    setTimeout(() => {
                      this.getUIContext().getPromptAction().closeCustomDialog(this.clickSpeedDialogId);
                    }, CommonConstant.CLOSE_SPEED_TOAST_DURATION);
                  }
                  this.timeOutId = setTimeout(() => {
                    this.getUIContext().getPromptAction().closeCustomDialog(this.clickSpeedDialogId);
                  }, CommonConstant.CLOSE_SPEED_TOAST_DURATION);
                });
            }, (item: PlayerSpeed) => JSON.stringify(item));
          }
          .width(CommonConstant.FIFTY_PERCENT_WIDTH);
        }
        .width(CommonConstant.FULL_PERCENT_WIDTH)
        .margin({
          top: CommonConstant.TEXT_TEXT_MARGIN[1],
          bottom: this.displayWidth > CommonConstant.PHONE_WIDTH &&
            this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH ? CommonConstant.TEXT_TEXT_MARGIN[1] :
          CommonConstant.TEXT_TEXT_MARGIN[0]
        })
        .padding({ left: CommonConstant.RIGHT_MARGIN });

        // report
        Row() {
          Image(CommonConstant.REPORT_IMAGE)
            .width(CommonConstant.REPORT_IMAGE_WIDTH)
            .margin({ right: CommonConstant.ICON_TEXT_MARGIN });
          Text(CommonConstant.getReportText(this.getUIContext()))
            .fontSize(CommonConstant.FAST_SPEED_FONT_SIZE)
            .fontWeight(CommonConstant.CUSTOM_FONT_WEIGHT);
        }
        .width(CommonConstant.FULL_PERCENT_WIDTH)
        .padding({ left: CommonConstant.RIGHT_MARGIN });

        // Bottom button
        if (this.displayWidth > CommonConstant.PHONE_WIDTH && this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH) {
          Button(CommonConstant.getFoldFastSpeedBottomButtonText(this.getUIContext()))
            .width(CommonConstant.NINETY_FIVE_PERCENT_WIDTH)
            .type(ButtonType.Normal)
            .margin({
              top: CommonConstant.SPEED_BUTTON_MARGIN,
              bottom: CommonConstant.SPEED_BUTTON_MARGIN
            })
            .fontColor(CommonConstant.SPEED_BUTTON_FONT_COLOR)
            .borderRadius(CommonConstant.FOLD_FAST_SPEED_BOTTOM_BUTTON_RADIUS)
            .backgroundColor(CommonConstant.LIVE_COMMENTS_REPLY_BACKGROUND_COLOR)
            .onClick(() => {
              this.closeDialog();
            });
        }
      }
      .backgroundColor(CommonConstant.SPEED_BACKGROUND_COLOR)
      .width(this.displayWidth > CommonConstant.PHONE_WIDTH && this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH ?
      CommonConstant.FIFTY_PERCENT_WIDTH : CommonConstant.FULL_PERCENT_WIDTH)
      .height(CommonConstant.TWENTY_FIVE_PERCENT_WIDTH)
      .padding({
        left: CommonConstant.LIVE_COMMENTS_LEFT_MARGIN,
        right: CommonConstant.RIGHT_MARGIN
      })
      .borderRadius({
        topLeft: this.displayWidth > CommonConstant.PHONE_WIDTH &&
          this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH ?
        CommonConstant.FOLD_FAST_SPEED_BORDER_RADIUS : CommonConstant.FAST_SPEED_TOP_BORDER_RADIUS,
        topRight: this.displayWidth > CommonConstant.PHONE_WIDTH &&
          this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH ?
        CommonConstant.FOLD_FAST_SPEED_BORDER_RADIUS : CommonConstant.FAST_SPEED_TOP_BORDER_RADIUS,
        bottomLeft: this.displayWidth > CommonConstant.PHONE_WIDTH &&
          this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH ?
        CommonConstant.FOLD_FAST_SPEED_BORDER_RADIUS : CommonConstant.FAST_SPEED_BOTTOM_BORDER_RADIUS,
        bottomRight: this.displayWidth > CommonConstant.PHONE_WIDTH &&
          this.displayWidth <= CommonConstant.FOLD_PHONE_WIDTH ?
        CommonConstant.FOLD_FAST_SPEED_BORDER_RADIUS : CommonConstant.FAST_SPEED_BOTTOM_BORDER_RADIUS,
      })
      .translate({
        x: this.displayWidth < CommonConstant.PHONE_WIDTH ? CommonConstant.SPEED_OFFSET[0] :
        CommonConstant.FIFTY_PERCENT_WIDTH,
        y: this.displayWidth < CommonConstant.PHONE_WIDTH ? CommonConstant.SPEED_OFFSET[0] :
        CommonConstant.SPEED_OFFSET[1]
      })
      .alignRules({
        bottom: {
          anchor: '__container__',
          align: this.displayWidth < CommonConstant.PHONE_WIDTH ? VerticalAlign.Bottom : VerticalAlign.Center
        },
        right: {
          anchor: '__container__',
          align: this.displayWidth < CommonConstant.PHONE_WIDTH ? HorizontalAlign.End : HorizontalAlign.Center
        }
      })
      .onClick(() => {
        hilog.info(0x0000, 'fastSpeedClick', 'click');
      });
    }
    .onClick(() => {
      this.closeDialog();
    });
  }
}

@Observed
export class SwipeData {
  swipePlayerController: SwipePlayerController = null!;
}
