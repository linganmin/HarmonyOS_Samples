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

import { inspector } from '@kit.ArkUI';
import {
  PlayerLayoutSize,
  SwipePlayerController,
  PushDirection,
  ProgressBar,
  PlayerSession,
} from '@hadss/swipeplayer';
import { CommonConstant } from '../constant/CommonConstant';
import { CommentsData, VideoData } from '../model/CommonModel';
import { FastSpeed, SwipeData } from './FastSpeed';
import { Comments } from './Comments';

@Component
export struct VerticalScreenComponent {
  @State dialogComponentData: CommentsData = new CommentsData();
  @State verticalScreenData: VideoData = null!;
  @State isSliderMoving: boolean = false;
  @State isVerticalScreen: boolean = true;
  @State isFullButtonShow: boolean = false;
  @State fullMargin: number = 0;
  @StorageLink('isPlaying') isPlaying: boolean = true;
  @StorageLink('isTabShow') isTabShow: boolean = true;
  @StorageLink('displayWidth') displayWidth: number = 0;
  @StorageLink('displayHeight') displayHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageLink('verticalScreenDataIsShow') verticalScreenDataIsShow: boolean = true;
  playerSession: PlayerSession = null!;
  swipePlayerController: SwipePlayerController = null!;
  swipeData: SwipeData = new SwipeData();
  private listener: inspector.ComponentObserver =
    this.getUIContext().getUIInspector().createComponentObserver('onScreenUpdate');
  private setDirection = () => {
    let videoHeight = this.playerSession.getPlayerLayoutSize().getXComponentHeight();
    this.fullMargin = Math.ceil(this.displayHeight - Number(videoHeight)) / 2;
  };

  aboutToAppear(): void {
    this.listener.on('layout', this.setDirection);
    this.swipeData.swipePlayerController = this.swipePlayerController;
    this.isFullButtonShow = this.isCanFullScreen();

    this.playerSession.onEvent('stateChange', (state: string) => {
      if (state === 'prepared' && this.playerSession.avPlayer && this.playerSession.avPlayer?.duration > 0) {
        this.isFullButtonShow = this.isCanFullScreen();
      } else if (state == 'playing') {
        this.isPlaying = true;
      } else if (state == 'paused') {
        this.isPlaying = false;
      }
    });
  }

  aboutToDisappear(): void {
    this.listener.off('layout');
  }

  closeAnimation(playerLayoutSize: PlayerLayoutSize, removeDialog: () => void) {
    this.dialogComponentData.y = CommonConstant.LIVE_COMMENTS_TRANSLATE_Y_ZERO;
    this.getUIContext().animateTo({
      duration: CommonConstant.DURATION_TIME, onFinish: () => {
        this.verticalScreenDataIsShow = true;
        removeDialog();
      }
    }, () => {
      this.dialogComponentData.y = CommonConstant.LIVE_COMMENTS_TRANSLATE_Y_FULL;
      playerLayoutSize.updatePlayerHeight(CommonConstant.FULL_PERCENT_HEIGHT);
      this.verticalScreenDataIsShow = true;
    });
  }

  isCanFullScreen(): boolean {
    let videoWidth = this.playerSession.getPlayerLayoutSize().getXComponentWidth();
    let videoHeight = this.playerSession.getPlayerLayoutSize().getXComponentHeight();
    if (videoWidth > videoHeight) {
      return true;
    } else {
      return false;
    }
  }

  build() {
    RelativeContainer() {
      if (!this.isSliderMoving) {
        Column({ space: CommonConstant.BUTTON_SPACE_SIZE }) {

          Column({ space: CommonConstant.BUTTON_TEXT_SPACE_SIZE }) {
            Image(this.verticalScreenData.publisherImage)
              .width(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT)
              .height(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT)
              .border({ width: CommonConstant.IMAGE_BORDER_WIDTH, color: Color.White })
              .borderRadius(CommonConstant.IMAGE_BORDER_RADIUS);
          };

          Column({ space: CommonConstant.BUTTON_TEXT_SPACE_SIZE }) {
            Image(this.verticalScreenData.isLike ? CommonConstant.CUSTOM_IMAGE[6] : CommonConstant.CUSTOM_IMAGE[0])
              .width(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT)
              .height(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT)
              .id('likeButton')
              .onClick(() => {
                if (this.verticalScreenData.isLike) {
                  this.verticalScreenData.isLike = false;
                  this.verticalScreenData.likesNum -= 1;
                } else {
                  this.verticalScreenData.isLike = true;
                  this.verticalScreenData.likesNum += 1;
                }
              });

            Text(this.verticalScreenData.likesNum.toString())
              .fontColor(CommonConstant.CUSTOM_FONT_COLOR);
          };

          Column({ space: CommonConstant.BUTTON_TEXT_SPACE_SIZE }) {
            Image(CommonConstant.CUSTOM_IMAGE[1])
              .width(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT)
              .height(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT);
            Text(this.verticalScreenData.commentsNum.toString())
              .fontColor(CommonConstant.CUSTOM_FONT_COLOR);
          }
          .id('commentButton')
          .onClick(() => {
            this.isTabShow = false;
            this.verticalScreenDataIsShow = false;
            let withAnimation = false;
            if (this.displayWidth < CommonConstant.PHONE_WIDTH) {
              withAnimation = true;
            }
            this.swipePlayerController.openDialog({
              dialogBuilder: () => wrapBuilder(CommentsBuilder),
              dataObj: this.dialogComponentData
            }, PushDirection.DOWN_TO_UP, 350, withAnimation, () => {
              this.isTabShow = true;
              this.verticalScreenDataIsShow = true;
            });
          });

          Column({ space: CommonConstant.BUTTON_TEXT_SPACE_SIZE }) {
            Image(CommonConstant.CUSTOM_IMAGE[2])
              .width(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT)
              .height(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT);
            Text(this.verticalScreenData.shareNum.toString())
              .fontColor(CommonConstant.CUSTOM_FONT_COLOR);
          };

          if (this.displayWidth > CommonConstant.PHONE_WIDTH) {
            Image(CommonConstant.CUSTOM_IMAGE[5])
              .width(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT)
              .height(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT)
              .onClick(() => {
                this.isTabShow = false;
                this.swipePlayerController.requestFullScreen(false);
                if (this.playerSession.avPlayer?.state === 'playing') {
                  this.isPlaying = true;
                } else {
                  this.isPlaying = false;
                }
              });
          }
        }
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .offset({ x: CommonConstant.X_OFFSET[0], y: CommonConstant.Y_OFFSET[0] });

        if (this.displayWidth < CommonConstant.PHONE_WIDTH && this.isFullButtonShow) {
          Text() {
            Span(CommonConstant.getRequestFullScreen(this.getUIContext()))
              .fontWeight(CommonConstant.CUSTOM_FONT_WEIGHT)
              .fontColor(Color.White);
            Span(' ')
              .letterSpacing(5);
            ImageSpan(CommonConstant.CUSTOM_IMAGE[5])
              .width(CommonConstant.FULL_SCREEN_TEXT_WIDTH);
          }
          .width(CommonConstant.CUSTOM_BUTTON_WIDTH)
          .height(CommonConstant.CUSTOM_IMAGE_WIDTH_OR_HEIGHT)
          .textAlign(TextAlign.Center)
          .padding({
            top: CommonConstant.FiVE_TOP_PADDING,
            right: CommonConstant.TWENTY_RIGHT_PADDING,
            bottom: CommonConstant.FiVE_BOTTOM_PADDING,
            left: CommonConstant.TWENTY_LEFT_PADDING
          })
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End },
          })
          .offset({ y: -this.fullMargin + this.getUIContext().px2vp(this.bottomRectHeight) + CommonConstant.OFFSET_Y })
          .onClick(() => {
            this.isVerticalScreen = false;
            this.swipePlayerController.requestFullScreen();
            this.isTabShow = false;
            if (this.playerSession.avPlayer?.state === 'playing') {
              this.isPlaying = true;
            } else {
              this.isPlaying = false;
            }
          });
        }

        Column({ space: CommonConstant.TEXT_SPACE_SIZE }) {
          Text(this.verticalScreenData.publisherName)
            .fontColor(CommonConstant.CUSTOM_FONT_COLOR);
          Text() {
            Span(this.verticalScreenData.mediaIntro);
          }
          .maxLines(CommonConstant.VIDEO_TEXT_MAX_LINES)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor(CommonConstant.CUSTOM_FONT_COLOR);
        }
        .constraintSize({ maxWidth: CommonConstant.CONSTRAINT_SIZE_MAX_WIDTH })
        .alignItems(HorizontalAlign.Start)
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .offset({ x: CommonConstant.X_OFFSET[1], y: CommonConstant.Y_OFFSET[1] });
      }

      Column() {
        Row() {
          ProgressBar({
            isShowTime: !this.isVerticalScreen,
            isSliderMoving: this.isSliderMoving,
            playerSession: this.playerSession,
            trackColor: Color.Gray,
            selectedColor: CommonConstant.SPEED_BUTTON_FONT_COLOR
          })
            .id('progressBar')
            .width(CommonConstant.FULL_PERCENT_WIDTH)
            .padding({
              left: CommonConstant.TWENTY_LEFT_PADDING,
              right: CommonConstant.TWENTY_RIGHT_PADDING
            });
        }
        .alignItems(VerticalAlign.Center);
      }
      .width(CommonConstant.FULL_PERCENT_WIDTH)
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })
      .offset({ y: CommonConstant.Y_OFFSET[2] });
    }
    .id('onScreenUpdate')
    .width(CommonConstant.FULL_PERCENT_WIDTH)
    .visibility(this.verticalScreenDataIsShow ? Visibility.Visible : Visibility.Hidden)
    .padding({
      top: this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
    .parallelGesture(
      GestureGroup(GestureMode.Parallel,
        LongPressGesture()
          .onAction(() => {
            this.swipePlayerController.openDialog({
              dialogBuilder: () => wrapBuilder(fastSpeedBuilder),
              dataObj: this.swipeData
            }, PushDirection.DOWN_TO_UP, 350, false);
          })
      )
    );
  }
}

@Builder
export function viewScreen(dataObj: ESObject, playerSession: PlayerSession | undefined,
  swipePlayerController: SwipePlayerController): void {
  VerticalScreenComponent({
    verticalScreenData: dataObj as VideoData,
    playerSession: playerSession,
    swipePlayerController: swipePlayerController
  });
}

@Builder
export function fastSpeedBuilder(swipeData: SwipeData, _playerLayoutSize: PlayerLayoutSize, _removeDialog: () => void,
  closeDialog: () => void) {
  FastSpeed({ swipeData: swipeData, closeDialog: closeDialog });
}

@Builder
export function CommentsBuilder(dialogComponentData: CommentsData, playerLayoutSize: PlayerLayoutSize,
  _removeDialog: () => void,
  closeDialog: () => void) {
  Comments({
    playerLayoutSize: playerLayoutSize,
    closeDialog: closeDialog,
    dialogComponentData: dialogComponentData
  });
}

