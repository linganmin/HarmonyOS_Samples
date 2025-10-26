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
import { media } from '@kit.MediaKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BreakpointConstants, BreakpointType, CommonConstants } from 'base';
import { BusinessError } from '@kit.BasicServicesKit';
import { AVPlayerUtil } from '../utils/AVPlayerUtil';
// [Start immersion_init]
import { AdaptiveImmersion } from '@hadss/adaptive_video';
// [StartExclude immersion_init]
// [Start rotation_init]
import { AdaptiveRotation, ScreenMode, ScreenModeNotifier } from '@hadss/adaptive_video';
// [StartExclude rotation_init]
import { display, window } from '@kit.ArkUI';
import { VideoControl } from './VideoControl';
import { common } from '@kit.AbilityKit';
import { BreakpointRange, BreakpointRangeDatabase } from '@hadss/adaptive_video/src/main/ets/rotation/rule/BreakPoint';
import { PCVideoControl } from './PCVideoControl';

const LOG_TAG = 'CustomAVPlayerComponent'
const DOMAIN = 0x0000;
// [EndExclude immersion_init]
const adaptiveImmersion = AdaptiveImmersion.getInstance(); // get AdaptiveImmersion instance
// [StartExclude immersion_init]
// [EndExclude rotation_init]
const adaptiveRotation = AdaptiveRotation.getInstance(); // get AdaptiveRotation instance
const screenModeNotifier: ScreenModeNotifier = ScreenModeNotifier.getInstance(); // get ScreenModeNotifier instance

// [StartExclude rotation_init]
/**
 * Short video component with adaptive immersion and rotation rules
 */
// [EndExclude immersion_init]
// [EndExclude rotation_init]
@Component
export struct AdaptiveAVPlayer {
  // [StartExclude immersion_init]
  // [StartExclude rotation_init]
  // Monitor the current video playback index and perform initialization actions in advance
  @Prop @Watch('onIndexChange') currentIndex: number = -1;
  // Video index
  index: number = 0;
  // Playback source
  currentSource: string = '';
  // Playback component width
  @State surfaceWidth: Length = '100%'
  // Playback component height
  @State surfaceHeight: Length = '100%'
  // Player location
  @State videoPosition: Position = {}
  // Control whether to display the full screen play button
  @State showFullScreenBtn: boolean = false;
  // Hide control bar
  @State hideControl: boolean = true;
  // Whether to hide the tab bar, mainly to control whether the vertical screen UI information is displayed after entering full screen mode
  @Consume hideTab: boolean
  // Current playback status
  @State currentState: media.AVPlayerState = 'idle'
  // Current playback time
  @State currentTime: string = ''
  // Current playback progress
  @State currentProgress: number = 0
  // Current window size
  @StorageProp(CommonConstants.WINDOW_SIZE) @Watch('windowChange') windowSize: window.Size = { width: 0, height: 0 }
  // Bottom tab bar height
  @StorageProp(CommonConstants.BOTTOM_TAB_HEIGHT) bottomTabHeight: number = 0
  // Bottom avoidance area height
  @StorageProp(CommonConstants.NAVIGATION_INDICATOR_HEIGHT) bottomRectHeight: number = 0
  // Is first time playing
  @Link firstInit: boolean
  // Video length
  @State duration: number = 0
  @Link disableSwipe: boolean
  // is 2in1 device
  @Consume is2in1Device: boolean
  @StorageProp(BreakpointConstants.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint =
    WidthBreakpoint.WIDTH_XS
  // Each playback component has its own AVPlayer, and they do not affect each other
  private avPlayer: media.AVPlayer | undefined = undefined;
  private xComponentController: XComponentController = new XComponentController();
  private surfaceId: string = '';
  // Is the video playback ready
  private hasPrepared: boolean = false;
  // Original width of the playback component
  private oriSurfaceWidth: Length = '100%'
  // Original height of the playback component
  private oriSurfaceHeight: Length = '100%'
  // Is the current player full screen or not
  private currentScreen: string = ScreenMode.NOT_FULL_SCREEN;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  // [Start get_immersion]
  build() {
    RelativeContainer() {
      Stack() {
        Column() {
          XComponent({
            id: 'AdaptiveAVPlayer', // Playback component ID
            type: XComponentType.SURFACE, // Playback component type
            controller: this.xComponentController // Playback Component Controller
          })
            .width(this.surfaceWidth)// Playback component width
            .height(this.surfaceHeight)// Playback component height
            .position(this.videoPosition)// The playback component is positioned relative to the upper left corner of the window
            // [StartExclude get_immersion]
            .onLoad(() => {
              // surfaceID is used to display the playback screen
              this.surfaceId = this.xComponentController.getXComponentSurfaceId()
              hilog.info(DOMAIN, LOG_TAG, `AdaptiveAVPlayer load succ, surfaceId = ${this.surfaceId}`)
              this.initAVPlayer()
            })
            .gesture(TapGesture({ count: 1 })
              .onAction((_event: GestureEvent) => {
                hilog.info(DOMAIN, LOG_TAG, `Gesture singleClick.`)
                // Click event handling
                if (this.hideTab && this.hideControl) {
                  // The scenario of hiding the tab bar and hiding the control bar indicates that the control bar is not displayed in landscape mode
                  this.hideControl = false
                } else {
                  this.controlPlayOrPause();
                }
              }))
        }
        .width('100%')
        .height('100%')

        if (this.currentState === CommonConstants.AV_PLAYER_PAUSED_STATE) {
          Image($r('app.media.icon_pause'))
            .height(56)
            .onClick(() => {
              if (this.canPlay()) {
                this.avPlayer?.play().catch(() => {
                  hilog.error(DOMAIN, LOG_TAG, 'Play AVPlayer failed.');
                })
              }
            })
        }
      }
      .width('100%')
      .height('100%')
      .alignSelf(ItemAlign.Center)
      .align(Alignment.Center)
      .alignContent(Alignment.Center)

      Column() {
        if (this.showFullScreenBtn) {
          Row() {
            Image($r('app.media.icon_fullscreen'))
              .width(15)
            Text($r('app.string.btn_fullscreen'))
              .fontSize(14)
              .lineHeight(20)
              .fontColor(Color.White)
              .fontWeight(500)
              .margin({ left: 4 })
          }
          .id('btn_fullscreen')
          .height(28)
          .padding({
            left: 8,
            right: 8,
            top: 4,
            bottom: 4
          })
          .borderRadius(14)
          .backgroundColor($r("app.color.color_white_ninety_percent"))
          .margin({ top: this.surfaceHeight })
          .focusable(false)
          .onClick(() => {
            hilog.info(DOMAIN, LOG_TAG, `Change fullscreen`)
            this.setOrientationFullScreen();
          })
        }
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.End)
      .width(this.surfaceWidth)
      .position(this.videoPosition)
      .padding({ top: 15 })
      .hitTestBehavior(HitTestMode.None)

      Column({ space: 20 }) {
        Image($r('app.media.menu_icon_user_avatar')).width(44)
        this.showFeatureIcon($r('app.media.menu_icon_like'), '1557')
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
        .enabled(false)
        .id('colorBlocks')
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })
        .margin({ bottom: this.bottomTabHeight + this.bottomRectHeight })
        .padding({ bottom: 40, left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint) })
        .visibility(this.hideTab ? Visibility.None : Visibility.Visible)
        .alignItems(HorizontalAlign.Start)

        if (this.hideTab) {
          if (!this.hideControl) {
            Row({ space: 8 }) {
              Image($r('app.media.fullscreen_back'))
                .width(40)
                .onClick(() => {
                  this.changePortraitVideo()
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
        } else {
          Column() {
            Slider({ value: this.currentProgress, max: this.duration, style: SliderStyle.NONE })
              .id('video_progress')
              .selectedColor(Color.White)
              .trackColor($r('app.color.color_white_ninety_percent'))
              .height(20)
              .onChange((value: number, mode: SliderChangeMode) => {
                this.seek(value, mode);
              })
          }
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .margin({
            bottom: this.bottomTabHeight + this.bottomRectHeight,
            left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
            right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint)
          })
          .height(24)
          .justifyContent(FlexAlign.Center)
        }
      }
      // [EndExclude get_immersion]
    }
  }

  // [StartExclude get_immersion]
  @Builder
  showFeatureIcon(src: ResourceStr, content?: ResourceStr) {
    Column() {
      Image(src)
        .width(30)
      if (content) {
        Text(content)
          .fontSize(14)
          .lineHeight(19)
          .fontColor(Color.White)
          .margin({ top: 5 })
      }
    }
  }

  onIndexChange() {
    if (this.currentIndex !== this.index) {
      // Because multiple instances may appear, other playing videos are paused here.
      this.avPlayer?.pause().catch(() => {
        hilog.error(DOMAIN, LOG_TAG, 'Pause AVPlayer failed.');
      })
    } else {
      this.changePortraitVideo();
      if (this.hasPrepared) {
        if (this.canPlay()) {
          this.avPlayer?.play().catch(() => {
            hilog.error(DOMAIN, LOG_TAG, 'Play AVPlayer failed');
          })
        }
      } else {
        this.initAVPlayer()
      }
    }
  }

  initAVPlayer() {
    media.createAVPlayer().then((avplayer: media.AVPlayer) => {
      if (avplayer === undefined) {
        hilog.error(DOMAIN, LOG_TAG, `Create AVPlayer failed.`);
        return;
      }
      this.avPlayer = avplayer;
      this.addAVPlayerCallback()
      if (AVPlayerUtil.getInstance().isUrl(this.currentSource)) {
        // If this.curSource is a string type, assign it to this.avPlayer.url, indicating that the playback source is a URL.
        this.avPlayer.url = this.currentSource;
      } else {
        // If this.curSource is not a string type, assign it to this.avPlayer.fdSrc, indicating that the playback source is a file descriptor.
        try {
          this.avPlayer.fdSrc = this.context.resourceManager.getRawFdSync(this.currentSource);
        } catch (error) {
          hilog.error(DOMAIN, LOG_TAG, `Get raw file failed.`);
        }
      }
    }).catch(() => {
      hilog.error(DOMAIN, LOG_TAG, `Create AVPlayer failed.`);
    })
  }

  windowChange() {
    if (this.currentIndex === this.index) {
      if (this.currentScreen === ScreenMode.FULL_SCREEN) {
        if (canIUse('SystemCapability.Window.SessionManager')) {
          try {
            if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED &&
              this.windowSize.width < CommonConstants.MIDDLE_WIDTH) {
              // If the fold screen is in the expand state, exit full screen mode, display the bottom TAB, and close the landscape control bar.
              this.hideTab = false
              this.hideControl = true
              this.changePortraitVideo();
            } else {
              // The UI layout switching logic when entering a horizontal layout (such as when a horizontal video enters full screen playback)
              this.setOrientationFullScreen();
            }
          } catch (error) {
            hilog.error(DOMAIN, LOG_TAG, `Get display fold status failed.`);
          }
        } else {
          // The UI layout switching logic when entering a horizontal layout (such as when a horizontal video enters full screen playback)
          this.setOrientationFullScreen();
        }
      } else {
        // The UI layout switching logic when entering vertical layout (such as when exiting full screen in horizontal video)
        this.changePortraitVideo();
      }
    }
  }

  // [EndExclude immersion_init]
  // [EndExclude rotation_init]
  // [Start sensor_callback]
  aboutToAppear(): void {
    // [StartExclude rotation_init]
    // [StartExclude sensor_callback]
    adaptiveImmersion.init(this.context) // The UIAbilityContext is initialized with the adaptive immersion tool
    // [StartExclude immersion_init]
    // [EndExclude rotation_init]
    adaptiveRotation.init(this.context) // The UIAbilityContext is initialized with the adaptive rotation tool.
    screenModeNotifier.init(this.context) // Initialize the page layout transformation tool in the UIAbilityContext.
    // [StartExclude rotation_init]
    // [EndExclude sensor_callback]
    screenModeNotifier.onScreenModeChange(this.onScreenModeChange); // Register a screen mode listener
    // [EndExclude immersion_init]
    // [EndExclude rotation_init]
  }

  // [StartExclude immersion_init]
  // [StartExclude rotation_init]
  // [StartExclude sensor_callback]
  aboutToDisappear(): void {
    this.removeAVPlayerCallback()
    this.avPlayer?.release().catch(() => {
      hilog.error(DOMAIN, LOG_TAG, `Release AVPlayer failed.`);
    })
    // [Start sensor_off_callback]
    // Unregister the screen mode listener
    screenModeNotifier.offScreenModeChange(this.onScreenModeChange);
    // [End sensor_off_callback]
  }

  private canPlay() {
    return (this.avPlayer?.state === CommonConstants.AV_PLAYER_PREPARED_STATE ||
      this.avPlayer?.state === CommonConstants.AV_PLAYER_PAUSED_STATE ||
      this.avPlayer?.state === CommonConstants.AV_PLAYER_COMPLETED_STATE)
  }

  private addAVPlayerCallback() {
    this.avPlayer?.on('stateChange', this.onStateChange);
    this.avPlayer?.on('videoSizeChange', this.videoSizeChange);
    this.avPlayer?.on('timeUpdate', this.onTimeUpdateFunction);
  }

  private removeAVPlayerCallback() {
    this.avPlayer?.off('stateChange', this.onStateChange);
    this.avPlayer?.off('videoSizeChange', this.videoSizeChange);
    this.avPlayer?.off('timeUpdate', this.onTimeUpdateFunction);
  }

  // Video status monitoring
  private onStateChange: (state: media.AVPlayerState) => void = async (state: media.AVPlayerState) => {
    if (this.avPlayer === undefined) {
      hilog.error(DOMAIN, LOG_TAG, `AvPlayer is undefined`);
      return;
    }
    this.currentState = state
    hilog.info(DOMAIN, LOG_TAG, `AVPlayer state is ${state}, index is ${this.index}`);
    switch (state) {
      case CommonConstants.AV_PLAYER_INITIALIZED_STATE:
        this.hasPrepared = true
        this.avPlayer.surfaceId = this.surfaceId;
        this.avPlayer.prepare().catch(() => {
          hilog.error(DOMAIN, LOG_TAG, `Preapare AVPlayer failed.`);
        }).then(() => {
        }, (err: BusinessError) => {
          hilog.error(DOMAIN, LOG_TAG, `Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          this.avPlayer?.reset().catch(() => {
            hilog.error(DOMAIN, LOG_TAG, `Reset avPlayer failed.`);
          });
        });
        break;
      case CommonConstants.AV_PLAYER_PREPARED_STATE:
        this.avPlayer.videoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT_CROP;
        // Video loop playback
        this.avPlayer.loop = true;
        if (this.firstInit && this.currentIndex === this.index && this.index === 0) {
          // The first playback can be played only after the width and height are obtained successfully. This prevents the zooming effect of the view
          const interval = setInterval(() => {
            this.avPlayer?.play().catch(() => {
              hilog.error(DOMAIN, LOG_TAG, `Play AVPlayer failed.`);
            });
            clearInterval(interval)
          }, 200)
          this.firstInit = false
        }
        this.duration = this.avPlayer.duration
        break;
      case CommonConstants.AV_PLAYER_COMPLETED_STATE:
        this.avPlayer.stop().catch(() => {
          hilog.error(DOMAIN, LOG_TAG, `Stop AVPlayer failed.`);
        });
        break;
      case CommonConstants.AV_PLAYER_ERROR_STATE:
        this.avPlayer.reset().catch(() => {
          hilog.error(DOMAIN, LOG_TAG, `Reset AVPlayer failed.`);
        })
        break;
      default:
        hilog.info(DOMAIN, LOG_TAG, 'AVPlayer state unknown');
        break;
    }
  }
  // Time refresh onScreenModeChange
  private onTimeUpdateFunction: (updateTime: number) => void = (updateTime: number) => {
    this.currentTime = AVPlayerUtil.getInstance().formatTime(updateTime)
    this.currentProgress = updateTime
  }
  private videoSizeChange: (width: number, height: number) => void = (width: number, height: number) => {
    // Unit Pixel
    this.oriSurfaceWidth = width
    this.oriSurfaceHeight = height
    if (this.currentIndex === this.index) {
      hilog.info(DOMAIN, LOG_TAG,
        `AVPlayer videoSizeChange width = ${this.oriSurfaceWidth}, height = ${this.oriSurfaceHeight}`);
      this.changePortraitVideo();
    }
  }

  // [EndExclude get_immersion]
  // [EndExclude sensor_callback]
  // Non-full-screen video playback
  private async changePortraitVideo() {
    try {
      // [StartExclude get_immersion]
      // [StartExclude sensor_callback]
      this.disableSwipe = false
      const oriWidth = this.oriSurfaceWidth as number
      const oriHeight = this.oriSurfaceHeight as number
      // The full-screen play button is displayed only for horizontal videos and special devices
      if (this.oriSurfaceWidth > this.oriSurfaceHeight) {
        const uiContext = this.getUIContext()
        let widthBp: WidthBreakpoint = uiContext.getWindowWidthBreakpoint();
        let heightBp: HeightBreakpoint = uiContext.getWindowHeightBreakpoint();
        const breakPoint = BreakpointRangeDatabase.getInstance().getBreakpointRange(widthBp, heightBp);
        this.showFullScreenBtn = breakPoint === (BreakpointRange.Small_Portrait || BreakpointRange.Medium_Landscape)
      }
      // [Start not_fullscreen]
      // [EndExclude sensor_callback]
      // Exit the full-screen mode
      adaptiveRotation?.setOrientationNotFullScreen({
        width: oriWidth, height: oriHeight
      }) // Input the width and height of the current video to be played, control the rotation attribute, and play the video vertically
      // [End not_fullscreen]
      // [StartExclude sensor_callback]
      hilog.info(DOMAIN, LOG_TAG, `changePortraitVideo windowSize = ${JSON.stringify(this.windowSize)}`)
      hilog.info(DOMAIN, LOG_TAG,
        `changePortraitVideo index = ${this.index}, oriSurfaceWidth = ${this.oriSurfaceWidth}, oriSurfaceHeight = ${this.oriSurfaceHeight}`);
      hilog.info(DOMAIN, LOG_TAG, `getImmersionInfo.index = ${this.index}`)
      // [EndExclude get_immersion]
      const immersionInfo = adaptiveImmersion
        .getImmersionInfo({ width: this.oriSurfaceWidth as number, height: this.oriSurfaceHeight as number },
          this.bottomTabHeight); // Input the width and height of the current video and the height of the tab navigation bar at the bottom to obtain the immersive layout information
      // Adjust the page layout based on the immersive information
      if (immersionInfo) {
        hilog.info(DOMAIN, LOG_TAG, `changePortraitVideo immersionInfo = ${JSON.stringify(immersionInfo)}`);
        this.surfaceWidth = immersionInfo.videoSize.width; // Video component width
        this.surfaceHeight = immersionInfo.videoSize.height; // Video component height
        this.videoPosition =
          immersionInfo.videoPosition; // Position of the video component relative to the upper left corner of the window
      }
      // [EndExclude sensor_callback]
    } catch (err) {
      hilog.error(DOMAIN, LOG_TAG, `changePortraitVideo error = ${JSON.stringify(err)}`);
    }
  }

  // [End get_immersion]
  // Horizontal full-screen video playback
  private async setOrientationFullScreen() {
    try {
      // [StartExclude sensor_callback]
      this.disableSwipe = true
      const oriWidth = this.oriSurfaceWidth as number
      const oriHeight = this.oriSurfaceHeight as number
      // [Start fullscreen]
      // [EndExclude sensor_callback]
      // Play the video in full screen mode
      adaptiveRotation?.setOrientationFullScreen({
        width: oriWidth, height: oriHeight
      }); // Input the width and height of the current video, control the rotation attribute, and horizontal full-screen playback effect
      // [End fullscreen]
      // [StartExclude sensor_callback]
      this.showFullScreenBtn = false
      // Proportional calculation based on the aspect ratio to prevent video distortion after landscape display
      hilog.info(DOMAIN, LOG_TAG, `setOrientationFullScreen windowSize = ${JSON.stringify(this.windowSize)}`)
      if (oriWidth > oriHeight) {
        this.surfaceHeight = this.windowSize.height;
        // Calculate the width based on the aspect ratio
        this.surfaceWidth = this.surfaceHeight * oriWidth / oriHeight
        let positionX = 0
        if (this.windowSize.width > this.surfaceWidth) {
          // The video width is smaller than the window width. You need to use position to control the display position and center the video
          positionX = (this.windowSize.width - this.surfaceWidth) / 2
        }
        this.videoPosition = { x: positionX, y: 0 };
        // [EndExclude sensor_callback]
      }
    } catch (err) {
      hilog.error(DOMAIN, LOG_TAG, `setOrientationFullScreen error = ${JSON.stringify(err)}`);
    }
  }

  // Toggle Notifier with Layout
  private onScreenModeChange = (data: string) => {
    if (this.currentIndex === this.index) {
      // Indicates that only the current listener on the foreground is processed
      this.currentScreen = data
      if (data === ScreenMode.FULL_SCREEN) {
        // UI layout switching logic when the horizontal layout needs to be entered (for example, when the horizontal video is played in full screen mode)
        hilog.info(DOMAIN, LOG_TAG, `screen switch to fullScreen`)
        this.hideTab = true
        this.setOrientationFullScreen(); // Invoke the full-screen playback method
      } else {
        // UI layout switching logic when the vertical layout needs to be entered (for example, when the horizontal video exits full screen)
        hilog.info(DOMAIN, LOG_TAG, `screen switch to notFullScreen`)
        this.hideTab = false
        this.changePortraitVideo(); // Invoke a non-full-screen player method
      }
    }
  }

  // [StartExclude sensor_callback]
  /**
   * Controls the playback and pause of a video
   */
  private controlPlayOrPause() {
    if (this.currentState === CommonConstants.AV_PLAYER_PLAYING_STATE) {
      this.avPlayer?.pause().catch(() => {
        hilog.error(DOMAIN, LOG_TAG, `Pause AVPlayer failed.`);
      });
    } else if (this.currentState === CommonConstants.AV_PLAYER_PAUSED_STATE) {
      if (this.canPlay()) {
        this.avPlayer?.play().catch(() => {
          hilog.error(DOMAIN, LOG_TAG, `Play AVPlayer failed.`);
        });
      }
    }
  }

  /**
   * Play the video at the specified position.
   * @param value Playing position
   * @param mode Event-triggered status value
   */
  private seek(value: number, mode: SliderChangeMode) {
    this.currentProgress = value;
    if (AVPlayerUtil.getInstance().isCanSeek(this.currentState) &&
      (mode === SliderChangeMode.End ||
        mode === SliderChangeMode.Click)) {
      this.avPlayer?.seek(value, media.SeekMode.SEEK_CLOSEST);
    }
  }

  // [EndExclude sensor_callback]
  // [End sensor_callback]
  // [EndExclude immersion_init]
  // [EndExclude rotation_init]
}

// [End immersion_init]
// [End rotation_init]

@Extend(Text)
function colourLump(width: Length, height: Length, borderRadius: Length | BorderRadiuses | LocalizedBorderRadiuses) {
  .width(width)
  .height(height)
  .backgroundColor($r("app.color.color_white_seventy_percent"))
  .borderRadius(borderRadius)
}