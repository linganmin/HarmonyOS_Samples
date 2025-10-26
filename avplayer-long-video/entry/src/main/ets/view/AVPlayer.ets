/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { window } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { media } from '@kit.MediaKit';
import { inputMethod } from '@kit.IMEKit';
import { BusinessError, settings } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BulletCommentView } from './BulletCommentView';
import { BulletComment } from '../model/BulletCommentModel';
import { CaptionFontView } from './CaptionFontView';
import { CaptionFont, registerMyFont } from '../model/CaptionFontModel';
import { VolumeAndBrightnessView } from './VolumeAndBrightnessView';
import { VideoSnapshotView } from './VideoSnapshotView';
import { TimeUtil } from '../common/utils/TimeUtils';
import { CommonConstants, ScreenShotConstants } from '../common/constants/CommonConstants';
import { VideoData } from '../model/VideoData';
import { AvPlayerController } from '../controller/AvPlayerController';
import { PiPWindowController } from '../controller/PipWindowController';
import { SpeedDialog } from './SpeedDialog';
import { LanguageDialog } from './LanguageDialog';

const TAG = '[AVPlayer]';

@Component
export struct AVPlayer {
  @Prop @Watch('onFullScreenChange') isFullLandscapeScreen: boolean =
    false; // Whether the video is played in full screen
  // [Start CreatePageShowChangeEvent]
  @Prop @Watch('onPageShowChange') isPageShow: boolean = false; // Whether the app is on the front end or back end
  // [End CreatePageShowChangeEvent]
  @Prop index: number = 0; // The index of each video
  @Prop curSource: VideoData; // Current video
  @Prop @Watch('onIndexChange') curIndex: number = CommonConstants.CURINDEX_DEFAULT_NUM; // The index of playing video
  @StorageLink('isPIPShow') @Watch('onPIPShowChange') isPIPShow: boolean = false; // Whether to show picture in picture
  @State showPopup: boolean = false; // Control pop-up display
  @State avPlayerController: AvPlayerController = new AvPlayerController(); // The instance of AvPlayer
  @State isSliderDragging: boolean = false; // Whether in the slider dragging state
  @State visible: boolean = false; // Whether to show slider/image
  @State volume: number = 5; // Set original video volume number
  @State screenBrightness: number = 0; // Screen luminance
  @State showBulletComment: boolean = true; // Whether to show bullet comments
  @State bulletComments: BulletComment[] = []; // Bullet comments storage array
  @State bulletCommentInput: string = ''; // User input bullet comment
  @State captionFont: CaptionFont = {
    family: 'Sans',
    size: 14,
    color: Color.White
  }; // Default font style
  @State isShowCaptionConfig: boolean = false; // Whether to show CaptionFontComponent
  @State imgWidth: number = 0; // The width of video snapshot image
  @State imgHeight: number = 0; // The height of video snapshot image
  @State screenshotTime: number = 0; // Video snapshot time
  @State showImg: boolean = false; // Whether to show video snapshot image
  @State pixmap: image.PixelMap | undefined = undefined; // Video snapshot image
  @State speedSelect: number = 0; // Speed Magnification Selection
  @State speedIndex: number = 0; // Index of the playback rate list.
  @State speedName: Resource = $r('app.string.video_speed_1_0X');
  @State isMuted: boolean = false; // Whether is sound off
  @State languageSelect: number = 0; // Index of the current selection
  @State currentLanguageType: number = 0; // Current language type
  private presetBulletCommentsTimerId: number = -1; // The timer of preset bullet comments
  private presetBulletComments =
    [$r('app.string.comment1'), $r('app.string.comment2'), $r('app.string.comment3')]; // Preset bullet comments
  private xComponentController = new XComponentController(); // The instance of XComponent
  onFullScreenClick: (isLandscape?: boolean) => void = () => {
  };
  private screenWidth: number = 0; //Screen width
  private screenHeight: number = 0; // Screen height
  private orgScreenBrightness: number = 0; //The original screen brightness
  private isInputtingBulletComment: boolean = false; // Whether is inputting bullet comment
  private pipWindowController: PiPWindowController =
    new PiPWindowController(this.avPlayerController, this.xComponentController); // The instance of picture in picture
  private speedDialogController: CustomDialogController = new CustomDialogController({
    builder: SpeedDialog({
      speedSelect: this.speedSelect,
      speedIndex: this.speedIndex,
      speedName: this.speedName,
      avPlayerController: this.avPlayerController
    }),
    alignment: DialogAlignment.Center,
    offset: { dx: $r('app.float.size_zero'), dy: $r('app.float.size_down_20') }
  });
  private languageDialogController: CustomDialogController = new CustomDialogController({
    builder: LanguageDialog({
      languageSelect: this.languageSelect,
      currentLanguageType: this.currentLanguageType,
      avPlayerController: this.avPlayerController
    }),
    alignment: DialogAlignment.Center,
    offset: { dx: $r('app.float.size_zero'), dy: $r('app.float.size_down_20') }
  });

  aboutToAppear(): void {
    let windowClass: window.Window | undefined = undefined;
    const context = this.getUIContext().getHostContext();
    registerMyFont(this.getUIContext());
    settings.getValue(context, settings.display.SCREEN_BRIGHTNESS_STATUS, settings.domainName.DEVICE_SHARED)
      .then((value) => {
        this.screenBrightness = Number(value) / 255;
        this.orgScreenBrightness = Number(value) / 255;
      })

    try {
      window.getLastWindow(this.getUIContext().getHostContext(), (err: BusinessError, data: window.Window) => {
        if (err.code) {
          hilog.error(0x0000, TAG,
            `Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
        }
        windowClass = data;
        this.screenWidth = windowClass.getWindowProperties().windowRect.width;
        this.screenHeight = windowClass.getWindowProperties().windowRect.height;
      })
    } catch (exception) {
      hilog.error(0x0000, TAG,
        `Failed to obtain the top window. Cause code: ${exception.code}, message: ${exception.message}`);
    }
  }

  aboutToDisappear(): void {
    this.avPlayerController.videoRelease();
    if (this.presetBulletCommentsTimerId > 0) {
      clearInterval(this.presetBulletCommentsTimerId);
    }
  }

  onFullScreenChange() {
    if (this.isFullLandscapeScreen && this.index === this.curIndex) {
      // Enter full screen mode, start to show preset bullet comment
      this.generatePresetBulletComments();
    } else if (!this.isFullLandscapeScreen && this.index === this.curIndex) {
      //exist full screen mode, set screen brightness back to original number
      this.setScreenBrightness(this.orgScreenBrightness);
      // Exist full screen mode, set CaptionFontView invisible
      this.isShowCaptionConfig = false;
      // Exist full screen mode, set videoSnapshotView invisible
      this.showImg = false;
      this.imgWidth = 0;
      this.imgHeight = 0;
      // Exist full screen mode, clear timer
      if (this.presetBulletCommentsTimerId > 0) {
        clearInterval(this.presetBulletCommentsTimerId);
      }
    }
  }

  // [Start OnPageShowChange]
  onPageShowChange() {
    if (!this.isPIPShow && this.curIndex === this.index) {
      this.isPageShow ? this.resumePlayback() : this.pausePlay();
    }
  }

  // [End OnPageShowChange]

  // Click videoList, switch video to play
  onIndexChange() {
    if (this.curIndex !== this.index) {
      this.avPlayerController.videoPause();
      this.pipWindowController.destroyPipController();
    } else {
      if (this.avPlayerController.isReady === true) {
        this.avPlayerController.videoPlay();
        this.onPIPShowChange();
      } else {
        let intervalFlag = setInterval(() => {
          if (this.curIndex !== this.index) {
            clearInterval(intervalFlag);
          }
          if (this.avPlayerController.isReady === true && this.isPageShow) {
            this.avPlayerController.videoPlay();
            clearInterval(intervalFlag);
          }
        }, 100);
      }
    }
  }

  onPIPShowChange() {
    if (this.isPIPShow && this.curIndex === this.index) {
      this.pipWindowController.createPipController();
    } else {
      this.pipWindowController.destroyPipController();
    }
  }

  // Normal mode: playControl
  @Builder
  playControl() {
    Column() {
      if (!this.isFullLandscapeScreen) {
        Row({ space: 5 }) {
          Text(TimeUtil.millisecondsToTime(this.avPlayerController.currentTime))
            .fontSize($r('app.float.font_size_12'))
            .fontColor(Color.White)
            .opacity($r('app.float.opacity_9'))

          Slider({
            value: this.avPlayerController.currentTime,
            min: CommonConstants.SLIDER_MIN,
            max: this.avPlayerController.durationTime,
            step: CommonConstants.SLIDER_STEP,
            direction: Axis.Horizontal,
            style: SliderStyle.OutSet
          })
            .height($r('app.float.size_24'))
            .trackColor($r('app.color.white_opacity_1_color'))
            .showSteps(false)
            .blockSize({ width: 16, height: 16 })
            .blockColor(Color.White)
            .layoutWeight(1)
            .trackThickness(6)
            .trackBorderRadius(CommonConstants.TRACK_BORDER_RADIUS)
            .selectedBorderRadius(CommonConstants.TRACK_BORDER_RADIUS)
            .zIndex(CommonConstants.SLIDER_INDEX)
            .onChange((value: number, mode: SliderChangeMode) => {
              this.sliderOnchange(value, mode);
            })

          Text(TimeUtil.millisecondsToTime(this.avPlayerController.durationTime))
            .fontColor(Color.White)
            .fontSize(12)

          Image($r('app.media.ic_video_menu_landscape_fullscreen'))
            .fillColor($r('sys.color.white'))
            .width($r('app.float.size_24'))
            .height($r('app.float.size_24'))
            .onClick(() => {
              this.onFullScreenClick?.(true);
            })
        }
        .padding({ left: 8, right: 8 })
        .width(CommonConstants.WIDTH_FULL_PERCENT)
      }
    }
    .margin({
      bottom: this.isFullLandscapeScreen ? (AppStorage.get<number>('navBarHeight') || 0) : $r('app.float.margin_small')
    })
  }

  private sliderOnchange(seconds: number, mode: SliderChangeMode) {
    switch (mode) {
      case SliderChangeMode.Begin:
        break;
      case SliderChangeMode.Click:
        break;
      case SliderChangeMode.Moving:
        this.isSliderDragging = true;
        break;
      case SliderChangeMode.End:
        this.avPlayerController.videoSeek(seconds);
        this.isSliderDragging = false;
        break;
      default:
        break;
    }
  }

  async iconOnclick() {
    if (this.avPlayerController.isPlaying) {
      this.avPlayerController.videoPause();
      let context = this.getUIContext().getHostContext() as Context;
      try {
        let windowClass = await window.getLastWindow(context);
        await windowClass.setWindowKeepScreenOn(false);
      } catch (exception) {
        hilog.error(0x0000, TAG,
          `setWindowKeepScreenOn failed: code: ${exception.code}, message: ${exception.message}`);
      }
    } else {
      if (this.avPlayerController.isReady === true) {
        this.avPlayerController.videoPlay();
      }
      let context = this.getUIContext().getHostContext() as Context;
      try {
        let windowClass = await window.getLastWindow(context);
        await windowClass.setWindowKeepScreenOn(true);
      } catch (exception) {
        hilog.error(0x0000, TAG,
          `setWindowKeepScreenOn failed: code: ${exception.code}, message: ${exception.message}`);
      }
    }
  }

  // Full screen mode: playControl and other control button
  @Builder
  fullLandscapeScreenControl() {
    Column() {
      // First row: caption
      Row() {
        Text(this.avPlayerController.currentCaption || '')
          .fontColor(this.captionFont.color)
          .fontSize(this.captionFont.size)
          .fontFamily(this.captionFont.family)
      }
      .height(10)

      // Second row: progress
      Row({ space: 3 }) {
        Text(TimeUtil.millisecondsToTime(this.avPlayerController.currentTime))
          .fontSize($r('app.float.font_size_12'))
          .fontColor(Color.White)
          .opacity($r('app.float.opacity_9'))

        Slider({
          value: this.avPlayerController.currentTime,
          min: CommonConstants.SLIDER_MIN,
          max: this.avPlayerController.durationTime,
          step: CommonConstants.SLIDER_STEP,
          direction: Axis.Horizontal,
          style: SliderStyle.OutSet
        })
          .height($r('app.float.size_24'))
          .trackColor($r('app.color.white_opacity_1_color'))
          .showSteps(false)
          .blockSize({ width: 16, height: 16 })
          .blockColor(Color.White)
          .layoutWeight(1)
          .trackThickness(6)
          .trackBorderRadius(CommonConstants.TRACK_BORDER_RADIUS)
          .selectedBorderRadius(CommonConstants.TRACK_BORDER_RADIUS)
          .zIndex(CommonConstants.SLIDER_INDEX)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.sliderOnchange(value, mode);
          })

        Text(TimeUtil.millisecondsToTime(this.avPlayerController.durationTime))
          .fontSize($r('app.float.font_size_12'))
          .fontColor(Color.White)
          .opacity($r('app.float.opacity_9'))

        Button(this.speedName, { type: ButtonType.Normal })
          .border({ width: $r('app.float.size_1'), color: Color.White })
          .width($r('app.float.size_56'))
          .height($r('app.float.size_25'))
          .fontSize($r('app.float.size_14'))
          .borderRadius($r('app.float.size_20'))
          .fontColor(Color.White)
          .backgroundColor('rgba(0, 0, 0, 0)')
          .opacity($r('app.float.size_1'))
          .padding({ left: $r('app.float.size_5'), right: $r('app.float.size_5') })
          .margin({ left: $r('app.float.size_5') })
          .id('Speed')
          .onClick(() => {
            if (!this.isInputtingBulletComment) {
              this.speedSelect = this.speedIndex;
              this.speedDialogController.open();
            }
          })

        Button() {
          Image(this.isMuted ? $r('app.media.ic_video_speaker_slash') : $r('app.media.ic_video_speaker'))
            .width($r('app.float.size_25'))
            .height($r('app.float.size_25'))
        }
        .type(ButtonType.Normal)
        .width($r('app.float.size_30'))
        .height($r('app.float.size_30'))
        .borderRadius($r('app.float.size_20'))
        .backgroundColor('rgba(0, 0, 0, 0)')
        .fontColor(Color.White)
        .onClick(() => {
          if (!this.isInputtingBulletComment) {
            this.isMuted = !this.isMuted;
            this.avPlayerController.videoMuted(this.isMuted)
          }
        })
      }
      .padding({ left: 8, right: 8 })
      .width(CommonConstants.WIDTH_FULL_PERCENT)
      .backgroundColor($r('app.color.progress_background_color'))

      // Third row: button
      Row({ space: 7 }) {
        // Switch caption language
        Button() {
          Image($r('app.media.ic_video_translate'))
            .width($r('app.float.size_25'))
            .height($r('app.float.size_25'))
        }
        .onClick(() => {
          if (!this.isInputtingBulletComment) {
            this.languageSelect = this.currentLanguageType;
            this.languageDialogController.open();
          }
        })
        .backgroundColor(Color.Transparent)

        // Set caption fontStyle
        Button() {
          Image($r('app.media.character_viewfinder'))
            .width(24)
            .height(24)
        }
        .onClick(() => {
          if (!this.isInputtingBulletComment) {
            this.pausePlay();
            this.isShowCaptionConfig = true;
          }
        })
        .backgroundColor(Color.Transparent)

        // Video snapshot
        Button() {
          Image($r('app.media.screenshot'))
            .width('24vp')
            .height('24vp')
        }
        .onClick(() => {
          if (!this.isInputtingBulletComment) {
            this.pausePlay();
            this.screenshotTime = this.avPlayerController.currentTime;
            this.screenshot();
            this.showImg = true;
            this.getUIContext().animateTo({
              duration: 500,
              iterations: 1,
              playMode: PlayMode.Normal,
            }, () => {
              this.imgWidth = 375;
              this.imgHeight = 166;
            })
          }
        })
        .backgroundColor(Color.Transparent)

        TextInput({ text: this.bulletCommentInput, placeholder: $r('app.string.placeholder') })
          .backgroundColor('rgba(255,255,255,0.4)')
          .placeholderColor('rgba(255,255,255,0.7)')
          .placeholderFont({ size: 14 })
          .padding({ top: 0, bottom: 0 })
          .fontColor(Color.White)
          .onFocus(() => {
            this.pausePlay();
            this.isInputtingBulletComment = true;
          })
          .onBlur(() => {
            this.resumePlayback();
            this.isInputtingBulletComment = false;
          })
          .height(30)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.bulletCommentInput = value;
          })

        Button() {
          Image($r('app.media.send_bulletcomment'))
            .width(24)
            .height(24)
        }
        .padding({ left: 2 })
        .onClick(() => {
          try {
            inputMethod.getController().stopInputSession().catch((err: BusinessError) => {
              hilog.error(0x0000, TAG, `stopInputSession failed. Code:${err.code}, message:${err.message}`);
            });
          } catch (exception) {
            hilog.error(0x0000, TAG, `getController failed: code: ${exception.code}, message: ${exception.message}`);
          }
          this.sendBulletComment();
        })
        .backgroundColor(Color.Transparent)
      }
      .height('20%')
      .margin({ top: 5 })
      .padding({ left: 8, right: 15 })
      .width(CommonConstants.WIDTH_FULL_PERCENT)
    }
    .height('40%')
    .width('100%')
    .position({ y: '77%' })
  }

  // [Start PausePlay]
  private pausePlay() {
    if (this.avPlayerController.isPlaying) {
      this.avPlayerController.videoPause();
    }
  }

  // [End PausePlay]

  // [Start Playback]
  private resumePlayback() {
    if (!this.avPlayerController.isPlaying) {
      this.avPlayerController.videoPlay();
    }
  }

  // [End Playback]

  // [Start SendBulletComment]
  private sendBulletComment() {
    if (this.bulletCommentInput.trim()) {
      this.bulletComments = [...this.bulletComments, new BulletComment(this.bulletCommentInput, true)];
      this.bulletCommentInput = '';
      if (this.bulletComments.length > 50) {
        this.bulletComments = this.bulletComments.slice(1);
      }
    }
    this.resumePlayback(); // Resume video playback after sending
  }

  // [End SendBulletComment]

  private generatePresetBulletComments() {
    if (this.presetBulletCommentsTimerId > 0) {
      clearInterval(this.presetBulletCommentsTimerId);
    }
    this.presetBulletCommentsTimerId = setInterval(() => {
      let randomIndex = Math.floor(Math.random() * 3);
      this.bulletComments = [...this.bulletComments, new BulletComment(this.presetBulletComments[randomIndex])];
    }, 2000)
  }

  private closeCaptionSetting(captionFont: CaptionFont | null) {
    this.isShowCaptionConfig = false;
    if (captionFont) {
      this.captionFont = captionFont;
    }
    this.resumePlayback();
  }

  // [Start VideoSnapshot]
  private async screenshot() {
    try {
      this.pixmap = await this.getUIContext().getComponentSnapshot().get(`videoXComponent_${this.curSource.index}`);
    } catch (exception) {
      hilog.error(0x0000, TAG, `screenshot failed: code: ${exception.code}, message: ${exception.message}`);
    }
  }

  // [End VideoSnapshot]

  // [Start GetLastFrame]
  private async clickPreviousFrame() {
    this.avPlayerController?.videoSeek(this.screenshotTime - 1000 / ScreenShotConstants.FRAME_RATE);
    this.pausePlay();
    setTimeout(() => {
      this.screenshot()
    }, 500)
    this.screenshotTime -= 1000 / ScreenShotConstants.FRAME_RATE
  }

  // [End GetLastFrame]

  // [Start GetNextFrame]
  private async clickNextFrame() {
    this.avPlayerController?.videoSeek(this.screenshotTime + 1000 / ScreenShotConstants.FRAME_RATE);
    this.pausePlay();
    setTimeout(() => {
      this.screenshot()
    }, 500)
    this.screenshotTime += 1000 / ScreenShotConstants.FRAME_RATE
  }

  // [End GetNextFrame]

  private setScreenBrightness(brightness: number) {
    let windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
    try {
      let mainWin: window.Window = windowStage.getMainWindowSync();
      mainWin.setWindowBrightness(brightness, (err: BusinessError) => {
        if (err.code) {
          hilog.error(0x0000, TAG,
            `Failed to set the brightness. code is ${err.code}, message is ${err.message}`);
          return;
        }
      });
    } catch (exception) {
      hilog.error(0x0000, TAG, `getMainWindowSync failed: code: ${exception.code}, message: ${exception.message}`);
    }
  }

  private getValidValue(inputValue: number, minValue: number, maxValue: number): number {
    inputValue = inputValue >= maxValue ? maxValue : inputValue;
    inputValue = inputValue <= minValue ? minValue : inputValue;
    return inputValue;
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Stack({ alignContent: Alignment.Center }) {
        if (!this.avPlayerController.isPlaying) {
          Row() {
            // Video pause image
            Image($r('app.media.ic_video_menu_play'))
              .width(this.isFullLandscapeScreen ? $r('app.float.icon_size_large') : $r('app.float.size_36'))
              .aspectRatio(1)
          }
          .width(CommonConstants.WIDTH_FULL_PERCENT)
          .justifyContent(this.isFullLandscapeScreen ? FlexAlign.SpaceEvenly : FlexAlign.SpaceAround)
          .zIndex(CommonConstants.Z_INDEX_VIDEO_PLAY)
        }
        Column() {
          Stack() {
            XComponent({
              type: XComponentType.SURFACE,
              controller: this.xComponentController
            })
              .id(`videoXComponent_${this.curSource.index}`)
              .onLoad(async () => {
                this.xComponentController.setXComponentSurfaceRect({
                  surfaceWidth: CommonConstants.SURFACE_WIDTH, surfaceHeight: CommonConstants.SURFACE_HEIGHT
                });
                try {
                  const avPlayer = await media.createAVPlayer();
                  this.avPlayerController.initAVPlayer(avPlayer, this.curSource,
                    this.xComponentController.getXComponentSurfaceId());
                } catch (exception) {
                  hilog.error(0x0000, TAG,
                    `createAVPlayer failed: code: ${exception.code}, message: ${exception.message}`);
                }
              })
              .aspectRatio(CommonConstants.ASPECT)

            if (this.isFullLandscapeScreen) {
              BulletCommentView({
                bulletComments: this.bulletComments,
                showBulletComment: this.showBulletComment
              })
                .width('100%')
                .height(200)
                .position({ x: '0%', y: '5%' })

              VolumeAndBrightnessView({
                visible: this.visible,
                volume: this.volume,
                screenBrightness: this.screenBrightness
              });
              this.fullLandscapeScreenControl();
            }
          }
        }
        .justifyContent(FlexAlign.Center)
        .width(CommonConstants.WIDTH_FULL_PERCENT)
        .height(CommonConstants.HEIGHT_FULL_PERCENT)
        .zIndex(CommonConstants.Z_INDEX_BASE)
      }
      .width(CommonConstants.WIDTH_FULL_PERCENT)
      .height(CommonConstants.HEIGHT_FULL_PERCENT)
      .onClick(() => {
        this.iconOnclick();
      })
      // [Start SetScreenBrightnessPanGesture]
      .gesture(
        // Sliding in the vertical direction
        PanGesture({ direction: PanDirection.Vertical })
          .onActionStart(() => {
          })
          .onActionUpdate((event: GestureEvent) => {
            // The area on the right side of the screen
            if (event.fingerList[0].globalX > (this.screenWidth / 2)) {
              if (this.isInputtingBulletComment) {
                return; // When inputting bullet comment, disable screen brightness change
              }
              this.visible = true;
              let curBrightness = this.screenBrightness -
                this.getUIContext().vp2px(event.offsetY) / this.getUIContext().vp2px(this.screenHeight);
              curBrightness = this.getValidValue(curBrightness, 0.0, 1.0);
              this.screenBrightness = curBrightness;
              this.setScreenBrightness(this.screenBrightness);
            } else {
              this.visible = false;
              let curVolume = this.volume - this.getUIContext().vp2px(event.offsetY) / this.screenHeight;
              curVolume = this.getValidValue(curVolume, 0.0, 15.0);
              this.volume = curVolume;
            }
          })
          .onActionEnd(() => {
            setTimeout(() => {
              this.visible = false;
            }, 3000)
          })
      )

      // [End SetScreenBrightnessPanGesture]

      this.playControl();

      if (this.isShowCaptionConfig) {
        CaptionFontView({
          captionFont: this.captionFont,
          close: (captionFont: CaptionFont | null) => {
            this.closeCaptionSetting(captionFont);
          }
        })
      }

      if (this.showImg) {
        VideoSnapshotView({
          imgWidth: this.imgWidth,
          imgHeight: this.imgHeight,
          pixmap: this.pixmap,
          showImg: this.showImg,
          onPreviousClick: () => {
            this.clickPreviousFrame();
          },
          onNextClick: () => {
            this.clickNextFrame();
          }
        });
      }
    }
    .width(CommonConstants.WIDTH_FULL_PERCENT)
    .height(CommonConstants.HEIGHT_FULL_PERCENT)
    .backgroundColor(Color.Black)
  }
}