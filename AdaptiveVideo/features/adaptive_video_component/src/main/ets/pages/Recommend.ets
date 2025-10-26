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
import { AdaptiveRotation, ScreenModeNotifier } from '@hadss/adaptive_video';
import { BreakpointConstants, BreakpointType, CommonConstants } from 'base';
import { VideoDataSource } from 'base/src/main/ets/model/VideoDataSource';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CustomAdaptiveVideoComponent } from '../components/CustomAdaptiveVideoComponent';
import { AdaptiveAVPlayer } from '../components/AdaptiveAVPlayer';
import { window } from '@kit.ArkUI';
import { KeyCode } from '@kit.InputKit';

/**
 * Recommended TAB Index
 */
const TAB_RECOMMEND_INDEX = 4
const LOG_TAG = 'Recommend'
const DOMAIN = 0x0000;

/**
 * Slide to the scene with index 1 to automatically slide to the far left
 */
const SCROLL_EDGE_START = 1


/**
 * Slide to the scene with index 3 to automatically slide to the far right
 */
const SCROLL_EDGE_END = 3

/**
 * Recommended page
 */
@Component
export struct Recommend {
  /**
   * Page stack
   */
  @Consume('pathStack') pageStack: NavPathStack;
  @State selTabIndex: number = TAB_RECOMMEND_INDEX
  @StorageProp(CommonConstants.SYSTEM_HEIGHT) topRectHeight: number = 0
  @Consume hideTab: boolean
  // The index of the video currently playing
  @State curIndex: number = 0;
  // Status bar immersive mode
  @State isStatusBarImmersive: boolean = false;
  // Bottom tab immersion state on short video page
  @State isBottomTabImmersive: boolean = false;
  // Is the progress bar sliding
  @State isSliderMoving: boolean = false;
  scroller: Scroller = new Scroller();
  @State firstInit: boolean = true
  /**
   * Disable swipe switching in landscape mode
   */
  @State disableSwipe: boolean = false
  /**
   * is 2in1 device
   */
  @Consume is2in1Device: boolean
  /**
   * The search bar is located on the right side
   */
  @State searchBarMarginRight: number = 0
  /**
   * Determine which subpage to enter
   */
  pageIndex: number = 0
  @StorageProp(BreakpointConstants.CURRENT_WIDTH_BREAKPOINT) currentWidthBreakpoint: WidthBreakpoint =
    WidthBreakpoint.WIDTH_XS
  private controller: TabsController = new TabsController();
  /**
   * top tab data
   */
  private tabData: ResourceStr[] = [$r('app.string.top_tab_title_group'), $r('app.string.top_tab_title_live'),
    $r('app.string.top_tab_title_follow'), $r('app.string.top_tab_title_mall'),
    $r('app.string.top_tab_title_recommend')]
  private swiperController: SwiperController = new SwiperController();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass?: window.Window

  // custom tab
  @Builder
  Tab(tabIndex: number, tabTitle: ResourceStr) {
    RelativeContainer() {
      Text(tabTitle)
        .id('tabTitle')
        .fontSize(16)
        .lineHeight(21)
        .fontWeight(this.selTabIndex === tabIndex ? 500 : 400)
        .fontColor(this.selTabIndex === tabIndex ? Color.White : $r("app.color.color_white_forty_percent"))
        .textAlign(TextAlign.Center)
        .height(56)
        .onClick(() => {
          this.controller.changeIndex(tabIndex);
          this.selTabIndex = tabIndex;
          if (tabIndex <= SCROLL_EDGE_START) {
            this.scroller.scrollEdge(Edge.Start)
          } else if (tabIndex >= SCROLL_EDGE_END) {
            this.scroller.scrollEdge(Edge.End)
          }
        })
      if (this.selTabIndex === tabIndex) {
        Divider()
          .id('tabDivider')
          .strokeWidth(2)
          .color(Color.White)
          .borderRadius(1)
          .alignRules({
            left: { 'anchor': 'tabTitle', 'align': HorizontalAlign.Start },
            right: { 'anchor': 'tabTitle', 'align': HorizontalAlign.End },
            bottom: { 'anchor': 'tabTitle', 'align': VerticalAlign.Bottom },
          })
          .margin({ bottom: 8 })
      }
    }.width('auto')
  }

  @Builder
  SwiperBuilder() {
    Stack() {
      Swiper(this.swiperController) {
        LazyForEach(new VideoDataSource(CommonConstants.VIDEO_SOURCE), (item: string, index: number) => {
          if (this.pageIndex === 0) {
            AdaptiveAVPlayer({
              currentIndex: this.curIndex,
              index: index,
              currentSource: item,
              firstInit: this.firstInit,
              disableSwipe: this.disableSwipe
            })
          } else {
            CustomAdaptiveVideoComponent({
              fdPath: item,
              curIndex: this.curIndex,
              index: index,
              disableSwipe: this.disableSwipe
            })
          }
        }, (item: string) => item)
      }
      .onKeyPreIme((event: KeyEvent) => {
        if (event.type === KeyType.Down) {
          if (event.keyCode === KeyCode.KEYCODE_DPAD_DOWN) {
            this.swiperController.showNext();
          }
          if (event.keyCode === KeyCode.KEYCODE_DPAD_UP) {
            this.swiperController.showPrevious();
          }
        }
        return false;
      })
      .cachedCount(this.pageIndex === 0 ? this.firstInit ? 0 : 2 : 2)
      .width('100%')
      .height('100%')
      .vertical(true)
      .loop(true)
      .curve(Curve.Ease)
      .duration(300)
      .indicator(false)
      .onAnimationStart((index: number, targetIndex: number) => {
        // Perform the operation of preloading resources
        hilog.info(DOMAIN, LOG_TAG, `Swiper onAnimationStart index = ${index}, targetIndex = ${targetIndex}`)
        this.curIndex = targetIndex;
      })
      .disableSwipe(this.disableSwipe)
    }.align(Alignment.Bottom)
    .alignSelf(ItemAlign.End)
  }

  build() {
    if (this.is2in1Device) {
      RelativeContainer() {
        this.SwiperBuilder()
        if (this.currentWidthBreakpoint === WidthBreakpoint.WIDTH_SM) {
          // Drag and shrink to a certain position, only display the search icon
          Image($r('app.media.search'))
            .height(40)
            .padding(12)
            .alignRules({
              right: { anchor: '__container__', align: HorizontalAlign.End },
              top: { anchor: '__container__', align: VerticalAlign.Top },
            })
            .margin({ top: 8, right: this.searchBarMarginRight })
        } else {
          // Top toolbar
          TextInput({ placeholder: 'Search' })
            .id('search_input')
            .backgroundColor($r("app.color.color_white_ninety_percent"))
            .placeholderColor($r("app.color.color_white_forty_percent"))
            .placeholderFont({ size: 16 })
            .alignRules({
              top: { anchor: '__container__', align: VerticalAlign.Top },
              right: { anchor: '__container__', align: HorizontalAlign.End }
            })
            .width(328)
            .height(40)
            .margin({ top: 8, right: this.searchBarMarginRight })
            .padding({ left: 36 })
            .focusable(false)

          Image($r('app.media.search'))
            .width(16)
            .alignRules({
              left: { anchor: 'search_input', align: HorizontalAlign.Start },
              center: { anchor: 'search_input', align: VerticalAlign.Center },
            })
            .margin({ left: 12 })
        }
        Image($r('app.media.pc_title_back'))
          .width(40)
          .height(40)
          .id('back_img')
          .focusable(false)
          .alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          })
          .margin({ left: 32, top: 8, bottom: 8 })
          .onClick(() => {
            this.pageStack.pop()
          })
      }
    } else {
      RelativeContainer() {
        Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
          TabContent() {
            this.SwiperBuilder()
          }
        }
        .barHeight(0)
        .scrollable(false)

        RelativeContainer() {
          Image($r('app.media.home_tab_top_menu'))
            .id('menu')
            .width(40)
            .height(40)
            .margin({ top: 8, bottom: 8 })
            .alignRules({
              top: { 'anchor': '__container__', 'align': VerticalAlign.Top },
              left: { 'anchor': '__container__', 'align': HorizontalAlign.Start }
            })

          Image($r('app.media.home_tab_top_search'))
            .id('search')
            .width(40)
            .height(40)
            .margin({ top: 8, bottom: 8 })
            .alignRules({
              top: { 'anchor': '__container__', 'align': VerticalAlign.Top },
              right: { 'anchor': '__container__', 'align': HorizontalAlign.End }
            })

          Scroll(this.scroller) {
            Row({ space: 16 }) {
              ForEach(this.tabData, (tabTitle: ResourceStr, index: number) => {
                this.Tab(index, tabTitle)
              }, (item: string) => item)
            }.justifyContent(FlexAlign.Center)
          }
          .id('top_tabs')
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Horizontal)
          .layoutWeight(1)
          .margin({ left: 4, right: 4 })
          .alignRules({
            left: { 'anchor': 'menu', 'align': HorizontalAlign.End },
            right: { 'anchor': 'search', 'align': HorizontalAlign.Start },
            middle: { 'anchor': '__container__', 'align': HorizontalAlign.Center }
          })
          .onAppear(() => {
            // The recommended tab is selected by default
            this.scroller.scrollEdge(Edge.End)
          })
        }
        .width('100%')
        .padding({
          left: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
          right: new BreakpointType(16, 24, 32).getValue(this.currentWidthBreakpoint),
          top: this.topRectHeight
        })
        .height(56 + this.topRectHeight)
        .visibility(this.hideTab ? Visibility.None : Visibility.Visible)
        .linearGradient({
          colors: [[$r('app.color.color_black_ninety_five_percent'), 0.0],
            [$r('app.color.color_black_ninety_five_percent'), 0.5],
            [Color.Transparent, 1.0]]
        })
      }
    }
  }

  aboutToDisappear(): void {
    // [Start sensor_off_callback]
    // Destroy listener
    AdaptiveRotation.getInstance().reset()
    ScreenModeNotifier.getInstance().destroy()
    // [End sensor_off_callback]
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        this.windowClass?.off('windowTitleButtonRectChange', this.onWindowTitleButtonRectChange)
      } catch (error) {
        hilog.error(DOMAIN, LOG_TAG, `Off windowTitleButtonRectChange failed.`);
      }
    }
  }

  aboutToAppear(): void {
    try {
      this.windowClass = this.context.windowStage.getMainWindowSync();
    } catch (error) {
      hilog.error(DOMAIN, LOG_TAG, `Get windowClass failed.`);
    }
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        this.searchBarMarginRight = this.windowClass?.getTitleButtonRect().width ?? 140
      } catch (error) {
        hilog.error(DOMAIN, LOG_TAG, `Get window title button rect failed.`);
      }
      try {
        this.windowClass?.on('windowTitleButtonRectChange', this.onWindowTitleButtonRectChange)
      } catch (error) {
        hilog.error(DOMAIN, LOG_TAG, `On window windowTitleButtonRectChange failed.`);
      }
    }
  }

  private onWindowTitleButtonRectChange: (titleButtonRect: window.TitleButtonRect) => void =
    (titleButtonRect: window.TitleButtonRect) => {
      if (canIUse('SystemCapability.Window.SessionManager')) {
        this.searchBarMarginRight = titleButtonRect.width
      }
    }
}