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

import web_webview from '@ohos.web.webview';
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

// Action image capture
const ACTION_IMAGE_CAPTURE: string = "ohos.want.action.imageCapture";
// Local html path
const LOCAL_HTML_PATH: string = "camera.html";
// Margin top
const MARGIN_TOP = 40

class FileResult {
  result: FileSelectorResult;
  fileSelector: FileSelectorParam;

  constructor(result: FileSelectorResult, fileSelector: FileSelectorParam) {
    this.result = result;
    this.fileSelector = fileSelector;
  }
}

@Entry
@Component
struct Index {
  controller: web_webview.WebviewController = new web_webview.WebviewController();

  build() {
    Column() {
      Web({ src: $rawfile(LOCAL_HTML_PATH), controller: this.controller })
        .onShowFileSelector((event: FileResult) => {
          this.invokeCamera(((uri: string) => {
            event?.result.handleFileList([uri]);
          }))
          return true;
        })
        .margin({ top: MARGIN_TOP })
        .backgroundColor(Color.Black)
    }
    .backgroundColor(Color.Black)
  }

  invokeCamera(callback: (uri: string) => void) {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const want: Want = {
      action: ACTION_IMAGE_CAPTURE,
      parameters: {
        'callBundleName': context.abilityInfo.bundleName,
      }
    };
    const result: (error: BusinessError, data: common.AbilityResult) => void = (error: BusinessError,
      data: common.AbilityResult) => {
      const resultUri: string = data.want?.parameters?.resourceUri as string;
      if (callback && resultUri) {
        callback(resultUri);
      }
    }
    context.startAbilityForResult(want, result);
  }
}