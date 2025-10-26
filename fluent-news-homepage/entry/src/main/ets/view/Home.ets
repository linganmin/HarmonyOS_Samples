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

import { deviceInfo } from '@kit.BasicServicesKit';
// [Start lottie]
// Home.ets
import lottie, { AnimationItem } from '@ohos/lottie';
// [End lottie]
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { ResourceUtil } from '../utils/ResourceUtil';
import { BlankView } from './BlankView';
import { HomeContent } from './HomeContent';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { ComponentContent } from '@kit.ArkUI';

@Component
export struct Home {
  @State currentBottomIndex: number = 0;
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageProp('currentColorMode') @Watch('onColorModeChange')
  currentMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  // [Start rendering_settings1]
  // Home.ets
  private renderingSettings1: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext1: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings1);
  // [End rendering_settings1]
  private renderingSettings2: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext2: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings2);
  private renderingSettings3: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext3: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings3);
  private tabOption1: TabBarOption = {
    index: 0,
    text: $r('app.string.tab_bar_option_one'),
    name: 'tab1',
    path: ResourceUtil.getLottiePath('tabbar1', this.currentMode),
    canvasRenderingContext: this.canvasRenderingContext1,
    currentBottomIndex: this.currentBottomIndex,
    currentBreakpoint: this.currentBreakpoint,
  };
  private tabOption2: TabBarOption = {
    index: 1,
    text: $r('app.string.tab_bar_option_two'),
    name: 'tab2',
    path: ResourceUtil.getLottiePath('tabbar2', this.currentMode),
    canvasRenderingContext: this.canvasRenderingContext2,
    currentBottomIndex: this.currentBottomIndex,
    currentBreakpoint: this.currentBreakpoint,
  };
  private tabOption3: TabBarOption = {
    index: 2,
    text: $r('app.string.tab_bar_option_three'),
    name: 'tab3',
    path: ResourceUtil.getLottiePath('tabbar3', this.currentMode),
    canvasRenderingContext: this.canvasRenderingContext3,
    currentBottomIndex: this.currentBottomIndex,
    currentBreakpoint: this.currentBreakpoint,
  };
  private tabBarOption1 = new ComponentContent(this.getUIContext(), wrapBuilder<[TabBarOption]>(BottomTabBuilder),
    this.tabOption1);
  private tabBarOption2 = new ComponentContent(this.getUIContext(), wrapBuilder<[TabBarOption]>(BottomTabBuilder),
    this.tabOption2);
  private tabBarOption3 = new ComponentContent(this.getUIContext(), wrapBuilder<[TabBarOption]>(BottomTabBuilder),
    this.tabOption3);

  onColorModeChange(): void {
    this.destroyLottie();
    // 1.更新所有TabBarOption的路径
    this.tabOption1.path = ResourceUtil.getLottiePath('tabbar1', this.currentMode)
    this.tabOption2.path = ResourceUtil.getLottiePath('tabbar2', this.currentMode)
    this.tabOption3.path = ResourceUtil.getLottiePath('tabbar3', this.currentMode)

    this.tabBarOption1 = new ComponentContent(this.getUIContext(), wrapBuilder<[TabBarOption]>(BottomTabBuilder),
      this.tabOption1);
    this.tabBarOption2 = new ComponentContent(this.getUIContext(), wrapBuilder<[TabBarOption]>(BottomTabBuilder),
      this.tabOption2);
    this.tabBarOption3 = new ComponentContent(this.getUIContext(), wrapBuilder<[TabBarOption]>(BottomTabBuilder),
      this.tabOption3);

    // 2. 强制触发Tabs重建
    const indexBak = this.currentBottomIndex;
    this.currentBottomIndex = -1; // 临时重置索引
    setTimeout(() => {
      this.currentBottomIndex = indexBak; // 恢复索引触发动画加载
    }, 0);
  }

  aboutToDisappear(): void {
    this.destroyLottie();
  }

  build() {
    Column() {
      Tabs({
        barPosition: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
        BarPosition.Start : BarPosition.End
      }) {
        TabContent() {
          HomeContent()
        }
        .tabBar(this.tabBarOption1)

        TabContent() {
          BlankView()
        }
        .tabBar(this.tabBarOption2)

        TabContent() {
          BlankView()
        }
        .tabBar(this.tabBarOption3)

      }
      .barWidth(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
      $r('app.float.bottom_tab_bar_width_lg') : CommonConstants.FULL_PERCENT)
      .barHeight(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? CommonConstants.FULL_PERCENT :
        ((deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[0] ? CommonConstants.TAB_BAR_HEIGHT :
          CommonConstants.TAB_BAR_HEIGHT + CommonConstants.BOTTOM_RECT_HEIGHT)))
      .barBackgroundColor($r('app.color.start_window_background'))
      .barMode(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? BarMode.Scrollable : BarMode.Fixed,
        { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
      .vertical(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG)
      // [Start on_animation_start]
      // Home.ets
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
        this.currentBottomIndex = targetIndex;
        this.lottieController();
      })
      // [End on_animation_start]
      .scrollable(false)
    }
  }

  // [Start lottie_controller]
  // Home.ets
  lottieController(): void {
    if (this.currentBottomIndex === 0) {
      lottie.stop();
      lottie.play(this.tabOption1.name);
    }
    if (this.currentBottomIndex === 1) {
      lottie.stop();
      lottie.play(this.tabOption2.name);
    }
    if (this.currentBottomIndex === 2) {
      lottie.stop();
      lottie.play(this.tabOption3.name);
    }
  }

  // [End lottie_controller]

  destroyLottie() {
    this.tabOption1.lottieItem?.removeEventListener('DOMLoaded');
    this.tabOption2.lottieItem?.removeEventListener('DOMLoaded');
    this.tabOption3.lottieItem?.removeEventListener('DOMLoaded');
    lottie.destroy(this.tabOption1.name);
    lottie.destroy(this.tabOption2.name);
    lottie.destroy(this.tabOption3.name);
  }
}

@Builder
function BottomTabBuilder(tabBarOption: TabBarOption) {
  Column() {
    // [Start canvas]
    // Home.ets
    Canvas(tabBarOption.canvasRenderingContext)
      .width($r('app.float.canvas_size'))
      .height($r('app.float.canvas_size'))
      .onReady(() => {
        tabBarOption.canvasRenderingContext.imageSmoothingEnabled = true;
        tabBarOption.canvasRenderingContext.imageSmoothingQuality = 'medium';
        lottie.destroy(tabBarOption.name);
        const item = lottie.loadAnimation({
          container: tabBarOption.canvasRenderingContext,
          renderer: 'canvas',
          loop: false,
          autoplay: false,
          autoSkip: false,
          name: tabBarOption.name,
          path: tabBarOption.path,
        });
        tabBarOption.lottieItem = item;
        item.addEventListener('DOMLoaded', (args: Object): void => {
          if (tabBarOption.index === tabBarOption.currentBottomIndex) {
            item.play();
          }
        })
      })
    // [End canvas]
    Text(tabBarOption.text)
      .fontSize($r('app.float.tab_font_size'))
      .fontWeight(CommonConstants.FONT_WEIGHT_500)
      .fontColor(tabBarOption.currentBottomIndex === tabBarOption.index ? $r('app.color.tab_sel_color') :
      ResourceUtil.getCommonBackgroundColor()[3])
      .margin({ top: $r('app.float.tab_top_margin') })
      .opacity(tabBarOption.currentBottomIndex === tabBarOption.index ?
      CommonConstants.TEXT_OPACITY[0] : CommonConstants.TEXT_OPACITY[1])
  }
  .padding({
    bottom: deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[0] ? 0 : CommonConstants.BOTTOM_RECT_HEIGHT
  })
  .height(tabBarOption.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.side_tab_bar_height') :
  CommonConstants.FULL_PERCENT)
  .width(CommonConstants.FULL_PERCENT)
  .justifyContent(FlexAlign.Center)
}

// [Start tab_bar_option]
// Home.ets
interface TabBarOption {
  index: number;
  text: ResourceStr;
  name: string;
  path: string;
  canvasRenderingContext: CanvasRenderingContext2D;
  lottieItem?: AnimationItem;
  currentBottomIndex?: number;
  currentBreakpoint?: string;
}

// [End tab_bar_option]