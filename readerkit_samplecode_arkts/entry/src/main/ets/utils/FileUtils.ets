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

import { fileIo as fs } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'FileUtils';

export class FileUtils {

  public static isFileExist(filePath: string): boolean {
    try {
      if (!filePath || filePath.length === 0) {
        hilog.error(0x0000, TAG, "isFileExist filePath is blank");
        return false;
      }
      if (fs.accessSync(filePath)) {
        return true;
      }
    } catch (e) {
      hilog.error(0x0000, TAG, 'isFileExist filePath is not exist');
    }
    return false;
  }

  static exist(filePath: string): Promise<boolean> {
    if (!filePath || filePath.length === 0) {
      hilog.error(0x0000, TAG, "exist filePath is blank");
      return Promise.reject();
    }
    return fs.access(filePath);
  }

  public static getExtensionFileName(filePath: string): string {
    if (!filePath || filePath.length === 0) {
      hilog.error(0x0000, TAG, "getExtensionFileName filePath is blank");
      return '';
    }
    let fn = FileUtils.getFileFullName(filePath);
    let fileNameSplit = fn.split(".");
    if (fileNameSplit.length > 1) {
      return fileNameSplit[fileNameSplit.length - 1].toLowerCase();
    } else {
      return "";
    }
  }

  public static getFileName(filePath: string): string {
    if (!filePath || filePath.length === 0) {
      hilog.error(0x0000, TAG, "getFileName filePath is blank");
      return '';
    }
    let fn = FileUtils.getFileFullName(filePath);
    let fileNameSplit = fn.split(".");
    if (fileNameSplit.length > 0) {
      return fileNameSplit[0];
    } else {
      return "";
    }
  }

  public static getFileFullName(filePath: string): string {
    if (!filePath || filePath.length === 0) {
      hilog.error(0x0000, TAG, "getFileFullName filePath is blank");
      return '';
    }
    let reg = /(\/+)/g;
    filePath = filePath.replace(reg, "#");
    let filePathArray = filePath.split("#");
    if (filePathArray.length > 0) {
      return filePathArray[filePathArray.length - 1];
    } else {
      return '';
    }
  }

  public static async makeDirs(dirToMake: string): Promise<boolean> {
    if (dirToMake === null || dirToMake === undefined) {
      hilog.error(0x0000, TAG, `makeDirs dirToMake is null or undefined`);
      return false;
    }
    hilog.info(0x0000, TAG, `makeDirs ${dirToMake}`);

    if (await FileUtils.exist(dirToMake)) {
      hilog.warn(0x0000, TAG, `makeDirs already exists`);
      return true;
    }

    while (dirToMake.endsWith('/')) {
      dirToMake = dirToMake.substring(0, dirToMake.length - 1);
    }

    if (dirToMake.length === 0) {
      hilog.warn(0x0000, TAG, `makeDirs dirToMake is empty`);
      return false;
    }

    // create directory
    let directMakeDirSuccess: boolean = false;
    await fs.mkdir(dirToMake).then(() => {
      hilog.info(0x0000, TAG, `makeDirs ${dirToMake} succeeded`);
      directMakeDirSuccess = true;
    }).catch((e: Error) => {
      hilog.error(0x0000, TAG, `makeDirs failed ${e}. may need to make parent dir`);
    });
    if (directMakeDirSuccess) {
      return true;
    }

    // Try to create a parent directory
    let pos = dirToMake.lastIndexOf('/');
    let parentDir = dirToMake.substring(0, pos);
    let makeParentDirSuccess: boolean = await FileUtils.makeDirs(parentDir);
    if (!makeParentDirSuccess) {
      hilog.error(0x0000, TAG, `makeDirs ${dirToMake} failed to make parent dir`);
      return false;
    }

    let finalResult: boolean = false;
    await fs.mkdir(dirToMake).then(() => {
      hilog.info(0x0000, TAG, `makeDirs ${dirToMake} succeeded`);
      finalResult = true;
    }).catch((e: Error) => {
      hilog.error(0x0000, TAG, `makeDirs ${dirToMake} error ${e}`);
      finalResult = false;
    });
    return finalResult;
  }

  public static async copyFileToCache(srcPath: string, dstPath: string): Promise<void> {
    if (!srcPath || srcPath.length === 0 || !dstPath || dstPath.length === 0) {
      hilog.error(0x0000, TAG, "copyFileToCache srcPath or dstPath is blank");
      return Promise.reject();
    }
    let fileId = -1;
    try {
      let file = fs.openSync(srcPath, fs.OpenMode.READ_ONLY);
      fileId = file.fd;
      await fs.copyFile(fileId, dstPath, 0);
      hilog.info(0x0000, TAG, "copyFileToCache succeeded");
      return Promise.resolve();
    } catch (err) {
      hilog.error(0x0000, TAG, "copyFileToCache failed");
      return Promise.reject();
    } finally {
      fs.close(fileId);
    }
  }
}