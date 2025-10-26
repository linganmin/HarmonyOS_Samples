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
* FAQ:如何使用Web组件下载pdf文件并展示给用户
*/

// [Start UseWebDownloadPdf]
import { webview } from '@kit.ArkWeb';
import { common } from '@kit.AbilityKit';
import { request } from '@kit.BasicServicesKit';

let context = AppStorage.get("context") as UIContext;
let filesDir = context.getHostContext()!.filesDir;
let config: request.agent.Config = {
  action: request.agent.Action.DOWNLOAD,
  url: 'https://www-file.huawei.com/minisite/media/annual_report/annual_report_2023_cn.pdf',
  title: 'createTest',
  description: 'Sample code for create task',
  mode: request.agent.Mode.FOREGROUND,
  overwrite: true,
  method: 'get',
  saveas: filesDir + '/test.pdf',
  network: request.agent.Network.WIFI,
  metered: false,
  roaming: true,
  retry: true,
  redirect: true,
  index: 0,
  begins: 0,
  ends: -1,
  gauge: false,
  precise: false,
  token: 'it is a secret'
};
let createOnCallback = (progress: request.agent.Progress) => {
  console.info('download task completed.');
  context.getPromptAction().showToast({
    message: 'Download completed',
    duration: 2000
  });
};

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();
  @State uri: string = '';
  @State isChange: boolean = false;

  build() {
    Column() {
      Button('Refresh UI')
        .width('200vp')
        .onClick(() => {
          this.controller.loadUrl('file://' + filesDir + '/test.pdf');
        })
        .margin({ bottom: '20vp' })
      Web({ src: $rawfile('WebDownloadPDF.html'), controller: this.controller })
        .fileAccess(true)
        .domStorageAccess(true)
        .onPageBegin((event) => {
          request.agent.create(this.getUIContext().getHostContext(), config).then((task: request.agent.Task) => {
            task.on('completed', createOnCallback);
            console.info(`Succeeded in creating a download task. result: ${task.config}`);
            task.start();
          }).catch((err: Error) => {
            console.error(`Failed to create a download task, message: ${err.message}`);
          });
        })
    }
  }
}
// [End UseWebDownloadPdf]