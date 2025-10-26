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

import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { FileConstants } from '../constant/FileConstants';
import { FileItem } from '../model/FileItem';
import Logger from './Logger';

export class FileUtil {
  copyRawfile(rawfileName: string, rawfileType: string, context: UIContext): void {
    context.getHostContext()?.resourceManager.getRawFileContent(rawfileName + rawfileType,
      (err: BusinessError, value: Uint8Array) => {
        if (err) {
          Logger.error(`Failed to get rawfile content, error code: ${err.code}, error message: ${err.message}`);
          return;
        }
        let rawfileContentBuffer: ArrayBufferLike = value.buffer;
        let outFilePath: string = context.getHostContext()?.filesDir + '/' + rawfileName + rawfileType;
        let file = fileIo.openSync(outFilePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        fileIo.writeSync(file.fd, rawfileContentBuffer);
        this.addToFileList(outFilePath, rawfileName, FileConstants.TXT_FILE_TYPE);
      })
  }

  addToFileList(outFile: string, fileName: string, fileType: string) {
    let fileList: FileItem[] | undefined = AppStorage.get('fileList');
    fileIo.stat(outFile).then((stat: fileIo.Stat) => {
      let fileContent: string = '';
      if (fileType === FileConstants.TXT_FILE_TYPE) {
        fileContent = fileIo.readTextSync(outFile);
      }
      let tempFile: FileItem = new FileItem(fileName, fileType, stat.size, fileContent, outFile);
      fileList?.push(tempFile);
      AppStorage.set('fileList', fileList);
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to add the file, error code: ${err.code}, error message: ${err.message}`);
    });
  }

  deleteOriginalFile(filePath: string): void {
    let fileList: FileItem[] | undefined = AppStorage.get('fileList');
    if (fileList === undefined) {
      return;
    }
    // If the file already exists before decompression, overwrite it.
    fileIo.unlinkSync(filePath);
    for (let i = 0; i < fileList.length; i++) {
      if (fileList[i].getFilePath() === filePath) {
        fileList.splice(i, 1);
      }
    }
    AppStorage.set('fileList', fileList);
  }


  async isCompressedFileExisted(filePath: string): Promise<boolean> {
    let isExist = await fileIo.access(filePath);
    if (isExist) {
      return true;
    }
    return false;
  }

  formatFileSize(fileSize: number): string {
    let circleCount: number = 0;
    while (fileSize / FileConstants.BYTE_CONVERSION > 1) {
      fileSize /= FileConstants.BYTE_CONVERSION;
      circleCount += 1;
      if (circleCount === 2) {
        break;
      }
    }
    let sizeUnit: string = FileConstants.SIZE_UNITS[0];
    switch (circleCount) {
      case 1:
        sizeUnit = FileConstants.SIZE_UNITS[1];
        break;
      case 2:
        sizeUnit = FileConstants.SIZE_UNITS[2];
        break;
      default:
        break;
    }
    return Number.isInteger(fileSize) ? (fileSize + ' ' + sizeUnit) : (fileSize.toFixed(1) + ' ' + sizeUnit);
  }
}