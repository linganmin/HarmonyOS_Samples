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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';

/**
 * File migration and conversion management.
 */
export default class FileTransferManager {
  /**
   * Move HarmonyOS 4.0 files to the designated location of HarmonyOS NEXT.
   *
   * @param context context.
   */
  transfer(context: common.Context): void {
    if (this.moveFiles(context)) {
      hilog.info(0x0000, 'BackupRestore FileTransferManager', 'transfer success');
      return;
    }
    hilog.error(0x0000, 'BackupRestore FileTransferManager', 'transfer fail');
  }

  /**
   * Move files from the original backup and recovery path to the directory specified in the application's sandbox path.
   *
   * @param context context.
   * @return success return true, failed return false.
   */
  private moveFiles(context: common.Context): boolean {
    try {
      let cePathPrefix: string = '/data/storage/el2/backup/restore/com.example.backuprestore/ce';
      let sourceFilePath: string = cePathPrefix + '/files/sourceFiles';
      if (!fileIo.accessSync(sourceFilePath)) {
        hilog.error(0x0000, 'BackupRestore FileTransferManager', `moveFiles, ${sourceFilePath} can't access`);
        return false;
      }
      let listFileNames: string[] = fileIo.listFileSync(sourceFilePath);
      if (!listFileNames || listFileNames.length === 0) {
        hilog.error(0x0000, 'BackupRestore FileTransferManager', `moveFiles, ${sourceFilePath} is not file`);
        return false;
      }

      let targetPath: string = context.filesDir + '/targetFiles';
      if (!fileIo.accessSync(targetPath)) {
        fileIo.mkdirSync(targetPath);
      }

      listFileNames.forEach((fileName: string) => {
        let srcPath: string = `${sourceFilePath}/${fileName}`;
        let destPath: string = `${targetPath}/${fileName}`;
        if (fileIo.statSync(srcPath).isFile()) {
          fileIo.moveFileSync(srcPath, destPath);
        } else {
          fileIo.moveDirSync(srcPath, targetPath);
        }
      });
      return true;
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore FileTransferManager', `moveFiles, error: ${JSON.stringify(error)}`);
      return false;
    }
  }
}