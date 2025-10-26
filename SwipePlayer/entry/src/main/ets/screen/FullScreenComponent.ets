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

import { PlayerSession, ProgressBar, SwipePlayerController } from '@hadss/swipeplayer';
import { CommonConstant } from '../constant/CommonConstant';
import { fullScreenData, VideoData } from '../model/CommonModel';

@Component
export struct FullScreenComponent {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageLink('isPlaying') isPlaying: boolean = true;
  @StorageLink('isTabShow') isTabShow: boolean = false;
  @State isSliderMoving: boolean = false;
  @State isVerticalScreen: boolean = true;
  @State fullScreenData: fullScreenData = null!;
  @State playerSession: PlayerSession = null!;
  @State isTouch: boolean = true;
  swipePlayerController: SwipePlayerController = null!;
  timer: number = 0;

  aboutToAppear(): void {
    this.timer = setTimeout(() => {
      this.isTouch = false;
    }, CommonConstant.HIDE_TIME);
  }

  build() {
    Column() {
      RelativeContainer() {
        // Return to the top left corner
        Column({ space: CommonConstant.BUTTON_SPACE_SIZE }) {
          Column({ space: CommonConstant.BUTTON_TEXT_SPACE_SIZE }) {
            Text() {
              ImageSpan($r('app.media.back'))
                .width(CommonConstant.RETURN_BUTTON_WIDTH)
                .height(CommonConstant.RETURN_BUTTON_HEIGHT)
                .onClick(() => {
                  this.isTabShow = true;
                  this.swipePlayerController.exitFullScreen();
                })
                .padding({ right: CommonConstant.TEN_RIGHT_PADDING })
                .id('exitFullScreen');
              Span(CommonConstant.getFullScreenMessage(this.getUIContext()))
                .fontColor(Color.White)
                .fontSize(CommonConstant.FULL_SCREEN_TEXT_FONT_SIZE)
                .width(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT)
                .height(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT);

            }.offset({ x: CommonConstant.X_OFFSET[2] });
          };
        }
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Top },
          right: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .offset({ x: CommonConstant.X_OFFSET[2], y: CommonConstant.Y_OFFSET[3] });

        Column() {
          Row() {
            ProgressBar({
              isShowTime: this.isVerticalScreen,
              isSliderMoving: this.isSliderMoving,
              playerSession: this.playerSession,
              trackColor: Color.Gray,
              selectedColor: CommonConstant.SPEED_BUTTON_FONT_COLOR
            })
              .width(CommonConstant.FULL_PERCENT_WIDTH)
              .padding({
                left: CommonConstant.TWENTY_LEFT_PADDING,
                right: CommonConstant.TWENTY_RIGHT_PADDING
              });
          }
          .alignItems(VerticalAlign.Center);
        }
        .width(CommonConstant.FULL_PERCENT_WIDTH)
        .height(CommonConstant.PROGRESS_BAR_HEIGHT)
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .offset({ y: CommonConstant.Y_OFFSET[2] });

        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Image(this.isPlaying ? $r('app.media.pause') : $r('app.media.triangle'))
            .size({
              height: CommonConstant.BOTTOM_IMAGE_SIZE,
              width: CommonConstant.BOTTOM_IMAGE_SIZE
            })
            .alignRules({
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              right: { anchor: '__container__', align: HorizontalAlign.Start }
            })
            .onClick(() => {
              if (this.isPlaying === true) {
                this.swipePlayerController.pause();
                this.isPlaying = false;
              } else {
                this.swipePlayerController.play();
                this.isPlaying = true;
              }
            });
          Image($r('app.media.small'))
            .size({
              height: CommonConstant.BOTTOM_IMAGE_SIZE,
              width: CommonConstant.BOTTOM_IMAGE_SIZE
            })
            .alignRules({
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              right: { anchor: '__container__', align: HorizontalAlign.End }
            })
            .onClick(() => {
              this.swipePlayerController.exitFullScreen();
              this.isTabShow = true;
            });
        }
        .padding({
          left: CommonConstant.FORTY_LEFT_PADDING,
          right: CommonConstant.FORTY_RIGHT_PADDING,
          top: CommonConstant.TEN_TOP_PADDING
        })
        .width(CommonConstant.FULL_PERCENT_WIDTH)
        .height(CommonConstant.BOTTOM_IMAGE_SIZE)
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        });

      }
      .visibility(this.isTouch ? Visibility.Visible : Visibility.None)
      .width(CommonConstant.FULL_PERCENT_WIDTH)
      .height(CommonConstant.FULL_PERCENT_HEIGHT)
      .padding({
        top: this.getUIContext().px2vp(this.topRectHeight),
        bottom: this.getUIContext().px2vp(this.bottomRectHeight)
      });
    }
    .width(CommonConstant.FULL_PERCENT_WIDTH)
    .height(CommonConstant.FULL_PERCENT_HEIGHT)
    .onTouch(() => {
      if (!this.isTouch) {
        this.isTouch = true;
      }
      if (this.timer) {
        clearTimeout(this.timer);
        this.timer = 0;
      }
      this.timer = setTimeout(() => {
        this.isTouch = false;
      }, CommonConstant.HIDE_TIME);
    });
  }
}

@Builder
export function fullScreen(dataObj: ESObject, playerSession: PlayerSession | undefined,
  swipePlayerController: SwipePlayerController): void {
  FullScreenComponent({
    fullScreenData: dataObj as VideoData,
    playerSession: playerSession!,
    swipePlayerController: swipePlayerController
  });
}