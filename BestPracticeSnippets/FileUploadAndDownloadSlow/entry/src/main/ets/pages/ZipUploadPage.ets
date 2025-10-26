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

// [Start import_zlib]
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError, zlib } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// [End import_zlib]

// [Start zip_upload]
class ZipUpload {
  // Uri stored before creating the task
  private waitList: Array<string> = [];
  // Files that need to be uploaded uri
  private fileUris: Array<string> = [];
  // ...
}
// [End zip_upload]

@Entry
@Component
struct ZipUploadPage {
  private context: common.UIAbilityContext | undefined = undefined;
  private waitList: Array<string> = [];
  private filePath: string = '';

  // [Start zip_upload_page]
  // Data compression processing
  async zipUploadFiles(fileUris: Array<string>): Promise<void> {
    try {
      this.context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      let cacheDir = this.context.cacheDir;
      let tempDir = fileIo.mkdtempSync(`${cacheDir}/XXXXXX`);
      // Put the uri obtained from the library picture into fileUris and copy it to the temporary folder.
      for (let i = 0; i < fileUris.length; i++) {
        let fileName = fileUris[i].split('/').pop();
        let resourceFile: fileIo.File = fileIo.openSync(fileUris[i], fileIo.OpenMode.READ_ONLY);
        fileIo.copyFileSync(resourceFile.fd, `${tempDir}/${fileName}`, 0);
        fileIo.closeSync(resourceFile);
      }
      // File compression, package the previously generated temporary folder into test.zip
      let options: zlib.Options = {
        level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION,
        memLevel: zlib.MemLevel.MEM_LEVEL_DEFAULT,
        strategy: zlib.CompressStrategy.COMPRESS_STRATEGY_DEFAULT_STRATEGY
      };
      let data = await zlib.compressFile(tempDir, `${cacheDir}/test.zip`, options);
      // Delete temporary folders
      fileIo.rmdirSync(tempDir);
      // Put the generated zip package into the transmission queue.
      this.waitList.push(`${cacheDir}/test.zip`);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'FileUploadAndDownloadSlow', `zipUploadFiles error ${error.code} ${error.message}`);
    }
  }
  // [End zip_upload_page]

  async createSandboxFile() {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const dirPath = context.filesDir + '/myFiles';
    this.filePath = dirPath + '/data.txt';

    try {
      await fileIo.access(dirPath);
    } catch {
      await fileIo.mkdir(dirPath);
    }
    try {
      const file = await fileIo.open(this.filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      await fileIo.write(file.fd, 'Sandbox file content');
      await fileIo.close(file.fd);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'FileUploadAndDownloadSlow', `zipUploadFiles error ${error.code} ${error.message}`);
    }
  }

  aboutToAppear(): void {
    this.createSandboxFile();
  }

  build() {
    Column() {
      Button('Click me')
        .width('100%')
        .onClick(async () => {
          if (this.filePath !== '') {
            await this.zipUploadFiles([this.filePath]);
          }
          hilog.info(0x0000, 'FileUploadAndDownloadSlow', `${JSON.stringify(this.waitList)}`)
        })
    }
    .justifyContent(FlexAlign.End)
    .width('100%')
    .height('100%')
    .padding({
      left: 16,
      right: 16
    })
  }
}