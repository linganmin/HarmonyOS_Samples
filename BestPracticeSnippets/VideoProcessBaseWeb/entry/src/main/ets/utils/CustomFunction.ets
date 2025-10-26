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

import { common, Want } from '@kit.AbilityKit';
import { pasteboard } from '@kit.BasicServicesKit';
import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../common/Constants';
import { WebDownloadManager } from './WebDownloadManager';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context1 = uiContext!.getPromptAction()

//src/main/ets/utils/CustomFunction.ets
// [Start link1]
/**
 * Copies a URI to the system clipboard.
 *
 * @param uri - The URI to be copied to the clipboard. This should be a valid string representing a URI.
 * @returns void - This function does not return any value.
 */
export function copyLink(uri: string) {
  const pasteData = pasteboard.createData('text/plain', uri);
  pasteboard.getSystemPasteboard().setData(pasteData, (err) => {
    if (err) {
      hilog.error(0x000, Constants.TAG, JSON.stringify(err));
      return;
    }
    context1.showToast({
      message: $r('app.string.copy_success')
    })
  })
}
// [End link1]

export function openVideoInBrowser(uri: string, context: common.UIAbilityContext) {
  let want: Want = {
    action: 'ohos.want.action.viewData',
    entities: ['entity.system.browsable'],
    uri
  };
  context.startAbility(want);
}
export async function saveVideoToGallery(
  uri: string,
  context: common.UIAbilityContext,
  openDownloadDialog: Function,
  closeDownloadDialog: Function) {
  const webDownloadManager = WebDownloadManager.getInstance();
  let documentSaveOptions = new picker.DocumentSaveOptions();
  documentSaveOptions.newFileNames = ['video.mp4'];
  let documentPicker = new picker.DocumentViewPicker(context);
  documentPicker.save(documentSaveOptions).then(async (uris: Array<string>) => {
    try {
      if (uris.length === 0) {
        context1.showToast({ message: $r('app.string.user_cancelled_authorization') })
        return;
      }
      openDownloadDialog(); // open dialog
      const path = await webDownloadManager.start(Constants.INDEX_WEB_CONTROLLER, context.filesDir, uri);
      closeDownloadDialog(); // close dialog
      webDownloadManager.clearProgress();
      context1.showToast({ message: $r('app.string.download_success') })
      const targetFile = fs.openSync(uris[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      const sourceFile = fs.openSync(path, fs.OpenMode.READ_ONLY);
      let buf = new ArrayBuffer(1024);
      while (true) {
        const len = fs.readSync(sourceFile.fd, buf);
        if (0 === len) {
          break;
        }
        fs.writeSync(targetFile.fd, buf);
      }
      fs.closeSync(sourceFile);
      fs.closeSync(targetFile);
    } catch (error) {
      hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
        error.code, error.message);
    }
  }).finally(() => {
    webDownloadManager.deleteFile();
  })
}