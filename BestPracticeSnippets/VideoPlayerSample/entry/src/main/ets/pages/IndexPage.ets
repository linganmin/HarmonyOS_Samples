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

import { window } from '@kit.ArkUI';
import { CommonConstants as Const, Logger, VideoData } from '@ohos/MediaService';
import { SOURCES, VideoSource } from '../model/DataModel';
import { WindowUtil } from '../utils/WindowUtil';
import { RightSide, VideoDes } from '../view/VideoSide';
import { VideoList } from '../view/VideoList';
import { VideoPlayer } from '../view/AVPlayer';
import { VideoDetails } from '../view/VideoDetails';

const TAG: string = '[IndexPage]';

// [Start index_page1]
@Entry
@Component
struct IndexPage {
  @State isFloatWindow: boolean = false;
  @StorageProp('deviceHeight') @Watch('onWindowSizeChange') deviceHeight: number =
    AppStorage.get<number>('deviceHeight') || 0;
  // [StartExclude index_page1]
  @StorageProp('statusBarHeight') statusBarHeight: number = 0;
  @State @Watch('onWindowSizeChange') isFullScreen: boolean = false;
  @State @Watch('onWindowSizeChange') isFullLandscapeScreen: boolean = false;
  @State sources: VideoData[] = SOURCES;
  @State currentIndex: number = 0;
  @State isPageShow: boolean = false;
  @Provide('pageInfo') pageInfo: NavPathStack = new NavPathStack();
  private swiperController: SwiperController = new SwiperController();
  private windowUtil: WindowUtil = WindowUtil.getInstance();

  // [Start about_appear]
  // Turn on window size monitoring in aboutToAppear
  async aboutToAppear(): Promise<void> {
    let context: Context = this.getUIContext().getHostContext() as Context;
    try {
      let windowClass: window.Window = await window.getLastWindow(context);
      await windowClass.setWindowKeepScreenOn(true);
    } catch (err) {
      Logger.error(TAG, `aboutToAppear failed, err.code:${err.code}, err.message:${err.message}`);
    }
    // Register window size monitoring
    this.windowUtil.registerOnWindowSizeChange((size) => {
      if (size.width > size.height) {
        // Horizontal screen logic
        this.isFullLandscapeScreen = true;
      } else {
        // Vertical screen logic
        this.isFullLandscapeScreen = false;
      }
    });
  }
  // [End about_appear]

  aboutToDisappear(): void {
    this.windowUtil.registerOffWindowSizeChange();
  }

  onPageHide(): void {
    Logger.info(TAG, `onPageHide curIndex: ${this.currentIndex} isPageShow:${this.isPageShow}}`);
    this.isPageShow = false;
  }

  onPageShow(): void {
    Logger.info(TAG, `onPageShow curIndex: ${this.currentIndex} isPageShow:${this.isPageShow}}`);
    this.isPageShow = true;
  }

  onBackPress(): boolean | void {
    if (this.isFullScreen || this.isFullLandscapeScreen) {
      this.handleFullScreenExit();
      return true;
    }
    return false;
  }

  handleFullScreenExit(): void {
    if (this.isFullLandscapeScreen) {
      this.windowUtil.setLandscapeMultiWindow(false);
      this.windowUtil.enableWindowSystemBar();
      this.windowUtil.setMainWindowOrientation(window.Orientation.PORTRAIT);
    } else if (this.isFullScreen) {
      this.animateFullscreen();
    }
  }


  // [Start device_width]
  build() {
    // [StartExclude device_width]
    Navigation(this.pageInfo) {
      Column() {
        Swiper(this.swiperController) {
          LazyForEach(new VideoSource(this.sources), (item: VideoData, index: number) => {
            Stack() {
   // [EndExclude device_width]
              VideoPlayer({
                // [StartExclude device_width]
                videoRightSide: (): void => this.rightSlide(item),
                videoDes: (): void => this.videoDes(item),
                isFullLandscapeScreen: this.isFullLandscapeScreen,
                isFullScreen: this.isFullScreen,
                // [EndExclude device_width]
                isFloatWindow: this.isFloatWindow,
                // [StartExclude device_width]
                onFullScreenClick: (isLandscape?: boolean) => {
                  if (isLandscape) {
                    this.windowUtil.disableWindowSystemBar();
                    this.windowUtil.setLandscapeMultiWindow(true);
                    this.windowUtil.setMainWindowOrientation(window.Orientation.LANDSCAPE);
                  } else {
                    this.animateFullscreen();
                  }
                },
                curSource: item,
                curIndex: this.currentIndex,
                index: index,
                isPageShow: this.isPageShow,
                // [EndExclude device_width]
              })
              // [StartExclude device_width]
              Button({ type: ButtonType.Circle }) {
                Image($r('sys.media.ohos_ic_public_arrow_left'))
                  .fillColor(Color.White)
                  .width($r('app.float.size_24'))
                  .height($r('app.float.size_24'))
              }
              .width($r('app.float.button_back_size'))
              .height($r('app.float.button_back_size'))
              .backgroundColor($r('app.color.white_opacity_1_color'))
              .position({
                x: $r('app.float.back_position_x'),
                y: this.isFloatWindow ? (AppStorage.get<number>('statusBarHeight') || 0) :
                  Const.DIVIDER_MARGIN + (AppStorage.get<number>('statusBarHeight') || 0)
              })
              .onClick(() => {
                this.handleFullScreenExit();
              })
              .visibility(this.isFullScreen || this.isFullLandscapeScreen ? Visibility.Visible : Visibility.Hidden)
            }

          }, (item: string, index: number) => JSON.stringify(item) + index)
        }
        .cachedCount(2)
        .disableSwipe(!this.isFullScreen || this.isFullLandscapeScreen)
        .width(Const.WIDTH_FULL_PERCENT)
        .height(this.isFullScreen || this.isFullLandscapeScreen ? Const.HEIGHT_FULL_PERCENT :
        this.getUIContext().px2vp((AppStorage.get<number>('deviceWidth') || 0) / Const.ASPECT))
        .vertical(true)
        .loop(true)
        .curve(Curve.Ease)
        .duration(Const.DURATION_TIME)
        .indicator(false)
        .backgroundColor(Color.Black)
        .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
          Logger.info(TAG,
            `onAnimationStart index: ${index},curIndex: ${targetIndex},extraInfo: ${JSON.stringify(extraInfo)}.`);
          this.currentIndex = targetIndex;
        })
        .onAnimationEnd((index: number, extraInfo: SwiperAnimationEvent) => {
          Logger.info(TAG, `onAnimationEnd index: ${index},extraInfo: ${JSON.stringify(extraInfo)}.`);
        })

        VideoDetails({
          item: this.sources[this.currentIndex]
        })
        VideoList({
          currentIndex: this.currentIndex,
          sources: this.sources,
          onItemClick: (index) => {
            this.swiperController.changeIndex(index, false);
            this.currentIndex = index;
          }
        })
      }
      .width(Const.WIDTH_FULL_PERCENT)
      .height(Const.HEIGHT_FULL_PERCENT)
    }
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .width(Const.WIDTH_FULL_PERCENT)
    .height(Const.HEIGHT_FULL_PERCENT)
    // [EndExclude device_width]
  }
  // [End device_width]
  @Builder
  videoDes(item: VideoData): void {
    VideoDes({
      item: item,
      isFloatWindow: this.isFloatWindow,
      onNextClick: () => {
        this.swiperController.showNext();
      }
    })
      .visibility(((this.isFullScreen || this.isFloatWindow) && !this.isFullLandscapeScreen) ? Visibility.Visible :
      Visibility.None)
      .margin({ bottom: $r('app.float.video_des_margin_bottom') })
  }

  @Builder
  rightSlide(item: VideoData): void {
    RightSide({ item: item })
      .visibility((this.isFullScreen && !this.isFloatWindow && !this.isFullLandscapeScreen) ? Visibility.Visible :
      Visibility.Hidden)
      .zIndex(Const.Z_INDEX_RIGHT_SIDE)
  }

  private animateFullscreen(): void {
    this.getUIContext().animateTo({
      duration: Const.ANIMATE_DURATION
    }, () => {
      this.isFullScreen = !this.isFullScreen;
    });
  }

  // [Start device_width1]
  // Because the width and height of the floating window are the system default, the value of isFloatWindow (whether to display the floating window or not) is only processed according to the height of the window, which is used to control the display and concealment of the interface components.
  // [EndExclude index_page1]
  onWindowSizeChange(): void {
    // [StartExclude index_page1]
    let deviceWidth: number = AppStorage.get<number>('deviceWidth') || 0;
    // Judge whether it is a horizontal screen or a vertical screen suspension window.
    if (this.isFullLandscapeScreen && Math.round((this.deviceHeight / deviceWidth) * 1000) / 1000 === 0.563) {
      this.isFloatWindow = true;
    } else if (this.isFullScreen &&
      (Math.round((deviceWidth / this.deviceHeight) * 1000) / 1000 === 0.563
        || Math.round((deviceWidth / this.deviceHeight) * 10) / 10 === 0.6)) {
      this.isFloatWindow = true;
    } else {
      this.isFloatWindow = false;
    }
    // [EndExclude index_page1]
  }
  // [End device_width1]
}
// [End index_page1]


