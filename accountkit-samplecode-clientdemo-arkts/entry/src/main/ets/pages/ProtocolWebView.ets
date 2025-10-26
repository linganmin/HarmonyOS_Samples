/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { webview } from '@kit.ArkWeb';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { connection } from '@kit.NetworkKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';
import { getWhiteSpaceWidthByDisplayWidth } from '../common/Utils';

const logTag: string = 'ProtocolWebView';
const domainId: number = 0x0000;

@Component
export struct ProtocolWebView {
  storage: LocalStorage = new LocalStorage();
  @State progress: number = 0;
  private controller: webview.WebviewController = new webview.WebviewController();
  private url: string = '';
  private isFromDialog: boolean = false;
  pageInfos: NavPathStack = new NavPathStack();
  params?: Record<string, Object>;
  @LocalStorageProp('displayWidth') displayWidth: number = 0;
  @LocalStorageProp('isLandScape') isLandScape: boolean = false;
  @LocalStorageProp('isPhone') isPhone: boolean = true;
  @StorageProp('colorMode') @Watch('onColorModeModify') colorMode?: number = ColorMode.LIGHT;

  aboutToAppear(): void {
    hilog.info(domainId, logTag, 'ProtocolWebView aboutToAppear');
    // Obtain the passed parameter object.
    if (this.params && this.params !== null) {
      this.isFromDialog = (this.params['isFromDialog'] ?? false) as boolean;
      this.url = (this.params['protocolUrl'] ?? '') as string;
    }
    hilog.info(domainId, logTag, `webView aboutToAppear isFromDialog: ${this.isFromDialog}`);
  }

  backPress(): void {
    const params: Record<string, Object> = {
      'isFromWeb': this.isFromDialog
    };
    hilog.info(domainId, logTag, `webView backPress isFromDialog: ${this.isFromDialog}`);
    if (this.isFromDialog) {
      this.pageInfos?.popToName('QuickLoginPage', params, true);
    }
  }

  // Toast message.
  showToast(resource: Resource) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: resource,
        duration: 2000
      });
    } catch (error) {
      const message = error.message as string;
      const code = error.code as string;
      hilog.error(domainId, logTag, `Failed to showToast, errCode is ${code}, errMessage is ${message}`);
    }
  }

  // Modify the bgmode parameter of the agreement link when the dark/light mode of the system is changed.
  onColorModeModify() {
    try {
      if (this.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
        // URL used in light mode.
        this.controller.loadUrl(this.url);
      } else {
        // URL used in dark mode.
        this.controller.loadUrl(this.url + '&bgmode=black');
      }
    } catch (error) {
      hilog.error(domainId, logTag, `Failed to loadUrl, errCode is ${error?.code}, errMessage is ${error?.message}`);
    }
  }

  // Adjust the width of the web component based on the screen width.
  getWebviewWidth() {
    // Original margin of the agreement page.
    const WEB_PAGE_MARGIN = 32;
    // Margin required by the web component.
    const UI_PAGE_MARGIN = this.isLandScape && this.isPhone ?
      40 : getWhiteSpaceWidthByDisplayWidth(this.displayWidth);
    return ((this.displayWidth + (WEB_PAGE_MARGIN - UI_PAGE_MARGIN) * 2) * 100 / this.displayWidth).toFixed(2) + '%';
  }

  // Check whether the link is an internal web page link and return to the previous URL using a gesture.
  onCheckOtherWeb(): boolean {
    try {
      const url = this.controller.getUrl();
      if (url !== this.url && url !== this.url + '&bgmode=black') {
        this.controller.backward();
        return true;
      }
      return false;
    } catch (error) {
      hilog.error(domainId, logTag, `Failed to getUrl, errCode is ${error?.code}, errMessage is ${error?.message}`);
      return false;
    }
  }

  build() {
    NavDestination() {
      Column() {
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.hwid_next_ic_appback'))
            .backgroundColor(Color.Transparent)
            .borderRadius(20)
            .width(40)
            .height(40)
            .draggable(false)
            .autoResize(false)
            .focusable(true)
            .fillColor($r('sys.color.ohos_id_color_titlebar_icon'))
            .matchTextDirection(true)
        }
        .alignSelf(ItemAlign.Start)
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .borderRadius(20)
        .width(40)
        .height(40)
        .margin({
          top: 36,
          bottom: $r('sys.float.ohos_id_elements_margin_horizontal_m'),
          left: this.isLandScape && this.isFromDialog ?
            40 : getWhiteSpaceWidthByDisplayWidth(this.displayWidth)
        })
        .id('hwidNextIcAppBackButton')
        .onClick(() => {
          AvoidRepeatClick.avoidRepeatClick(() => {
            if (this.isFromDialog) {
              this.backPress();
            } else {
              if (this.pageInfos && this.pageInfos.size() > 1) {
                this.pageInfos.pop();
              }
            }
          });
        })

        Progress({ value: this.progress, type: ProgressType.Linear })
          .width('100%')
          .visibility(this.progress <= 99 ? Visibility.Visible : Visibility.None)
        Web({
          src: this.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ? this.url :
            this.url + '&bgmode=black',
          controller: this.controller
        })
          .javaScriptAccess(true)
          .geolocationAccess(false)
          .fileAccess(false)
          .width(this.getWebviewWidth())
          .margin({
            bottom: 60
          })
          .darkMode(WebDarkMode.Auto)
          .backgroundColor($r('sys.color.ohos_id_color_background'))
          .onProgressChange((event) => {
            hilog.info(domainId, logTag,
              'onProgressChange: ', (event ? event.newProgress : -1));
            this.progress = event ? event.newProgress : 0;
          })
          .onAppear(() => {
            try {
              const checkNetConn = connection.hasDefaultNetSync();
              hilog.info(domainId, logTag, `network status: ${checkNetConn}`);
              if (!checkNetConn) {
                this.showToast($r('app.string.service_error'));
                return;
              }
            } catch (error) {
              const message = error.message as string;
              const code = error.code as string;
              hilog.error(domainId, logTag,
                `Failed to invoke the hasDefaultNetSync method. errCode is ${code}, errMessage is ${message}`);
            }
          })
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: 60 })
    }.hideTitleBar(true)
    .onBackPressed(() => {
      if (this.onCheckOtherWeb()) {
        return true;
      }
      this.backPress();
      // Directly return to the sign-in screen from a pop-up window. No gesture is needed.
      return this.isFromDialog;
    })
  }
}
