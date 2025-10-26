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

import { display, window } from '@kit.ArkUI';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { BreakpointSystem } from '../utils/BreakpointSystem';
import { IndexNavDestination } from '../view/IndexNavDestination';
import { HomeConstants } from '../constants/HomeConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { i18n } from '@kit.LocalizationKit';
import Logger from '../utils/Logger';

@Entry
@Component
struct Index {
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.LANGUAGE) language: string = CommonConstants.CHINESE_LANGUAGE;
  @State windowsHeight: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();
  private indexPage: string = CommonConstants.CHINESE_LANGUAGE;

  @Builder
  PageMap(name: string) {
    if (name === this.indexPage) {
      IndexNavDestination({ windowsHeight: this.windowsHeight });
    } else {
      NavDestination()
        .hideTitleBar(true);
    }
  }

  aboutToAppear(): void {
    try {
      let systemLanguage: string = i18n.System.getSystemLanguage();
      let local = new Intl.Locale(systemLanguage);
      this.language = local.language;
    } catch (err) {
      Logger.error(`call System.getSystemLanguage() failed`);
    }
    if (this.language === CommonConstants.CHINESE_LANGUAGE) {
      this.indexPage = HomeConstants.INDEX_PAGE;
    } else {
      this.indexPage = HomeConstants.INDEX_PAGE_EN;
    }
    this.pageInfos.pushPath({ name: this.indexPage }, false);
    try {
      this.windowsHeight = this.getUIContext().px2vp(display.getDefaultDisplaySync().height);
    } catch (error) {
      Logger.error(`getDefaultDisplaySync failed`);
    }
    this.breakpointSystem.register();
    window.getLastWindow(this.getUIContext().getHostContext()).then(win => {
      win.setWindowLayoutFullScreen(true);
      let area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      let height = area.topRect.height;
      let vpHeight = this.getUIContext().px2vp(height);
      AppStorage.setOrCreate('topHeight', vpHeight);
    }).catch(() => {
      Logger.error(`getLastWindow failed`);
    });
  }

  aboutToDisappear(): void {
    this.breakpointSystem.unregister();
  }

  build() {
    Navigation(this.pageInfos) {
    }
    .hideNavBar(true)
    .mode(NavigationMode.Split)
    .hideToolBar(true)
    .hideTitleBar(true)
    .navDestination(this.PageMap);
  }
}