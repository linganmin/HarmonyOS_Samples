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
import { audio, AVVolumePanel } from '@kit.AudioKit';
import { Logger, CommonConstants, secondToTime, } from '@ohos/MediaService';
import { AvPlayerController, VideoData } from '@ohos/MediaService';
import { FullScreenControl, VideoBottom } from './VideoSide';

const TAG: string = '[VideoPlayer]';

@Preview
@Component
export struct VideoPlayer {
  @Consume('pageInfo') pageInfo: NavPathStack;
  @StorageProp('navBarHeight') navBarHeight: number = 0;
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
  @State avPlayerController: AvPlayerController = new AvPlayerController(this.curSource);
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
  private xComponentController: XComponentController = new XComponentController();
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
  private mainWin?: window.Window;

  aboutToAppear(): void {
    try {
      this.mainWin = this.windowStage.getMainWindowSync();
    } catch (err) {
      Logger.error(TAG, `mainWin  failed, err.code:${err.code}, err.message:${err.message}`);
    }

    const context: Context | undefined = AppStorage.get('context');
    settings.getValue(context, settings.display.SCREEN_BRIGHTNESS_STATUS, settings.domainName.DEVICE_SHARED)
      .then((value) => {
        Logger.info(TAG, `Promise:value -> ${JSON.stringify(value)}`);
        this.screenBrightness = Number(value) / 255;
      })

    try {
      let windowClass: window.Window | undefined = undefined;
      window.getLastWindow(this.getUIContext().getHostContext()).then((window: window.Window) => {
        windowClass = window;
        this.screenHeight = windowClass.getWindowProperties().windowRect.height;
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
      });
      let audioManager: audio.AudioManager = audio.getAudioManager();
      let audioVolumeManger: audio.AudioVolumeManager = audioManager.getVolumeManager();
      this.volume = audioVolumeManger.getVolumeByStream(audio.StreamUsage.STREAM_USAGE_MOVIE);
    } catch (exception) {
      Logger.error(TAG,
        `Failed to obtain the top window. Cause code: ${exception.code}, message: ${exception.message}`);
    }
  }

  onIndexChange(): void {
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
        let countNum: number = 0;
        let intervalFlag: number = setInterval(() => {
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

  // [Start build]
  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // [StartExclude build]
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
            // [EndExclude build]
            XComponent({
              id: 'XComponent',
              type: XComponentType.SURFACE,
              controller: this.xComponentController
            })// [StartExclude build]
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
                // [Start panel]
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
                // [End panel]
                // [Start screen5]
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

                // [End screen5]
              }
              .height('100%')
              .width('100%')
            }
            // [EndExclude build]
          }

          // [StartExclude build]
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
      // [Start gesture]
      // [Start gesture1]
      .gesture(
        PanGesture({ direction: PanDirection.Vertical })
          .onActionStart(() => {
          })
          .onActionUpdate((event: GestureEvent) => {
            if (event.fingerList[0].globalX > (CommonConstants.FULL_SCREEN_WIDTH / 2)) {
              // On the right side of the screen relative to the X-axis coordinate in the upper left corner of the application window, adjust the brightness.
              this.visible = true;
              let curBrightness: number = this.screenBrightness -
                this.getUIContext().vp2px(event.offsetY) / this.getUIContext().vp2px(this.screenHeight);
              curBrightness = Math.max(0, Math.min(1.0, curBrightness));
              this.screenBrightness = curBrightness;
              Logger.info(TAG, `this brightness is: ` + this.screenBrightness);

              try {
                this.mainWin?.setWindowBrightness(this.screenBrightness, (err) => {
                  if (err) {
                    Logger.error(TAG, `Failed to set the brightness. Cause: ${JSON.stringify(err)}`);
                    return;
                  }
                  Logger.info(TAG, `Succeeded in setting the brightness.`);
                });
              } catch (exception) {
                Logger.error(TAG, `Failed to set the brightness.`);
              }
            } else {
              // On the left side of the screen relative to the X-axis coordinate in the upper left corner of the application window, adjust the volume.
              this.visible = false;
              let curVolume: number = this.volume - this.getUIContext().vp2px(event.offsetY) / this.screenHeight;
              curVolume = curVolume >= 15.0 ? 15.0 : curVolume;
              curVolume = curVolume <= 0.0 ? 0.0 : curVolume;
              this.volume = curVolume;
              Logger.info(TAG, `this volume is: ` + this.volume);
            }
          })
          .onActionEnd(() => {
            setTimeout(() => {
              this.visible = false;
            }, 3000)
          })
      )

      // [End gesture]
      // [End gesture1]
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
          .margin({ bottom: this.isFullScreen ? this.navBarHeight : 0 })
          .width(CommonConstants.WIDTH_FULL_PERCENT)
      }
      .zIndex(CommonConstants.Z_INDEX_MAX)
    }
    .width(CommonConstants.WIDTH_FULL_PERCENT)
    .height(CommonConstants.HEIGHT_FULL_PERCENT)
    .backgroundColor(Color.Black)
    // [EndExclude build]
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
          let panTime: number =
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

  // [End build]

  // The popup constructor defines the content of the dialog box
  @Builder
  popupBuilder(): void {
    Row({ space: 2 }) {
      Text($r('app.string.last_history', this.showTipsTime))
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('sys.color.font_primary'))
    }
    .height($r('app.float.size_44'))
    .padding({ left: $r('app.float.size_16'), right: $r('app.float.size_16') })
  }

  private showTip(value: number): void {
    if (value > 0 && this.isFullScreen) {
      this.showTipsTime = this.avPlayerController.currentStringTime;
      this.isShowTips = true;
      let percent: number = Number((value / this.avPlayerController.durationTime).toFixed(2));
      this.tipsOffset = this.getUIContext().px2vp(this.beginX) + (this.slideWidth - 16) * percent;
      this.hideTip();
    }
  }

  private hideTip(): void {
    clearTimeout(this.hideTipTask);
    this.hideTipTask = setTimeout(() => {
      this.isShowTips = false;
    }, 1000);
  }

  @Builder
  PlayControl(): void {
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
          // [Start slider]
          // [Start value]
          Slider({
            value: this.isSliderGesture ? this.panEndTime : this.avPlayerController.currentTime,
            step: CommonConstants.SLIDER_STEP,
            min: CommonConstants.SLIDER_MIN,
            max: this.avPlayerController.durationTime,
            style: this.sliderStyle
          })
          // [StartExclude value]
          // [StartExclude slider]
            .id('video_slider')
            .height(this.isSliderDragging ? $r('app.float.side_width') : $r('app.float.size_24'))
            .layoutWeight(1)
            .zIndex(CommonConstants.SLIDER_INDEX)// [EndExclude slider]
            .trackColor($r('app.color.white_opacity_1_color'))// Slide rail background color
            .showSteps(false)// Whether to display step scale or not.
            // [EndExclude value]
            .blockSize({ width: this.blockSize, height: this.blockSize })// Slider size
            // [StartExclude value]
            .blockColor($r('sys.color.background_primary'))// Slider color
            .trackThickness(this.trackThicknessSize)// Slide rail thickness
            .trackBorderRadius(CommonConstants.TRACK_BORDER_RADIUS)// Radius of bottom fillet
            .selectedBorderRadius(CommonConstants.TRACK_BORDER_RADIUS)// Radius of fillet of sliding part
            // [EndExclude value]
            // [StartExclude slider]
            .onAreaChange(() => {
              try {
                let videoSlider: componentUtils.ComponentInfo =
                  this.getUIContext().getComponentUtils().getRectangleById('video_slider');
                this.slideWidth = this.getUIContext().px2vp(videoSlider.size.width);
                this.offsetY = this.getUIContext().px2vp(videoSlider.localOffset.y);
                this.beginX = this.getUIContext().px2vp(videoSlider.localOffset.x);
              } catch (err) {
                Logger.error(TAG, `onAreaChange  failed, err.code:${err.code}, err.message:${err.message}`);
              }
            })
            // [EndExclude slider]
            .onChange((value: number, mode: SliderChangeMode) => {
              this.sliderOnchange(value, mode); // Progress bar change interface
            })
          // [End value]
          // [End slider]
          if (!this.isFloatWindow && !this.isFullLandscapeScreen &&
            !this.isFullScreen && !this.isSliderDragging) {
            FullScreenControl({ isFullScreen: this.isFullScreen, onFullScreenClick: this.onFullScreenClick })
          }
        }
        .width(CommonConstants.WIDTH_FULL_PERCENT)

        // [Start transparent]
        // Set a transparent stack block with the same size as the Slider.
        Stack() {
        }
        .backgroundColor($r('sys.color.background_primary'))
        .width(this.blockSize)
        .height(this.blockSize)
        .borderRadius($r('app.float.font_size_20'))
        .visibility(this.isShowTips ? Visibility.Visible : Visibility.None)
        .position({ x: this.tipsOffset, y: this.offsetY })
        //Bind the Popup to the Stack block and follow the Slider.
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

        // [End transparent]
      }
    }.margin({
      left: $r('app.float.padding_16'),
      right: $r('app.float.padding_16'),
      bottom: this.isSliderDragging ? $r('app.float.space_48') :
        this.isFullLandscapeScreen && !this.isFloatWindow ? this.navBarHeight : $r('app.float.margin_small')
    })
  }

  // 前台进度条变化接口
  // [Start slider1]
  sliderOnchange(seconds: number, mode: SliderChangeMode): void {
    let seekTime: number = seconds * this.avPlayerController.duration / this.avPlayerController.durationTime;
    this.currentStringTime = secondToTime(Math.floor(seekTime / CommonConstants.SECOND_TO_MS));
    this.avPlayerController.setCurrentStringTime(this.currentStringTime);
    switch (mode) {
      case SliderChangeMode.Begin:
        break;
      case SliderChangeMode.Click:
        break;
      case SliderChangeMode.Moving:
        // [StartExclude slider1]
        this.isSliderDragging = true;
        this.isTimeDisplay = 1;
        this.trackThicknessSize = CommonConstants.TRACK_SIZE_MAX;
        this.sliderStyle = SliderStyle.OutSet;
        // [EndExclude slider1]
        break;
      case SliderChangeMode.End:
        try {
          this.avPlayerController.seek(seekTime); // Call the seek method of AVPlayer to control the playback progress.
        } catch (err) {
          Logger.error(TAG, `AVPlsyer seek failed, err.code:${err.code}, err.message:${err.message}`);
        }
        // [StartExclude slider1]
        this.isTimeDisplay = 0;
        this.trackThicknessSize = CommonConstants.TRACK_SIZE_MIN;
        this.sliderStyle = SliderStyle.NONE;
        this.isSliderDragging = false;
        // [EndExclude slider1]
        break;
      default:
        break;
    }
  }

  // [End slider1]

  async iconOnclick(): Promise<void> {
    if (this.avPlayerController.isPlaying) {
      this.avPlayerController.pauseVideo();
      this.avPlayerController.setIsPlaying(false);
      this.isTimeDisplay = 0;
      this.trackThicknessSize = CommonConstants.TRACK_SIZE_MIN;
      let context: Context = AppStorage.get('context')!;
      try {
        let windowClass: window.Window = await window.getLastWindow(context);
        await windowClass.setWindowKeepScreenOn(false);
      } catch (err) {
        Logger.error(TAG, `iconOnclick isPlaying failed, err.code:${err.code}, err.message:${err.message}`);
      }
      return;
    }
    if (this.avPlayerController.isReady === true) {
      this.avPlayerController.playVideo();
      this.avPlayerController.setIsPlaying(true);
      this.isTimeDisplay = 0;
      this.trackThicknessSize = CommonConstants.TRACK_SIZE_MIN;
    } else {
      let intervalFlag: number = setInterval(async () => {
        if (this.avPlayerController.isReady === true) {
          this.avPlayerController.playVideo();
          this.avPlayerController.setIsPlaying(true);
          this.isTimeDisplay = 0;
          this.trackThicknessSize = CommonConstants.TRACK_SIZE_MIN;
          clearInterval(intervalFlag);
        }
      }, CommonConstants.TIMER_INTERVAL);
    }
    let context: Context = this.getUIContext().getHostContext() as Context;
    try {
      let windowClass: window.Window = await window.getLastWindow(context);
      await windowClass.setWindowKeepScreenOn(true);
    } catch (err) {
      Logger.error(TAG, `iconOnclick failed, err.code:${err.code}, err.message:${err.message}`);
    }
  }

  aboutToDisappear(): void {
    Logger.info(TAG,
      'enter aboutToDisappear.' +
        ` this.curIndex:${this.curIndex} this.index:${this.index} isPageShow:${this.isPageShow}`);
    this.avPlayerController.releaseVideo(this.index);
  }
}

