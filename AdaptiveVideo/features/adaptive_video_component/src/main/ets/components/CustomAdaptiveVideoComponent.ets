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
 *
 */
import {
  AdaptiveRotation,
  AdaptiveVideoComponent,
  AdaptiveVideoController,
  AdaptiveVideoListener,
  AdaptiveVideoSetting,
  ScreenMode,
  ScreenModeNotifier,
  ViewMode
} from '@hadss/adaptive_video';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BreakpointConstants, BreakpointType, CommonConstants } from 'base';
import { AVPlayerUtil } from '../utils/AVPlayerUtil';
import { PCVideoControl } from './PCVideoControl';
import { VideoControl } from './VideoControl';
import { media } from '@kit.MediaKit';
import { display, window } from '@kit.ArkUI';

const LOG_TAG = 'CustomAdaptiveVideoComponent'
const DOMAIN = 0x0000;
const adaptiveRotation = AdaptiveRotation.getInstance();
const screenModeNotifier: ScreenModeNotifier = ScreenModeNotifier.getInstance();

@Component
export struct CustomAdaptiveVideoComponent {
  // The index of the video currently being played
  @Prop curIndex: number = 0;
  // Is the current progress bar sliding
  @State isSliderMoving: boolean = false;
  index: number = 0
  fdPath: string = ''
  // Whether to hide the tab bar, mainly to control whether the vertical screen UI information is displayed after entering full screen mode
  @Consume hideTab: boolean
  // Hide control bar
  @State hideControl: boolean = true
  @Link disableSwipe: boolean
  // Whether to display the progress bar that comes with the advanced component: Not displayed in portrait mode or full-screen playback scenarios
  @State isProgressBarShow: boolean = true
  // is 2in1 device
  @Consume is2in1Device: boolean
  @State viewMode?: ViewMode = ViewMode.SWIPER
  @State svgFillColor: ResourceColor = Color.White
  @State featureIconWidth: number = 30
  @StorageProp(BreakpointConstants.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint =
    WidthBreakpoint.WIDTH_XS
  // Current playback time
  @State currentTime: string = ''
  // Current playback progress
  @State currentProgress: number = 0
  // Video length
  @State duration: number = 0
  // Current playback status
  @State currentState: media.AVPlayerState = 'idle'
  // Current window size
  @StorageProp(CommonConstants.WINDOW_SIZE) @Watch('windowChange') windowSize: window.Size = { width: 0, height: 0 }
  private dataSource?: string | media.AVFileDescriptor;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  // Instantiate an adaptiveVideoController object to control the current video playback/pause behavior
  private adaptiveVideoController?: AdaptiveVideoController = new AdaptiveVideoController(this.context);
  // Instantiate an adaptiveVideoListener object to listen to video status/events
  private adaptiveVideoListener?: AdaptiveVideoListener = new AdaptiveVideoListener();
  // [StartExclude video]
  private currentVideoSize: Size = { width: 0, height: 0 }
  // Bottom tab bar height
  private bottomTabHeight: number = 0
  private bottomRectHeight: number = 0

  // [EndExclude video]
  aboutToAppear(): void {
    this.bottomTabHeight = AppStorage.get(CommonConstants.BOTTOM_TAB_HEIGHT) ?? 56
    this.bottomRectHeight = AppStorage.get(CommonConstants.NAVIGATION_INDICATOR_HEIGHT) ?? 0
    if (AVPlayerUtil.getInstance().isUrl(this.fdPath)) {
      // If this.curSource is a string type, assign it to this.avPlayer.url, indicating that the playback source is a URL.
      this.dataSource = this.fdPath;
    } else {
      // If this.curSource is not a string type, assign it to this.avPlayer.fdSrc, indicating that the playback source is a file descriptor.
      try {
        this.dataSource = this.context.resourceManager.getRawFdSync(this.fdPath);
      } catch (error) {
        hilog.error(DOMAIN, LOG_TAG, `Get raw file failed.`);
      }
    }
    this.adaptiveVideoListener?.on('videoSizeChange', (videoSize: Size) => {
      hilog.info(DOMAIN, LOG_TAG, `videoSizeChange videoSize = ${JSON.stringify(videoSize)}`)
      this.currentVideoSize = videoSize
      adaptiveRotation?.setOrientationNotFullScreen({
        width: this.currentVideoSize.width,
        height: this.currentVideoSize.height
      })
    })
    this.adaptiveVideoListener?.on('stateChange', (state: media.AVPlayerState) => {
      hilog.info(DOMAIN, LOG_TAG, `index is ${this.index}, stateChange state = ${state}`)
      this.currentState = state
      if (state === CommonConstants.AV_PLAYER_PLAYING_STATE) {
        this.currentVideoSize = {
          width: this.adaptiveVideoController?.avPlayer?.width ?? 0,
          height: this.adaptiveVideoController?.avPlayer?.height ?? 0
        }
      }
    })
    this.adaptiveVideoListener?.on('timeUpdate', (updateTime: number) => {
      this.currentTime = AVPlayerUtil.getInstance().formatTime(updateTime)
      this.duration = this.adaptiveVideoController?.avPlayer?.duration ?? 0
      this.currentProgress = updateTime
    })
    adaptiveRotation.init(this.context)
    screenModeNotifier.init(this.context)
    // Register a screen mode listener
    screenModeNotifier.onScreenModeChange(this.onScreenModeChange);
    this.isProgressBarShow = !this.is2in1Device
  }
  // [Start video]
  build() {
    RelativeContainer() {
      Stack() {
        Column() {
          AdaptiveVideoComponent({
            dataSource: this.dataSource, // Video playback source, which can be a URL or a file descriptor
            adaptiveVideoController: this.adaptiveVideoController, // Video controller
            adaptiveVideoListener: this.adaptiveVideoListener, // Video player listener, used to get the status/event of the currently playing video
            isAutoPlay: true, // Auto play
            isLoop: true, // Loop playback
            viewMode: this.viewMode, // Video view mode
            curIndex: this.curIndex, // Current Playback Index
            index: this.index, // Player Index
            bottomTabHeight: this.bottomTabHeight, // Bottom tab height
            isFullScreenIconShow: true, // Show default full screen icon
            adaptiveVideoSetting: this.adaptiveVideoSetting, // Video Player Config Options
            isProgressBarShow: this.isProgressBarShow // Show progress bar
          })
        }
        // [StartExclude video]
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .alignSelf(ItemAlign.Center)
      .align(Alignment.Center)
      .alignContent(Alignment.Center)

      Column({ space: 20 }) {
        Image($r('app.media.menu_icon_user_avatar')).width(44)
        this.showFeatureIcon($r('app.media.menu_icon_like'), '1557', true)
        this.showFeatureIcon($r('app.media.menu_icon_comment'), '566')
        this.showFeatureIcon($r('app.media.menu_icon_share'), '147')
        Image($r('app.media.menu_icon_music_cover')).width(32)
      }
      .enabled(false)
      .id('featureIcons')
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        right: { anchor: '__container__', align: HorizontalAlign.End }
      })
      .margin({ bottom: this.is2in1Device ? 0 : this.bottomTabHeight + this.bottomRectHeight })
      .padding({
        bottom: this.is2in1Device ? 84 : 40,
        right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
      })
      .visibility(this.hideTab ? Visibility.None : Visibility.Visible)

      if (this.is2in1Device) {
        Column() {
          Row({ space: 4 }) {
            Text().colourLump(82, 16, 16)
            Text().colourLump(55, 14, 14)
          }

          Text().colourLump(669, 14, 14).margin({ top: 16 })
        }
        .id('colorBlocks')
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .padding({ bottom: 84, left: 32 })
        .visibility(this.hideTab ? Visibility.None : Visibility.Visible)
        .alignItems(HorizontalAlign.Start)

        PCVideoControl({
          currentTime: this.currentTime,
          currentProgress: this.currentProgress,
          videoDuration: this.duration,
          currentState: this.currentState,
          onChange: (value: number, mode: SliderChangeMode) => {
            this.seek(value, mode);
          },
          onVideoClick: () => {
            this.controlPlayOrPause()
          }
        })
          .id('pc_control')
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          })
      } else {
        Column() {
          Row({ space: 4 }) {
            Text().colourLump(82, 16, 16)
            Text().colourLump(55, 14, 14)
          }

          Text().colourLump(240, 14, 14).margin({ top: 11 })
          Text().colourLump(240, 14, 14).margin({ top: 13 })
          Text().colourLump(93, 14, 14).margin({ top: 16 })
        }
        .id('colorBlocks')
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .enabled(false)
        .margin({ bottom: this.bottomTabHeight + this.bottomRectHeight })
        .padding({ bottom: 40, left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint) })
        .visibility(this.hideTab ? Visibility.None : Visibility.Visible)
        .width('auto')
        .height('auto')
        .alignItems(HorizontalAlign.Start)


        if (this.hideTab) {
          if (!this.hideControl) {
            Row({ space: 8 }) {
              Image($r('app.media.fullscreen_back'))
                .width(40)
                .onClick(() => {
                  this.hideTab = false
                  this.hideControl = false
                  adaptiveRotation?.setOrientationNotFullScreen({
                    width: this.currentVideoSize.width,
                    height: this.currentVideoSize.height
                  })
                  this.viewMode = ViewMode.SWIPER
                })
              Text($r('app.string.title'))
                .fontSize(20)
                .lineHeight(27)
                .fontWeight(700)
                .fontColor(Color.White)
            }
            .margin({
              left: 16,
              right: 16,
              top: 8,
              bottom: 8
            })

            VideoControl({
              currentTime: this.currentTime,
              currentProgress: this.currentProgress,
              videoDuration: this.duration,
              onChange: (value: number, mode: SliderChangeMode) => {
                this.seek(value, mode);
              }
            })
              .id('video_control')
              .alignRules({
                bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                left: { anchor: '__container__', align: HorizontalAlign.Start },
                right: { anchor: '__container__', align: HorizontalAlign.End }
              })
              .margin({ bottom: this.bottomRectHeight, left: 16, right: 16 })
          }
        }
      }
      // [EndExclude video]
    }
  }
  // [StartExclude video]
  @Builder
  showFeatureIcon(src: ResourceStr, content?: ResourceStr, changeFillColor?: boolean) {
    Column() {
      Image(src)
        .width(changeFillColor ? this.featureIconWidth : 30)
        .fillColor(changeFillColor ? this.svgFillColor : Color.White)
      if (content) {
        Text(content)
          .fontSize(14)
          .lineHeight(19)
          .fontColor(Color.White)
          .margin({ top: 5 })
      }
    }
  }

  aboutToDisappear(): void {
    // Unregister the screen mode listener
    screenModeNotifier.offScreenModeChange(this.onScreenModeChange);
  }

  // [EndExclude video]
  private adaptiveVideoSetting?: AdaptiveVideoSetting = {
    interactionEventSetting: {
      onFullScreenIconClick: () => {
        // [StartExclude video]
        hilog.info(DOMAIN, LOG_TAG, `setOrientationFullScreen width = ${JSON.stringify(this.currentVideoSize)}`)
        this.hideTab = true
        // [EndExclude video]
        adaptiveRotation.setOrientationFullScreen({
          width: this.currentVideoSize.width, height: this.currentVideoSize.height
        }) // Pass in the width and height of the current video being played, control the rotation property, and achieve a horizontal full-screen playback effect
        this.viewMode = ViewMode.FULL_SCREEN // The component mode is full screen mode
      },
      onSingleClick: () => {
        // [StartExclude video]
        if (this.hideTab && this.hideControl) {
          // The scenario of hiding the tab bar and hiding the control bar indicates that the control bar is not displayed in landscape mode
          this.hideControl = false
        } else {
          hilog.info(DOMAIN, LOG_TAG, `Video showCtrol SingleClick`)
          // [EndExclude video]
          // Click the video to pause/play the video
          this.controlPlayOrPause();
          // [StartExclude video]
        }
        // [EndExclude video]
      },
      onDoubleClick: () => {
        // Double-click event handling
        // [StartExclude video]
        this.getUIContext().animateTo({
          duration: 3000,
          curve: Curve.EaseOut,
          playMode: PlayMode.Normal,
          onFinish: () => {
            this.featureIconWidth = 30
          }
        }, () => {
          this.svgFillColor = Color.Red
          this.featureIconWidth = 40
        })
        // [EndExclude video]
      },
      onLongPress: () => {
        // Long press event handling
        this.adaptiveVideoController?.avPlayer?.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X)
        // [StartExclude video]
        try {
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.speed_tips'),
            alignment: Alignment.Top,
            offset: {
              dx: 0,
              dy: this.getUIContext().vp2px(new BreakpointType(32, 56, 80).getValue(this.currentWidthBreakpoint))
            },
            textColor: Color.White,
            backgroundColor: $r('app.color.color_black_seventy_percent'),
            backgroundBlurStyle: BlurStyle.NONE
          })
        } catch (error) {
          hilog.error(DOMAIN, LOG_TAG, `Show toast failed.`);
        }
        // [EndExclude video]
      },
      onLongPressEnd: () => {
        // Long press event end processing
        this.adaptiveVideoController?.avPlayer?.setSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X)
      }
    },
    progressBarSetting: {
      selectedColor: Color.White,
      trackColor: '#1AFFFFFF',
      isTimeTextShow: false
    } // Progress config
  }
  // [End video]
  /**
   * Use layout switch notifier
   */
  private onScreenModeChange = (data: string) => {
    if (this.curIndex === this.index) {
      if (data === ScreenMode.FULL_SCREEN) {
        // The UI layout switching logic when entering a horizontal layout (such as when a horizontal video enters full screen playback)
        hilog.info(DOMAIN, LOG_TAG, `screen switch to fullScreen`)
        this.disableSwipe = true
        this.isProgressBarShow = false
        this.hideTab = true
        this.hideControl = true
        adaptiveRotation.setOrientationFullScreen({
          width: this.currentVideoSize.width, height: this.currentVideoSize.height
        })
        this.viewMode = ViewMode.FULL_SCREEN
      } else {
        // The UI layout switching logic when entering vertical layout (such as when exiting full screen in horizontal video)
        hilog.info(DOMAIN, LOG_TAG, `screen switch to notFullScreen`)
        this.disableSwipe = false
        this.isProgressBarShow = true
        this.hideTab = false
        this.hideControl = false
        adaptiveRotation?.setOrientationNotFullScreen({
          width: this.currentVideoSize.width,
          height: this.currentVideoSize.height
        })
        this.viewMode = ViewMode.SWIPER
      }
    }
  }

  /**
   * Control video playback and pause
   */
  private controlPlayOrPause() {
    const currentState = this.adaptiveVideoController?.avPlayer?.state;
    if (currentState === CommonConstants.AV_PLAYER_PLAYING_STATE) {
      this.adaptiveVideoController?.pause();
    } else if (currentState === CommonConstants.AV_PLAYER_PAUSED_STATE) {
      this.adaptiveVideoController?.play();
    }
  }

  windowChange() {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED) {
          // If the fold screen is in the expand state, exit full screen mode, display the bottom TAB, and close the landscape control bar
          this.hideTab = false
          this.hideControl = true
        }
      } catch (error) {
        hilog.error(DOMAIN, LOG_TAG, `Get display fold status failed.`);
      }
    }
  }

  private seek(value: number, mode: SliderChangeMode) {
    this.currentProgress = value;
    if (AVPlayerUtil.getInstance().isCanSeek(this.currentState) &&
      (mode === SliderChangeMode.End ||
        mode == SliderChangeMode.Click)) {
      this.adaptiveVideoController?.seek(value, media.SeekMode.SEEK_CLOSEST);
    }
  }
}

@Extend(Text)
function colourLump(width: Length, height: Length, borderRadius: Length | BorderRadiuses | LocalizedBorderRadiuses) {
  .width(width)
  .height(height)
  .backgroundColor($r("app.color.color_white_seventy_percent"))
  .borderRadius(borderRadius)
}
