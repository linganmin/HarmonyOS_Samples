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

import { BusinessError } from '@kit.BasicServicesKit';
import { router, promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { window } from '@kit.ArkUI';
import { common, Want } from '@kit.AbilityKit';
import { CommonConstants } from '../../constants/CommonConstants';
import { ArkTSFunModel } from '../../viewmodel/web/ProductModel';
import { i18n } from '@kit.LocalizationKit';
import { BreakpointConstants } from '../../constants/BreakpointConstants';
import { BreakpointType } from '../../utils/BreakpointSystem';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = '[IndexPage]';

@Entry
@Component
struct WebPageComponent {
  @StorageLink('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) @Watch('changeWebListCount') currentBreakpoint: string =
    BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('continueRestore') continueRestore: boolean = false;
  @StorageLink('pageUrl') @Watch('watchPageUrl') pageUrl: string = 'resource://rawfile/product_list.html';
  @StorageLink('scrollDistance') scrollDistance: number = 0;
  @StorageLink('bottomHeight') bottomHeight: number = 0;
  @StorageLink('topHeight') topHeight: number = 0;
  @StorageLink('continueEntry') continueEntry: boolean = false;
  @StorageLink('currentPage') currentPage: string = '';
  @State webCanBack: boolean = false;
  @State onPageEnd: boolean = false;
  @State webCanForward: boolean = false;
  @State controller: webview.WebviewController = new webview.WebviewController();
  @State statusBarHeight: number = 0;
  @State sliderBarHeight: number = 56;
  arkTSObj: ArkTSFunModel = {
    jumpOrderConfirm: (detailStr: string) => this.jumpOrderConfirm(detailStr)
  };

  watchPageUrl() {
    if (this.continueRestore) {
      this.controller.loadUrl(this.pageUrl);
      this.continueRestore = false;
    }
  }

  jumpOrderConfirm(detailStr: string): void {
    this.getUIContext().getRouter().pushUrl({
      url: 'pages/OrderConfirmPage',
      params: { statusBarHeight: this.statusBarHeight, sliderBarHeight: this.sliderBarHeight, detailStr }
    });
  }

  changeWebListCount() {
    let column = new BreakpointType({
      sm: 'javascript:document.getElementById("productList").style["column-count"] = 1',
      md: 'javascript:document.getElementById("productList").style["column-count"] = 2',
      lg: 'javascript:document.getElementById("productList").style["column-count"] = 3'
    }).getValue(this.currentBreakpoint);
    this.controller.runJavaScript(column);
    let columnGap = new BreakpointType({
      sm: 'javascript:document.getElementById("productList").style["column-gap"] = 0px',
      md: 'javascript:document.getElementById("productList").style["column-gap"] = 20px',
      lg: 'javascript:document.getElementById("productList").style["column-gap"] = 40px'
    }).getValue(this.currentBreakpoint);
    this.controller.runJavaScript(columnGap);
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.back'))
            .width(40)
            .height(40)
            .margin({
              right: 8
            })
            .onClick(() => {
              if (this.pageUrl.includes('product_list')) {
                this.pageInfos.pop();
              } else if (this.pageUrl.includes('product_detail')) {
                this.controller.loadUrl(i18n.System.getSystemLanguage() === 'zh-Hans' ?
                  'resource://rawfile/product_list.html' :
                  'resource://rawfile/product_list_en.html');
              }
            })
          Text($r('app.string.tittle'))
            .fontSize(20)
            .fontWeight(700)
            .lineHeight(27)
        }
        .backgroundColor(this.pageUrl && this.pageUrl.includes('product_list') ? '#FFF1F3F5' : '#00000000')
        .height(56)
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .padding({
          left: 19,
          right: 19
        })
        .margin({
          top: this.topHeight
        })

        // [Start web_on_page_end]
        Web({ src: this.pageUrl, controller: this.controller })
        // [StartExclude web_on_page_end]
          .layoutWeight(1)
          .javaScriptProxy({
            object: this.arkTSObj,
            name: 'arkTSFunObj',
            methodList: ['jumpOrderConfirm'],
            controller: this.controller
          })
          .onConfirm(() => {
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.toast_msg'),
              duration: CommonConstants.TOAST_DURATION
            });
            return false;
          })
          .layoutWeight(1)
          // [EndExclude web_on_page_end]
          .onPageEnd(async () => {
            // [StartExclude web_on_page_end]
            this.changeWebListCount();
            this.webCanBack = this.controller.accessBackward();
            this.webCanForward = this.controller.accessForward();
            this.onPageEnd = true;
            // [EndExclude web_on_page_end]
            if (this.pageUrl.includes('product_list') && this.continueRestore) {
              this.controller.runJavaScript('javascript:document.getElementById("productList").scrollTop = ' +
              this.scrollDistance);
            }
            this.pageUrl = this.controller.getUrl();
            let result =
              await this.controller.runJavaScript('javascript:document.getElementById("productList").scrollTop');
            this.scrollDistance = Number(result);
          })
          // [StartExclude web_on_page_end]
          .zoomAccess(false)
          // [EndExclude web_on_page_end]
          .onTouch(async (event: TouchEvent) => {
            if (event.type === TouchType.Up) {
              if (this.pageUrl.includes('product_list')) {
                let result =
                  await this.controller.runJavaScript('javascript:document.getElementById("productList").scrollTop');
                this.scrollDistance = Number(result);
              }
            }
          })
        // [End web_on_page_end]
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('app.color.common_bg'))
      .padding({
        bottom: this.pageUrl && this.pageUrl.includes('product_list') ? 0 : 28
      })
    }
    .hideTitleBar(true)
    .onAppear(() => {
      let url = AppStorage.get('pageUrl') as string;
      if (!url) {
        this.pageUrl = 'resource://rawfile/product_list.html';
      }
      webview.WebviewController.setWebDebuggingAccess(true);
      window.getLastWindow(this.getUIContext().getHostContext(), (err: BusinessError, windowClass: window.Window) => {
        if (err.code) {
          hilog.error(0x000, 'progress', TAG, 'Failed to obtain the main window. Cause: ' + JSON.stringify(err));
          return;
        }
        hilog.info(0x000, 'progress', TAG,
          'Succeeded in obtaining the main window. Data: ' + JSON.stringify(windowClass));

        // Realize the immersive effect.
        try {
          let type = window.AvoidAreaType.TYPE_SYSTEM;
          // Get status bar height.
          let area: window.AvoidArea = windowClass.getWindowAvoidArea(type);
          let statusBarHeight = this.getUIContext().px2vp(area.topRect.height);
          let sliderBarHeight = this.getUIContext().px2vp(area.bottomRect.height);
          this.statusBarHeight = statusBarHeight;
          this.sliderBarHeight = sliderBarHeight;
          if (statusBarHeight > 0) {
            windowClass.setWindowLayoutFullScreen(true);
          }
        } catch (exception) {
          hilog.error(0x000, 'progress', TAG,
            'Failed to set the system bar properties. Cause: ' + JSON.stringify(exception));
        }
      });
    })
    .onBackPressed(() => {
      if (this.pageUrl.includes('product_list')) {
        this.pageInfos.pop();
      } else if (this.pageUrl.includes('product_detail')) {
        this.controller.loadUrl(i18n.System.getSystemLanguage() === 'zh-Hans' ?
          'resource://rawfile/product_list.html' :
          'resource://rawfile/product_list_en.html');
      }
      return true;
    })
    .onShown(() => {
      hilog.info(0x000, 'progress', 'onShown currentPage ' + this.currentPage);
    })
  }
}

@Builder
export function WebPageComponentBuilder() {
  WebPageComponent()
}