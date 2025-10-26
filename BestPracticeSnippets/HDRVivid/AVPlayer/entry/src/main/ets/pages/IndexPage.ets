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
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants as Const, Logger, VideoData } from '@ohos/MediaService';
import { SOURCES, VideoSource } from '../model/DataModel';
import { WindowUtil } from '../utils/WindowUtil';
import { RightSide, VideoDes } from '../view/VideoSide';
import { VideoList } from '../view/VideoList';
import { VideoPlayer } from '../view/AVPlayer';
import { VideoDetails } from '../view/VideoDetails';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[IndexPage]';

@Entry
@Component
struct IndexPage {
  @Provide('pageInfo') pageInfo: NavPathStack = new NavPathStack();
  @StorageProp('deviceHeight') @Watch('onWindowSizeChange') deviceHeight: number =
    AppStorage.get<number>('deviceHeight') || 0;
  @State @Watch('onWindowSizeChange') isFullScreen: boolean = false;
  @State @Watch('onWindowSizeChange') isFullLandscapeScreen: boolean = false;
  @State sources: VideoData[] = SOURCES;
  @State currentIndex: number = 0;
  @State isPageShow: boolean = false;
  @State isFloatWindow: boolean = false;
  private swiperController: SwiperController = new SwiperController();
  private windowUtil: WindowUtil = WindowUtil.getInstance();
  uiContext = this.getUIContext()

  async aboutToAppear(): Promise<void> {
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

    this.windowUtil.registerOnWindowSizeChange((size) => {
      if (size.width > size.height) {
        this.isFullLandscapeScreen = true;
      } else {
        this.isFullLandscapeScreen = false;
      }
    });
  }

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

  onWindowSizeChange() {
    let deviceWidth = AppStorage.get<number>('deviceWidth') || 0;
    if (this.isFullLandscapeScreen && Math.round((this.deviceHeight / deviceWidth) * 1000) / 1000 === 0.563) {
      // Determine whether it is a floating window in landscape orientation
      this.isFloatWindow = true;
    } else if (this.isFullScreen &&
      (Math.round((deviceWidth / this.deviceHeight) * 1000) / 1000 === 0.563 ||
        Math.round((deviceWidth / this.deviceHeight) * 10) / 10 === 0.6)) {
      // Determine whether it is a floating window in portrait orientation
      this.isFloatWindow = true;
    } else {
      this.isFloatWindow = false;
    }
  }

  onBackPress(): boolean | void {
    if (this.isFullScreen || this.isFullLandscapeScreen) {
      this.handleFullScreenExit();
      return true;
    }
    return false;
  }

  handleFullScreenExit() {
    if (this.isFullLandscapeScreen) {
      this.windowUtil.setLandscapeMultiWindow(false);
      this.windowUtil.enableWindowSystemBar();
      this.windowUtil.setMainWindowOrientation(window.Orientation.PORTRAIT);
    } else if (this.isFullScreen) {
      this.animateFullscreen();
    }
  }

  build() {
    Navigation(this.pageInfo) {
      Column() {
        Swiper(this.swiperController) {
          LazyForEach(new VideoSource(this.sources), (item: VideoData, index: number) => {
            Stack() {
              VideoPlayer({
                videoRightSide: (): void => this.rightSlide(item),
                videoDes: (): void => this.videoDes(item),
                isFullLandscapeScreen: this.isFullLandscapeScreen,
                isFullScreen: this.isFullScreen,
                isFloatWindow: this.isFloatWindow,
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
              })
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
        this.uiContext.px2vp((AppStorage.get<number>('deviceWidth') || 0) / Const.ASPECT))
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
  }

  @Builder
  videoDes(item: VideoData) {
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
  rightSlide(item: VideoData) {
    RightSide({ item: item })
      .visibility((this.isFullScreen && !this.isFloatWindow && !this.isFullLandscapeScreen) ? Visibility.Visible :
      Visibility.Hidden)
      .zIndex(Const.Z_INDEX_RIGHT_SIDE)
  }

  private animateFullscreen() {
    this.uiContext.animateTo({
      duration: Const.ANIMATE_DURATION
    }, () => {
      this.isFullScreen = !this.isFullScreen;
    });
  }
}