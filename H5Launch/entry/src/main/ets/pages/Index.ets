/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { webview } from '@kit.ArkWeb';
import { DataCache } from '@hadss/datacache';
import { connection } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FULL_HEIGHT, FULL_WIDTH } from '../common/constant/CommonConstants';
import * as Const from '../common/constant/CommonConstants';
import { ResData } from '../common/types/CommonTypes';
import { Config } from '../common/utils/Common';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const storage = uiContext?.getSharedLocalStorage()

@Entry(storage)
@Component
struct Index {
  webviewController: webview.WebviewController = new webview.WebviewController();
  responseResource: WebResourceResponse = new WebResourceResponse();
  init: boolean = true;
  uiContext = this.getUIContext();
  @LocalStorageLink('List') List: ResData[] = [];
  @State hasNet: boolean = true;

  aboutToAppear(): void {
    connection.hasDefaultNet().then((data: boolean) => {
      this.hasNet = data;
    });
  }

  build() {
    Column() {
      if (!this.hasNet) {
        this.failLayout()
      } else {
        Row() {
          Button($r('app.string.clear'))
            .padding({ left: Const.CLEAR_PADDING, right: Const.CLEAR_PADDING })
            .backgroundColor($r('app.color.transparent'))
            .borderColor($r('app.color.clear_fontcolor'))
            .borderWidth(Const.CLEAR_BORDER_WIDTH)
            .fontColor($r('app.color.clear_fontcolor'))
            .height(Const.CLEAR_HEIGHT)
            .fontSize(Const.CLEAR_FONT_SIZE)
            .fontWeight(Const.CLEAR_FONT_WEIGHT)
            .onClick(() => {
              DataCache.getInstance(this.uiContext?.getHostContext() as Context).clear().then(() => {
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.clear_success'),
                  duration: Const.ANIMATION_DURATION
                });
              });
            })
        }
        .position({ top: 0, right: Const.LIST_MARGIN_LEFT as Dimension })
        .zIndex(Const.TAB_Z_INDEX)
        .height(Const.TAB_HEIGHT)
        .align(Alignment.End)
        .width('auto')
        .justifyContent(FlexAlign.SpaceBetween)

        Web({
          src: `${Const.URL}/?filename=${(this.uiContext?.getHostContext() as Context)
            .resourceManager.getStringSync($r('app.string.fileName').id)}`,
          controller: this.webviewController
        })
          .domStorageAccess(true)
          .zoomAccess(true)
          .fileAccess(true)
          .mixedMode(MixedMode.All)
          .width(FULL_WIDTH)
          .height(FULL_HEIGHT)
          .onPageBegin(() => {
            this.webviewController.onActive();
          })
          .onControllerAttached(() => {
            // configure precompiled JavaScript file information
            const configs: Array<Config> = [
              {
                url: Const.URL + '/js/chunk-vendors.b49231f7.js',
                localPath: 'chunk-vendors.b49231f7.js',
                options: {
                  responseHeaders: []
                }
              },
              {
                url: Const.URL + '/js/app.5122dce5.js',
                localPath: 'app.5122dce5.js',
                options: {
                  responseHeaders: []
                }
              }
            ]

            const resourceMapArr: Array<webview.OfflineResourceMap> = [{
              urlList: [Const.URL + '/css/app.bcf61a4e.css'],
              resource: (this.uiContext?.getHostContext() as Context).resourceManager.getRawFileContentSync('app.bcf61a4e.css'),
              responseHeaders: [],
              type: webview.OfflineResourceType.CSS,
            }];
            // read configuration and precompile
            for (const config of configs) {
              let content = (this.uiContext?.getHostContext() as Context).resourceManager.getRawFileContentSync(config.localPath)
              resourceMapArr.push({
                urlList: [config.url],
                resource: content,
                responseHeaders: config.options.responseHeaders,
                type: webview.OfflineResourceType.CLASSIC_JS,
              })

              try {
                // precompile
                this.webviewController.precompileJavaScript(config.url, content, config.options)
                  .then(() => {
                    hilog.info(0x0000, 'testTag', 'precompile successfully!');
                  }).catch((errCode: number) => {
                  hilog.error(0x0000, 'testTag', 'precompile failed.' + errCode);
                })
              } catch (err) {
                hilog.error(0x0000, 'testTag', 'precompile failed!.' + err.code + err.message);
              }
            }
            // offline resource injection
            this.webviewController.injectOfflineResources(resourceMapArr);
          })
            // resource interception replacement
          .onInterceptRequest(event => {
            if (event) {
              const url = event.request.getRequestUrl();
              if (this.init &&
                url === Const.URL + `/api/getSceneMockData?scene=newsData&fileName=${(this.uiContext?.getHostContext() as Context)
                  .resourceManager
                  .getStringSync($r('app.string.fileName').id)}.json&pageNum=1&pageSize=5` &&
                this.List.length !== 0) {
                this.init = false;
                this.responseResource.setResponseData(JSON.stringify({ data: this.List }));
                this.responseResource.setResponseEncoding('utf-8');
                this.responseResource.setResponseMimeType('text/json');
                this.responseResource.setResponseCode(200);
                this.responseResource.setReasonMessage('OK');
                this.responseResource.setResponseHeader([{ headerKey: 'Access-Control-Allow-Origin', headerValue: '*' }]);
                return this.responseResource;
              }
            }
            return null;
          })
      }
    }
    .height(FULL_HEIGHT)
    .width(FULL_WIDTH)
  }

  @Builder
  failLayout() {
    Column() {
      Image($r('app.media.none'))
        .height(Const.LIST_NONE_IMAGE_SIZE)
        .width(Const.LIST_NONE_IMAGE_SIZE)
      Text($r('app.string.page_none_msg'))
        .opacity(Const.LIST_NONE_TEXT_OPACITY)
        .fontSize(Const.LIST_NONE_TEXT_SIZE)
        .fontColor($r('app.color.fontColor_text3'))
        .margin({ top: Const.LIST_NONE_TEXT_MARGIN })
    }
    .width(Const.FULL_WIDTH)
    .height(Const.FULL_HEIGHT)
    .justifyContent(FlexAlign.Center)
  }
}