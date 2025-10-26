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

import { componentUtils, window } from '@kit.ArkUI';
import { BusinessError, settings } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { audio, AVVolumePanel } from '@kit.AudioKit';
import { Logger, CommonConstants, secondToTime, } from '@ohos/MediaService';
import { AvPlayerController, VideoData } from '@ohos/MediaService';
import { FullScreenControl, VideoBottom } from './VideoSide';
import { common } from '@kit.AbilityKit';

const TAG = '[VideoPlayer]';

@Preview
@Component
export struct VideoPlayer {
  @Consume('pageInfo') pageInfo: NavPathStack;
  @BuilderParam videoRightSide?: () => void;
  @BuilderParam videoDes?: () => void;
  @Prop isFullLandscapeScreen: boolean = false;
  @Prop isFullScreen: boolean = false;
  @Prop isFloatWindow: boolean = false;
  @Prop isPageShow: boolean = false;
  @Prop index: number = 0;
  @Prop curSource: VideoData;
  @Prop @Watch('onIndexChange') curIndex: number = CommonConstants.CURINDEX_DEFAULT_NUM;
  @State isTimeDisplay: number = 0;
  @State trackThicknessSize: number = CommonConstants.TRACK_SIZE_MIN;
  @State avPlayerController: AvPlayerController = new AvPlayerController(this.curSource, this.getUIContext());
  @State sliderStyle: SliderStyle = SliderStyle.NONE;
  @State isShowTips: boolean = false;
  @State isSliderDragging: boolean = false;
  @State isSliderGesture: boolean = false;
  @State currentStringTime: string = '00:00';
  @State tipsOffset: number = 0;
  @State offsetY: number = 0;
  @State value: number = 0;
  @State beginX: number = 0;
  @State panEndTime: number = 0;
  @State volume: number = 0;
  @State visible: boolean = false;
  @State screenBrightness: number = 0;
  private xComponentController = new XComponentController();
  private showTipsTime: string = '';
  private slideWidth: number = 130;
  private blockSize: number = 16;
  private hideTipTask?: number;
  private panStartX: number = 0;
  private panStartTime: number = 0;
  onFullScreenClick: (isLandscape?: boolean) => void = () => {
  };
  private screenHeight: number = 0;
  private windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  // Get the main window.
  private mainWin: window.Window | null = null;
  uiContext = this.getUIContext()

  aboutToAppear(): void {
    try {
      this.mainWin = this.windowStage.getMainWindowSync();
    } catch (error) {
      hilog.error(0x0000, 'AVPlayer', `getMainWindowSync failed. Cause code: ${error.code}, message: ${error.message}`);
    }
    const context = this.uiContext.getHostContext() as common.UIAbilityContext;
    settings.getValue(context, settings.display.SCREEN_BRIGHTNESS_STATUS, settings.domainName.DEVICE_SHARED)
      .then((value) => {
        hilog.info(0x0000, 'AVPlayer', `Promise:value -> ${JSON.stringify(value)}`);
        this.screenBrightness = Number(value) / 255;
      })

    window.getLastWindow(context)
      .then((data) => {
        try {
          this.screenHeight = data?.getWindowProperties().windowRect.height;
        } catch (exception) {
          hilog.error(0x0000, 'AVPlayer', `Failed to obtain the top window. Cause code: ${exception.code}, message: ${exception.message}`);
        }
      })
     .catch((error: BusinessError) => {
        hilog.error(0x0000, 'AVPlayer', `Failed to obtain the top window. Cause code: ${error.code}, message: ${error.message}`);
     })
    let groupId: number = audio.DEFAULT_VOLUME_GROUP_ID;
    let audioManager = audio.getAudioManager();
    let audioVolumeManger: audio.AudioVolumeManager = audioManager.getVolumeManager();

    audioVolumeManger.getVolumeGroupManager(groupId, (err: BusinessError, value: audio.AudioVolumeGroupManager) => {
      if (err) {
        hilog.error(0x0000, 'AVPlayer', `Failed to obtain the colume group infos list. ${err}`);
        return;
      }
      let audioVolumeGroupManager = value;
      hilog.info(0x0000, 'AVPlayer', `Callback invoked to indicate that the volume group infos list is obtained.`);

      audioVolumeGroupManager.getVolume(audio.AudioVolumeType.MEDIA, (err: BusinessError, value: number) => {
        if (err) {
          hilog.error(0x0000, 'AVPlayer', `Failed to obtain the volume. ${err}`);
          return;
        }
        this.volume = value;
        hilog.info(0x0000, 'AVPlayer', `Callback invoked to indicate that the volume is obtained. ${value}`);
      });

      audioVolumeGroupManager.getMaxVolume(audio.AudioVolumeType.MEDIA, (err: BusinessError, value: number) => {
        if (err) {
          hilog.error(0x0000, 'AVPlayer', `Failed to obtain the maximum volume. ${err}`);
          return;
        }
        hilog.info(0x0000, 'AVPlayer', `Callback invoked to indicate that the maximum volume is obtained. ${value}`);
      });

      audioVolumeGroupManager.getMinVolume(audio.AudioVolumeType.MEDIA, (err: BusinessError, value: number) => {
        if (err) {
          hilog.error(0x0000, 'AVPlayer', `Failed to obtain the minimum volume. ${err}`);
          return;
        }
        hilog.info(0x0000, 'AVPlayer', `Callback invoked to indicate that the minimum volume is obtained. ${value}`);
      });
    });
  }

  onIndexChange() {
    this.avPlayerController.setCurIndex(this.curIndex);
    Logger.info(TAG, `enter onIndexChange. ` +
      ` this.curIndex:${this.curIndex} this.index:${this.index}`);
    if (this.curIndex !== this.index) {
      this.avPlayerController.pauseVideo();
      this.avPlayerController.setIsPlaying(false);
      this.trackThicknessSize = CommonConstants.TRACK_SIZE_MIN;
    } else {
      Logger.info(TAG, `enter indexChange play. ` +
        ` isReady:${this.avPlayerController.isReady}, this.curIndex:${this.curIndex} this.index:${this.index}`);
      if (this.avPlayerController.isReady === true) {
        this.showTip(this.avPlayerController.currentTime);
        this.avPlayerController.playVideo();
        this.avPlayerController.setIsPlaying(true);
        this.trackThicknessSize = CommonConstants.TRACK_SIZE_MIN;
      } else {
        let countNum = 0;
        let intervalFlag = setInterval(() => {
          countNum++;
          if (this.curIndex !== this.index) {
            Logger.info(TAG, `[ enter indexChange play error, clearInterval. ` +
              ` isReady:${this.avPlayerController.isReady}, this.curIndex:${this.curIndex} this.index:${this.index}`);
            clearInterval(intervalFlag);
          }
          if (this.avPlayerController.isReady === true && this.isPageShow) {
            countNum = 0;
            this.avPlayerController.playVideo();
            this.avPlayerController.setIsPlaying(true);
            this.trackThicknessSize = CommonConstants.TRACK_SIZE_MIN;
            clearInterval(intervalFlag);
          } else {
            Logger.info(TAG, `enter indexChange play error. ` +
              ` countNum:${countNum} isReady:${this.avPlayerController.isReady}, ` +
              ` this.curIndex:${this.curIndex} this.index:${this.index}`);
            if (countNum > 15) {
              Logger.info(TAG, `enter indexChange play error, reinit  initAVPlayer. ` +
                ` countNum:${countNum} isReady:${this.avPlayerController.isReady}, ` +
                ` this.curIndex:${this.curIndex} this.index:${this.index}`);
              countNum = 0;
              this.showTip(this.avPlayerController.currentTime);
              this.avPlayerController.initAVPlayer();
            }
          }
        }, 100);
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Stack({ alignContent: Alignment.Center }) {
        if (!this.avPlayerController.isPlaying) {
          Row() {
            Image($r('app.media.ic_video_menu_backward'))
              .width(this.isFloatWindow ? $r('app.float.size_24') : $r('app.float.icon_size_large'))
              .aspectRatio(1)
              .margin({ left: $r('app.float.margin_padding_lg') })
              .visibility(this.isFloatWindow ? Visibility.Visible : Visibility.Hidden)
              .monopolizeEvents(true)
              .onClick(() => {
                this.avPlayerController.seek((this.avPlayerController.currentTime - 10) * 1000);
              })
            Image($r('app.media.ic_video_menu_play'))
              .width(this.isFloatWindow ? $r('app.float.size_24') : $r('app.float.icon_size_large'))
              .aspectRatio(1)
              .visibility(this.isFullScreen || this.isFullLandscapeScreen || this.isFloatWindow ?
              Visibility.Visible : Visibility.Hidden)
            Image($r('app.media.ic_video_menu_forward'))
              .monopolizeEvents(true)
              .width(this.isFloatWindow ? $r('app.float.size_24') : $r('app.float.icon_size_large'))
              .aspectRatio(1)
              .visibility(this.isFloatWindow ? Visibility.Visible : Visibility.Hidden)
              .margin({ right: $r('app.float.margin_padding_lg') })
              .onClick(() => {
                this.avPlayerController.seek((this.avPlayerController.currentTime + 10) * 1000);
              })
          }
          .width(CommonConstants.WIDTH_FULL_PERCENT)
          .justifyContent(this.isFullLandscapeScreen ? FlexAlign.SpaceEvenly : FlexAlign.SpaceAround)
          .zIndex(CommonConstants.Z_INDEX_VIDEO_PLAY)
        }
        Column() {
          Stack() {
            XComponent({
              id: 'XComponent',
              type: XComponentType.SURFACE,
              controller: this.xComponentController
            })
              .onLoad(async () => {
                this.xComponentController.setXComponentSurfaceRect({
                  surfaceWidth: CommonConstants.SURFACE_WIDTH, surfaceHeight: CommonConstants.SURFACE_HEIGHT
                });
                this.avPlayerController.setSurfaceID(this.xComponentController.getXComponentSurfaceId());
                Logger.info(TAG,
                  'surfaceID= ${this.avPlayerController.surfaceID} ' +
                    ` this.curIndex:${this.curIndex} this.index:${this.index}`);
                this.avPlayerController.initAVPlayer();
              })
              .aspectRatio(CommonConstants.ASPECT)

            if (this.isFullLandscapeScreen) {
              Row() {
                Column() {
                  AVVolumePanel({
                    volumeLevel: this.volume,
                    volumeParameter: {
                      position: {
                        x: 150,
                        y: 300
                      }
                    }
                  })
                }
                .width('50%')

                Column() {
                  Stack() {
                    Slider({
                      value: this.screenBrightness,
                      min: 0,
                      max: 1,
                      step: 0.1,
                      style: SliderStyle.NONE,
                      direction: Axis.Vertical,
                      reverse: true
                    })
                      .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
                      .height(160)
                      .selectedColor(Color.White)
                      .trackColor(Color.Black)
                      .trackThickness(40)

                    Image($r('app.media.sun_max_fill'))
                      .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
                      .margin({ top: 120 })
                      .width(20)
                      .height(20)
                  }
                  .margin({
                    top: 0,
                    right: 0
                  })
                }
                .alignItems(HorizontalAlign.End)
                .justifyContent(FlexAlign.Center)
                .padding({
                  right: 30,
                  bottom: 20
                })
                .height('100%')
                .width('50%')
              }
              .height('100%')
              .width('100%')
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
      .gesture(
        PanGesture({ direction: PanDirection.Vertical })
          .onActionStart(() => {

          })
          .onActionUpdate((event: GestureEvent) => {
            if (event.fingerList[0].globalX > (820 / 2)) {
              this.visible = true;
              let curBrightness = this.screenBrightness - this.uiContext.vp2px(event.offsetY) / this.uiContext.vp2px(this.screenHeight);
              curBrightness = curBrightness >= 1.0 ? 1.0 : curBrightness;
              curBrightness = curBrightness <= 0.0 ? 0.0 : curBrightness;
              this.screenBrightness = curBrightness;
              hilog.info(0x0000, 'AVPlayer', `this brightness is: ` + this.screenBrightness);

              try {
                this.mainWin?.setWindowBrightness(this.screenBrightness, (err) => {
                  if (err) {
                    hilog.error(0x0000, 'AVPlayer', `Failed to set the brightness. Cause: ${JSON.stringify(err)}`);
                    return;
                  }
                  hilog.info(0x0000, 'AVPlayer', `Succeeded in setting the brightness.`);
                });
              } catch (exception) {
                hilog.error(0x0000, 'AVPlayer', `Failed to set the brightness.`);
              }
            } else {
              this.visible = false;
              let curVolume = this.volume - this.uiContext.vp2px(event.offsetY) / this.screenHeight;
              curVolume = curVolume >= 15.0 ? 15.0 : curVolume;
              curVolume = curVolume <= 0.0 ? 0.0 : curVolume;
              this.volume = curVolume;
              hilog.info(0x0000, 'AVPlayer', `this volume is: ` + this.volume);
            }
          })
          .onActionEnd(() => {
            setTimeout(() => {
              this.visible = false;
            }, 3000)
          })
      )

      if (!this.isSliderDragging) {
        this.videoRightSide?.();
      }
      Column() {
        this.PlayControl();
        VideoBottom({
          isFullScreen: this.isFullScreen,
          onFullScreenClick: (isLandScape?: boolean) => this.onFullScreenClick?.(isLandScape),
        })
          .visibility(!this.isFullScreen || this.isFullLandscapeScreen || this.isFloatWindow ||
          this.isSliderDragging ? Visibility.None : Visibility.Visible)
          .margin({ bottom: this.isFullScreen ? (AppStorage.get<number>('navBarHeight') || 0) : 0 })
          .width(CommonConstants.WIDTH_FULL_PERCENT)
      }
      .zIndex(CommonConstants.Z_INDEX_MAX)
    }
    .width(CommonConstants.WIDTH_FULL_PERCENT)
    .height(CommonConstants.HEIGHT_FULL_PERCENT)
    .backgroundColor(Color.Black)
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionStart((event: GestureEvent) => {
          this.isSliderGesture = true;
          this.panStartX = event.offsetX;
          this.panStartTime = this.avPlayerController.currentTime;
          this.sliderOnchange(this.panStartTime, SliderChangeMode.Begin);
        })
        .onActionUpdate((event: GestureEvent) => {
          this.isSliderGesture = true;
          let panTime =
            this.panStartTime +
              (this.panStartX + event.offsetX) / this.slideWidth * this.avPlayerController.durationTime;
          this.panEndTime = Math.min(Math.max(0, panTime), this.avPlayerController.durationTime);
          this.sliderOnchange(this.panEndTime, SliderChangeMode.Moving);
        })
        .onActionEnd(() => {
          this.sliderOnchange(this.panEndTime, SliderChangeMode.End);
          this.isSliderGesture = false;
        })
    )
  }

  // The popup constructor defines the content of the dialog box
  @Builder
  popupBuilder() {
    Row({ space: 2 }) {
      Text($r('app.string.last_history', this.showTipsTime))
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('sys.color.font_primary'))
    }
    .height($r('app.float.size_44'))
    .padding({ left: $r('app.float.size_16'), right: $r('app.float.size_16') })
  }

  private showTip(value: number) {
    if (value > 0 && this.isFullScreen) {
      this.showTipsTime = this.avPlayerController.currentStringTime;
      this.isShowTips = true;
      let percent = Number((value / this.avPlayerController.durationTime).toFixed(2));
      this.tipsOffset = this.uiContext.px2vp(this.beginX) + (this.slideWidth - 16) * percent;
      this.hideTip();
    }
  }

  private hideTip() {
    clearTimeout(this.hideTipTask);
    this.hideTipTask = setTimeout(() => {
      this.isShowTips = false;
    }, 1000);
  }

  @Builder
  PlayControl() {
    Column() {
      Row() {
        Text(this.currentStringTime)
          .fontSize($r('app.float.font_size_14'))
          .fontColor(Color.White)
          .opacity($r('app.float.opacity_9'))
          .margin({ left: CommonConstants.TEXT_MARGIN_LEFT })
          .width(CommonConstants.TEXT_LEFT_WIDTH)
          .textAlign(TextAlign.End)
          .zIndex(CommonConstants.SLIDER_INDEX)
        Divider()
          .vertical(true)
          .height($r('app.float.padding_14'))
          .width(CommonConstants.DIVIDER_WIDTH)
          .backgroundBlurStyle(BlurStyle.Regular, { colorMode: ThemeColorMode.LIGHT })
          .color(Color.White)
          .opacity($r('app.float.opacity_9'))
          .margin({ left: $r('app.float.margin_small'), right: $r('app.float.margin_small') })
          .rotate({
            x: CommonConstants.DIVIDER_X,
            y: CommonConstants.DIVIDER_Y,
            z: CommonConstants.DIVIDER_Z,
            centerX: CommonConstants.DIVIDER_CENTER_X,
            centerY: CommonConstants.DIVIDER_CENTER_Y,
            angle: CommonConstants.DIVIDER_ANGLE
          })
        Text(this.avPlayerController.durationStringTime)
          .fontSize($r('app.float.font_size_14'))
          .fontColor(Color.White)
          .margin({ right: CommonConstants.TEXT_MARGIN_LEFT })
          .width(CommonConstants.TEXT_LEFT_WIDTH)
          .textAlign(TextAlign.Start)
          .opacity($r('app.float.opacity_4'))
          .zIndex(CommonConstants.SLIDER_INDEX)
      }
      .margin({ bottom: $r('app.float.margin_small') })
      .alignItems(VerticalAlign.Center)
      .opacity(this.isTimeDisplay)

      if (!this.isSliderDragging) {
        this.videoDes?.();
      }
      Column() {
        Row() {
          Image(this.avPlayerController.isPlaying ? $r('sys.media.ohos_ic_public_pause') :
          $r('app.media.ic_video_menu_play'))
            .width($r('app.float.size_24'))
            .height($r('app.float.size_24'))
            .fillColor(Color.White)
            .margin({ right: $r('app.float.margin_small') })
            .onClick(() => {
              this.iconOnclick();
            })
            .visibility(this.isFloatWindow || this.isFullLandscapeScreen || this.isFullScreen ||
            this.isSliderDragging ? Visibility.None : Visibility.Visible)
          Slider({
            value: this.isSliderGesture ? this.panEndTime : this.avPlayerController.currentTime,
            step: CommonConstants.SLIDER_STEP,
            min: CommonConstants.SLIDER_MIN,
            max: this.avPlayerController.durationTime,
            style: this.sliderStyle
          })
            .id('video_slider')
            .height(this.isSliderDragging ? $r('app.float.side_width') : $r('app.float.size_24'))
            .trackColor($r('app.color.white_opacity_1_color'))
            .showSteps(false)
            .blockSize({ width: this.blockSize, height: this.blockSize })
            .blockColor($r('sys.color.background_primary'))
            .layoutWeight(1)
            .trackThickness(this.trackThicknessSize)
            .trackBorderRadius(CommonConstants.TRACK_BORDER_RADIUS)
            .selectedBorderRadius(CommonConstants.TRACK_BORDER_RADIUS)
            .zIndex(CommonConstants.SLIDER_INDEX)
            .onAreaChange(() => {
              try {
                let videoSlider: componentUtils.ComponentInfo = this.getUIContext().getComponentUtils().getRectangleById('video_slider');
                this.slideWidth = this.uiContext.px2vp(videoSlider.size.width);
                this.offsetY = this.uiContext.px2vp(videoSlider.localOffset.y);
                this.beginX = this.uiContext.px2vp(videoSlider.localOffset.x);
              } catch (error) {
                hilog.error(0x0000, 'testTag',`getRectangleById failed, Code:${error.code}, message:${error.message}`);
              }
            })
            .onChange((value: number, mode: SliderChangeMode) => {
              this.sliderOnchange(value, mode);
            })
          if (!this.isFloatWindow && !this.isFullLandscapeScreen &&
            !this.isFullScreen && !this.isSliderDragging) {
            FullScreenControl({ isFullScreen: this.isFullScreen, onFullScreenClick: this.onFullScreenClick })
          }
        }
        .width(CommonConstants.WIDTH_FULL_PERCENT)

        Stack() {
        }
        .backgroundColor($r('sys.color.background_primary'))
        .width(this.blockSize)
        .height(this.blockSize)
        .borderRadius($r('app.float.font_size_20'))
        .visibility(this.isShowTips ? Visibility.Visible : Visibility.None)
        .position({ x: this.tipsOffset, y: this.offsetY })
        .bindPopup(this.isShowTips, {
          builder: this.popupBuilder,
          placement: Placement.Top,
          mask: false,
          arrowOffset: 0,
          popupColor: $r('sys.color.background_primary'),
          backgroundBlurStyle: BlurStyle.BACKGROUND_ULTRA_THICK,
          enableArrow: true,
          arrowPointPosition: ArrowPointPosition.CENTER,
          radius: this.blockSize,
        })
      }
    }.margin({
      left: $r('app.float.padding_16'),
      right: $r('app.float.padding_16'),
      bottom: this.isSliderDragging ? $r('app.float.space_48') :
        this.isFullLandscapeScreen && !this.isFloatWindow ? (AppStorage.get<number>('navBarHeight') || 0)
          : $r('app.float.margin_small')
    })
  }

  sliderOnchange(seconds: number, mode: SliderChangeMode) {
    let seekTime: number = seconds * this.avPlayerController.duration / this.avPlayerController.durationTime;
    this.currentStringTime = secondToTime(Math.floor(seekTime / CommonConstants.SECOND_TO_MS));
    this.avPlayerController.setCurrentStringTime(this.currentStringTime);
    switch (mode) {
      case SliderChangeMode.Begin:
        break;
      case SliderChangeMode.Click:
        break;
      case SliderChangeMode.Moving:
        this.isSliderDragging = true;
        this.isTimeDisplay = 1;
        this.trackThicknessSize = CommonConstants.TRACK_SIZE_MAX;
        this.sliderStyle = SliderStyle.OutSet;
        break;
      case SliderChangeMode.End:
        this.avPlayerController.seek(seekTime);
        this.isTimeDisplay = 0;
        this.trackThicknessSize = CommonConstants.TRACK_SIZE_MIN;
        this.sliderStyle = SliderStyle.NONE;
        this.isSliderDragging = false;
        break;
      default:
        break;
    }
  }

  async iconOnclick() {
    if (this.avPlayerController.isPlaying) {
      this.avPlayerController.pauseVideo();
      this.avPlayerController.setIsPlaying(false);
      this.isTimeDisplay = 0;
      this.trackThicknessSize = CommonConstants.TRACK_SIZE_MIN;
      let context = this.uiContext.getHostContext() as common.UIAbilityContext;
      await window.getLastWindow(context)
        .then((windowClass: window.Window) => {
           windowClass.setWindowKeepScreenOn(false)
            .catch((err: BusinessError) => {
              hilog.error(0x0000, 'testTag',`setWindowKeepScreenOn failed, Code:${err.code}, message:${err.message}`);
            })
        })
         .catch((err: BusinessError) => {
           hilog.error(0x0000, 'testTag',`getLastWindow failed, Code:${err.code}, message:${err.message}`);
         })
      return;
    }
    if (this.avPlayerController.isReady === true) {
      this.avPlayerController.playVideo();
      this.avPlayerController.setIsPlaying(true);
      this.isTimeDisplay = 0;
      this.trackThicknessSize = CommonConstants.TRACK_SIZE_MIN;
    } else {
      let intervalFlag = setInterval(async () => {
        if (this.avPlayerController.isReady === true) {
          this.avPlayerController.playVideo();
          this.avPlayerController.setIsPlaying(true);
          this.isTimeDisplay = 0;
          this.trackThicknessSize = CommonConstants.TRACK_SIZE_MIN;
          clearInterval(intervalFlag);
        }
      }, CommonConstants.TIMER_INTERVAL);
    }
    let context = this.uiContext.getHostContext() as common.UIAbilityContext;
    await window.getLastWindow(context)
      .then((windowClass: window.Window) => {
        windowClass.setWindowKeepScreenOn(true)
        .catch((err: BusinessError) => {
          hilog.error(0x0000, 'testTag',`setWindowKeepScreenOn failed, Code:${err.code}, message:${err.message}`);
        })
      })
      .catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag',`getLastWindow failed, Code:${err.code}, message:${err.message}`);
      })
  }

  aboutToDisappear(): void {
    Logger.info(TAG,
      'enter aboutToDisappear.' +
        ` this.curIndex:${this.curIndex} this.index:${this.index} isPageShow:${this.isPageShow}`);
    this.avPlayerController.releaseVideo(this.index);
  }
}