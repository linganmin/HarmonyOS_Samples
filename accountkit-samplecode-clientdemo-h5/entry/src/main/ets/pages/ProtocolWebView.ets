/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { webview } from '@kit.ArkWeb';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { connection } from '@kit.NetworkKit';

const logTag: string = 'ProtocolWebView';
const domainId: number = 0x0000;

@Component
export struct ProtocolWebView {
  @State progress: number = 0;
  private controller: webview.WebviewController = new webview.WebviewController();
  private url: string = '';
  @Consume('pageInfos') pageInfos?: NavPathStack;
  params?: Record<string, Object>;
  @LocalStorageProp('displayWidth') displayWidth: number = 0;
  @LocalStorageProp('isLandScape') isLandScape: boolean = false;
  @LocalStorageProp('isPhone') isPhone: boolean = true;

  aboutToAppear(): void {
    hilog.info(domainId, logTag, 'ProtocolWebView aboutToAppear');
    // Obtain the passed parameter object.
    if (this.params && this.params !== null) {
      this.url = (this.params['protocolUrl'] ?? '') as string;
    }
  }

  backPress(): void {
    this.pageInfos?.popToName('LoginPage', null, true);
  }

  // Check whether the link is an internal web page link and return to the previous URL using a gesture.
  onCheckOtherWeb(): boolean {
    const url = this.controller.getUrl();
    if (url !== this.url) {
      this.controller.backward();
      return true;
    }
    return false;
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
          bottom: $r('sys.float.ohos_id_elements_margin_horizontal_m'),
          left: 16,
          right: 16
        })
        .id('hwidNextIcAppBackButton')
        .onClick(() => {
          this.backPress();
        })

        Progress({ value: this.progress, type: ProgressType.Linear })
          .width('100%')
          .visibility(this.progress <= 99 ? Visibility.Visible : Visibility.None)
        Web({
          src: this.url,
          controller: this.controller
        })
          .layoutWeight(1)
          .javaScriptAccess(true)
          .geolocationAccess(false)
          .fileAccess(false)
          .width('100%')
          .backgroundColor($r('sys.color.ohos_id_color_background'))
          .onProgressChange((event) => {
            hilog.info(domainId, logTag,
              'onProgressChange: ', (event ? event.newProgress : -1));
            this.progress = event ? event.newProgress : 0;
          })
          .onAppear(() => {
            try {
              hilog.info(domainId, logTag, `network url: ${this.url}`);
              this.controller.loadUrl(this.url)
              const checkNetConn = connection.hasDefaultNetSync();
              hilog.info(domainId, logTag, `network status: ${checkNetConn}`);
              if (!checkNetConn) {
                return;
              }
            } catch (error) {
              const message = error.message as string;
              const code = error.code as string;
              hilog.error(domainId, logTag,
                `Failed to invoke the hasDefaultNetSync method. errCode is ${code}, errMessage is ${message}`);
            }
          })
          .onErrorReceive(() => {
            hilog.error(domainId, logTag, 'Failed to open');
          })
      }
      .width('100%')
    }
    .backgroundColor(Color.White)
    .hideTitleBar(true)
  }
}
