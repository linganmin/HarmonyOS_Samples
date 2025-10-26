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

import { ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { DarkModeSetting } from './DarkModeSetting';
import { Home } from './Home';
import { Mine } from './Mine';
import { hilog } from '@kit.PerformanceAnalysisKit';

// [Start state_start]
// src/main/ets/pages/Index.ets
// [Start monitor_start]
@Entry
@Component
struct Index {
  // [StartExclude state_start]
  // [StartExclude monitor_start]
  @Provide navPathStack: NavPathStack = new NavPathStack();
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  // [EndExclude monitor_start]
  @StorageProp('currentColorMode') @Watch('onCurrentColorModeChange') currentColorMode: ConfigurationConstant.ColorMode =
    ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  private windowObj: window.Window | null = null;

  aboutToAppear(): void {
    window.getLastWindow(this.getUIContext().getHostContext(), (err: BusinessError, data) => {
      if (err.code) {
        hilog.error(0x0000, 'Index', `getLastWindow failed. code=${err.code}, message=${err.message}`);
        return;
      }
      this.windowObj = data;
    })
  }

  onCurrentColorModeChange(): void {
    if (!this.windowObj) {
      return;
    }
    try {
      if (this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
        this.windowObj?.setWindowSystemBarProperties({
          statusBarContentColor: '#000000'
        })
      } else if (this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        this.windowObj?.setWindowSystemBarProperties({
          statusBarContentColor: '#FFFFFF'
        })
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index', `setWindowSystemBarProperties failed, error code=${err.code}, message=${err.message}`);
    }
  }

  // [StartExclude monitor_start]
  @Builder
  tabBuilder(title: ResourceStr, unSelectIcon: Resource, selectedIcon: Resource, targetIndex: number) {
    Column() {
      SymbolGlyph(this.currentIndex === targetIndex ? selectedIcon : unSelectIcon)
        .fontSize(24)
        .fontColor(this.currentIndex === targetIndex ?
          [$r('sys.color.icon_emphasize')] :
          [$r('sys.color.icon_secondary')])
        .symbolEffect(new BounceSymbolEffect(EffectScope.WHOLE, EffectDirection.UP),
          this.currentIndex === targetIndex ? true : false)
        .margin({ bottom: 4 })

      Text(title)
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(13)
        .fontColor(this.currentIndex === targetIndex ? $r('sys.color.icon_emphasize') : $r('sys.color.icon_secondary'))
    }
    .width('100%')
    .height(52 + this.bottomRectHeight)
    .padding({ top: 5 })
    .justifyContent(FlexAlign.Start)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex);
    })
  }

  @Builder
  PageMap(name: string) {
    if (name === 'darkModeSetting') {
      DarkModeSetting()
    }
  }

  // [EndExclude monitor_start]

  // [EndExclude state_start]
  build() {
    // [StartExclude monitor_start]
    Navigation(this.navPathStack) {
      // [StartExclude state_start]
      Tabs({ controller: this.tabsController }) {
        TabContent() {
          Home()
        }
        .tabBar(this.tabBuilder($r('app.string.home'), $r('sys.symbol.house'), $r('sys.symbol.house_fill'), 0))

        TabContent() {
        }
        .tabBar(this.tabBuilder($r('app.string.discover'), $r('sys.symbol.fast'), $r('sys.symbol.fast_fill'), 1))

        TabContent() {
          Mine()
        }.tabBar(this.tabBuilder($r('app.string.mine'), $r('sys.symbol.person'), $r('sys.symbol.person_fill'), 2))
      }
      .barPosition(BarPosition.End)
      .scrollable(false)
      .barHeight(52 + this.bottomRectHeight)
      .barOverlap(true)
      .barBackgroundColor('#1AE9E9E9')
      .barBackgroundBlurStyle(BlurStyle.COMPONENT_THICK)

      // [EndExclude state_start]
    }
    .backgroundColor($r('app.color.app_background_color'))
    .hideTitleBar(true)
    // [StartExclude state_start]
    .navDestination(this.PageMap)
    .padding({ top: this.topRectHeight })

    // [EndExclude state_start]
    // [EndExclude monitor_start]
  }
}

// [End state_start]
// [End monitor_start]