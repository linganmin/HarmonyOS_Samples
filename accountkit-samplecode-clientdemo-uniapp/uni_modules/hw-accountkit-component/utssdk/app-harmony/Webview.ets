/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { NativeEmbedBuilderOptions, defineNativeEmbed } from "@dcloudio/uni-app-runtime"
import { webview } from '@kit.ArkWeb';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { connection } from '@kit.NetworkKit';
import { buffer } from "@kit.ArkTS";
import { common } from "@kit.AbilityKit";

const logTag: string = 'WebView';
const domainId: number = 0x0000;
// Key value of the link to the HUAWEI ID User Authentication Agreement.
const PRIVACY_URL = 'privacy_url';

// Define the data that the webview page returns to uni-app.
interface onClickBackDetail {
  webClickBack: boolean
}

// Place all data that the component should return to uni-app within the specified field in detail.
interface onClickBackData {
  detail: onClickBackDetail
}

@Component
export struct WebView {
  @State progress: number = 0;
  private controller: webview.WebviewController = new webview.WebviewController();
  private url: string = '';
  // File used to configure the link to the HUAWEI ID User Authentication Agreement.
  private readonly srcPath = 'data.json';
  clickBack?: Function;

  aboutToAppear(): void {
    hilog.info(domainId, logTag, 'ProtocolWebView aboutToAppear');
    this.url = this.getProtocolUrl(PRIVACY_URL);
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

  // Adjust the width of the web component based on the screen width.
  getWebviewWidth() {
    // Original margin of the agreement page.
    const WEB_PAGE_MARGIN = 32;
    // Margin required by the web component.
    const UI_PAGE_MARGIN = 24;
    return ((1080 + (WEB_PAGE_MARGIN - UI_PAGE_MARGIN) * 2) * 100 / 1080).toFixed(2) + '%';
  }

  // Obtain the privacy policy address from rawfile.
  getProtocolUrl(privacyUrl: string): string {
    try {
      // Read files from /AppScope/resources/rawfile.
      const value: Uint8Array = (this.getUIContext()
        .getHostContext() as common.UIAbilityContext).resourceManager.getRawFileContentSync(this.srcPath);
      // Return the link to the HUAWEI ID User Authentication Agreement.
      return JSON.parse(buffer.from(value.buffer).toString())[privacyUrl] as string;
    } catch (error) {
      hilog.error(domainId, logTag, `Failed to get ProtocolUrl, errCode: ${error.code}, Message: ${error.message}`);
      return ''
    }
  }

  // Check whether the link is an internal web page link and return to the previous URL using a gesture.
  onCheckOtherWeb(): boolean {
    const url = this.controller.getUrl();
    if (url !== this.url && url !== this.url + '&bgmode=black') {
      this.controller.backward();
      return true;
    }
    return false;
  }

  build() {
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
        left: 24
      })
      .id('hwidNextIcAppBackButton')
      .onClick(() => {
        if (this.clickBack) {
          this.clickBack({ detail: { webClickBack: true } } as onClickBackData);
        }
      })

      Progress({ value: this.progress, type: ProgressType.Linear })
        .width('100%')
        .visibility(this.progress <= 99 ? Visibility.Visible : Visibility.None)
      Web({
        src: this.url,
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
  }
}

@Builder
function WebViewBuilder(webviewparams: NativeEmbedBuilderOptions) {
  WebView({
    clickBack: webviewparams?.on?.get('webview_click_back')
  })
    .width(webviewparams.width)
    .height(webviewparams.height)
}

// Declare the components that need to be embedded into uni-app.
defineNativeEmbed('webview', {
  builder: WebViewBuilder
})