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
import { EnvironmentCallback } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { i18n } from '@kit.LocalizationKit';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';

@Entry
@Component
struct Index {
  @StorageLink('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.LANGUAGE) language: string = CommonConstants.CHINESE_LANGUAGE;
  @StorageLink('continueEntry') continueEntry: boolean = false;
  @StorageLink('topHeight') topHeight: number = 0;
  @StorageLink('bottomHeight') bottomHeight: number = 0;
  @StorageLink('currentPage') currentPage: string = '';

  aboutToAppear(): void {
    window.getLastWindow(this.getUIContext().getHostContext()).then(win => {
      win.setWindowLayoutFullScreen(true);
      let area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      let height = area.topRect.height;
      let vpHeight = this.getUIContext().px2vp(height);
      AppStorage.setOrCreate('topHeight', vpHeight);
      let bottomArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      let bottomHeight = bottomArea.bottomRect.height;
      let vpBottomHeight = this.getUIContext().px2vp(bottomHeight);
      AppStorage.setOrCreate('bottomHeight', vpBottomHeight);
    });
    let envCallback: EnvironmentCallback = {
      onConfigurationUpdated(config) {
        AppStorage.set(CommonConstants.LANGUAGE, config.language);
      },
      onMemoryLevel(level) {
      }
    };
    try {
      let applicationContext = this.getUIContext().getHostContext()?.getApplicationContext();
      applicationContext && applicationContext.on('environment', envCallback);
    } catch (paramError) {
      hilog.error(0x000, 'progress', `error: ${JSON.stringify(paramError)}`);
    }
  }

  onPageShow(): void {
    try {
      let systemLanguage: string = i18n.System.getSystemLanguage();
      let local = new Intl.Locale(systemLanguage);
      this.language = local.language;
    } catch (err) {
      hilog.error(0x000, 'progress', `call System.getSystemLanguage() failed`);
    }
    if (this.currentPage !== '') {
      let pageArr = this.pageInfos.getAllPathName();
      if (pageArr.length === 0) {
        this.pageInfos.pushPathByName(this.currentPage, null, true);
      } else if (pageArr[pageArr.length - 1] !== this.currentPage) {
        this.pageInfos.replacePathByName(this.currentPage, null, true);
      }
      this.currentPage = '';
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        Text($r('app.string.title'))
          .fontSize(30)
          .textAlign(TextAlign.Start)
          .width('100%')
          .fontWeight(FontWeight.Bold)
          .padding({
            top: 56
          })

        Column({ space: 12 }) {
          Button($r('app.string.button1'))
            .width('100%')
            .constraintSize({
              maxWidth: 448
            })
            .onClick(async () => {
              this.pageInfos.pushPathByName('LongListPage', null, true);
            })

          Button($r('app.string.button2'))
            .width('100%')
            .constraintSize({
              maxWidth: 448
            })
            .onClick(async () => {
              this.pageInfos.pushPathByName('VideoPage', null, true);
            })

          Button($r('app.string.button3'))
            .width('100%')
            .constraintSize({
              maxWidth: 448
            })
            .onClick(async () => {
              this.pageInfos.pushPathByName('WebPageComponent', null, true);
            })

        }
        .width('100%')
        .alignSelf(ItemAlign.End)
        .padding({
          bottom: 16
        })
      }
      .width('100%')
      .height('100%')
      .padding({
        left: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? 32 : 24,
        right: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? 32 : 24,
        top: this.topHeight,
        bottom: this.bottomHeight
      })
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('sys.color.container_modal_unfocus_background'))
  }
}