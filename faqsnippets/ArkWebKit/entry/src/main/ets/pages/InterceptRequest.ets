/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

/*
* FAQ:onInterceptRequest拦截URL并自定义HTML文件，页面加载失败
*/

import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebviewAlert {
  controller: webview.WebviewController = new webview.WebviewController();
  responseWeb: WebResourceResponse | null = null;
  heads: Array<Header> = new Array;
  webData: number = 1;
  build() {
    Column() {
      // [Start InterceptRequest]
      Web({ src: 'www.example.com',controller: this.controller })
        .onInterceptRequest((event) => {
          console.log('url:' + event.request.getRequestUrl())
          this.responseWeb = new WebResourceResponse();
          let head1: Header = {
            headerKey: "Connection",
            headerValue: "keep-alive"
          }
          let length = this.heads.push(head1)
          this.responseWeb.setResponseHeader(this.heads)
          this.responseWeb.setResponseData(this.webData)
          this.responseWeb.setResponseEncoding('utf-8')
          this.responseWeb.setResponseMimeType('text/html')
          this.responseWeb.setResponseCode(200)
          this.responseWeb.setReasonMessage('OK')
          return this.responseWeb
        })
      // [End InterceptRequest]
    }
  }
}

