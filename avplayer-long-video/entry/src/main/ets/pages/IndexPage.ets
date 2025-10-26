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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { emitter } from '@kit.BasicServicesKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { SOURCES } from '../model/VideoSourceModel';
import { VideoData } from '../model/VideoData';
import { WindowUtil } from '../common/utils/WindowUtil';
import { CommonConstants } from '../common/constants/CommonConstants';
import { VideoList } from '../view/VideoList';
import { AVPlayer } from '../view/AVPlayer';

const TAG = '[IndexPage]';

@Entry
@Component
struct IndexPage {
  @Provide('pageInfo') pageInfo: NavPathStack = new NavPathStack();
  @State isFullLandscapeScreen: boolean = false; // Whether the video is played in full screen
  @State sources: VideoData[] = SOURCES; // Local video sources
  @State currentIndex: number = 0; // The index of playing video
  @State isPageShow: boolean = false; // Whether the app is on the front end or back end
  @State showPopup: boolean = false; // Control pop-up display
  private swiperController: SwiperController = new SwiperController();
  private windowUtil: WindowUtil = WindowUtil.getInstance();

  async aboutToAppear(): Promise<void> {
    let context = this.getUIContext().getHostContext() as Context;
    try {
      // Set dark color mode
      context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      // Set screen stay on during video play
      let windowClass = await window.getLastWindow(context);
      await windowClass.setWindowKeepScreenOn(true);
    } catch (exception) {
      hilog.error(0x0000, TAG, `setWindowKeepScreenOn failed: code: ${exception.code}, message: ${exception.message}`);
    }
    this.windowUtil.registerOnWindowSizeChange((size) => {
      if (size.width > size.height) {
        this.isFullLandscapeScreen = true;
      } else {
        this.isFullLandscapeScreen = false;
      }
    });
    emitter.on(CommonConstants.PLAY_PREVIOUS_EVENT_ID, () => {
      this.playPrevious();
    });
    emitter.on(CommonConstants.PLAY_NEXT_EVENT_ID, () => {
      this.playNext();
    });
    AppStorage.setOrCreate('isPIPShow', false); // Whether to show picture in picture
  }

  aboutToDisappear(): void {
    this.windowUtil.registerOffWindowSizeChange();
    emitter.off(CommonConstants.PLAY_PREVIOUS_EVENT_ID);
    emitter.off(CommonConstants.PLAY_NEXT_EVENT_ID);
  }

  // [Start SwitchToBackEnd]
  onPageHide(): void {
    this.isPageShow = false;
  }

  // [End SwitchToBackEnd]

  // [Start SwitchToFront]
  onPageShow(): void {
    this.isPageShow = true;
  }

  // [End SwitchToFront]

  // Full screen mode back to normal mode
  private handleFullScreenExit() {
    if (this.isFullLandscapeScreen) {
      this.windowUtil.enableWindowSystemBar();
      this.windowUtil.setLandscapeMultiWindow(false);
      // [Start SetMainWindowPORTRAIT]
      this.windowUtil.setMainWindowOrientation(window.Orientation.USER_ROTATION_PORTRAIT);
      // [End SetMainWindowPORTRAIT]
    }
  }

  private animateFullscreen() {
    this.getUIContext().animateTo({
      duration: CommonConstants.ANIMATE_DURATION
    }, () => {
    });
  }

  // Background control set to play previous
  private playPrevious() {
    if (this.currentIndex > 0) {
      this.swiperController.changeIndex(--this.currentIndex, false);
    }
  }

  // Background control set to play next
  private playNext() {
    if (this.currentIndex < this.sources.length - 1) {
      this.swiperController.changeIndex(++this.currentIndex, false);
    }
  }

  // Define pop-up content
  @Builder
  popupContent() {
    Column() {
      // Set picture in picture
      Row() {
        Text($r('app.string.pip_start'))
          .width(160)
          .fontSize($r('app.float.size_15'))
          .fontWeight(FontWeight.Bold)
          .margin({ left: $r('app.float.size_8') })
          .fontColor($r('app.color.dialog_text_color'))
        Toggle({ type: ToggleType.Switch, isOn: AppStorage.get('isPIPShow') })
          .onChange((isOn: boolean) => {
            AppStorage.set('isPIPShow', isOn); // Update the status of the toggle
          })
          .height($r('app.float.size_20'))
          .margin({ right: $r('app.float.size_8') })
          .selectedColor($r('app.color.dialog_cancel_color'))
      }
      .width('95%')
      .height($r('app.float.size_44'))
      .borderRadius($r('app.float.size_20'))
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  build() {
    Navigation(this.pageInfo) {
      Column() {
        Stack() {
          Swiper(this.swiperController) {
            ForEach(this.sources, (item: VideoData, index: number) => {
              Stack() {
                AVPlayer({
                  isFullLandscapeScreen: this.isFullLandscapeScreen,
                  onFullScreenClick: (isLandscape?: boolean) => {
                    if (isLandscape) {
                      this.windowUtil.disableWindowSystemBar();
                      this.windowUtil.setLandscapeMultiWindow(true);
                      // [Start SetMainWindowLANDSCAPE]
                      this.windowUtil.setMainWindowOrientation(window.Orientation.USER_ROTATION_LANDSCAPE);
                      // [End SetMainWindowLANDSCAPE]
                    } else {
                      this.animateFullscreen();
                    }
                  },
                  curSource: item,
                  curIndex: this.currentIndex,
                  index: index,
                  isPageShow: this.isPageShow,
                })
              }
            }, (item: string, index: number) => JSON.stringify(item) + index)
          }
          .width(CommonConstants.WIDTH_FULL_PERCENT)
          .height(this.isFullLandscapeScreen ? CommonConstants.HEIGHT_FULL_PERCENT :
            this.getUIContext().px2vp((AppStorage.get<number>('deviceWidth') || 0) / CommonConstants.ASPECT))
          .vertical(true)
          .loop(false)
          .indicator(false)
          .backgroundColor(Color.Black)
          .onAnimationStart((_index: number, targetIndex: number) => {
            this.currentIndex = targetIndex;
          })
          .onAnimationEnd(() => {
          })

          Button({ type: ButtonType.Circle }) {
            Image($r('sys.media.ohos_ic_public_arrow_left'))
              .fillColor(Color.White)
              .width($r('app.float.size_24'))
              .height($r('app.float.size_24'))
          }
          .width($r('app.float.button_back_size'))
          .height($r('app.float.button_back_size'))
          .backgroundColor('rgba(255,255,255,0.1)')
          .position({
            x: '2%',
            y: $r('app.float.back_position_y')
          })
          .onClick(() => {
            this.handleFullScreenExit();
          })
          .visibility(this.isFullLandscapeScreen ? Visibility.Visible : Visibility.Hidden)

          Text(this.sources[this.currentIndex].name)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('app.float.size_24'))
            .position({
              x: $r('app.float.size_64'),
              y: $r('app.float.size_30')
            })
            .visibility(this.isFullLandscapeScreen ? Visibility.Visible : Visibility.Hidden)

          Text() {
            SymbolSpan($r('sys.symbol.dot_grid_2x2'))
              .fontSize($r('app.float.size_25'))
              .fontColor([Color.White])
          }
          .position({ x: '96%', y: $r('app.float.size_27') })
          .markAnchor({ x: '100%', y: 0 })
          .padding($r('app.float.size_10'))
          .zIndex(1)
          .borderRadius($r('app.float.size_25'))
          .backgroundColor('rgba(255,255,255,0.1)')
          .onClick(() => {
            this.showPopup = !this.showPopup; // Click the button to switch the pop-up status
          })
          .bindSheet(this.showPopup, this.popupContent(), {
            height: '170vp',
            title: { title: $r('app.string.more') },
            onDisappear: () => {
              this.showPopup = false;
            }
          })
          .visibility(this.isFullLandscapeScreen ? Visibility.Hidden : Visibility.Visible)
        }

        VideoList({
          currentIndex: this.currentIndex,
          sources: this.sources,
          onItemClick: (index) => {
            this.swiperController.changeIndex(index, false);
            this.currentIndex = index;
          }
        })
      }
      .width(CommonConstants.WIDTH_FULL_PERCENT)
      .height(CommonConstants.HEIGHT_FULL_PERCENT)
    }
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .width(CommonConstants.WIDTH_FULL_PERCENT)
    .height(CommonConstants.HEIGHT_FULL_PERCENT)
  }
}