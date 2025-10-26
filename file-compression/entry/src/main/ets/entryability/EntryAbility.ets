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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo } from '@kit.CoreFileKit';
import { window } from '@kit.ArkUI';
import { FileConstants } from '../constant/FileConstants';
import { FileItem } from '../model/FileItem';
import Logger from '../utils/Logger';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    fileIo.rmdirSync(this.context.filesDir);
    fileIo.mkdir(this.context.filesDir + FileConstants.DECOMPRESSED_FILE_DIRECTORY, true);
    let filePath: string = this.context.filesDir + '/' + FileConstants.PRESET_FILE_NAME + FileConstants.TXT_FILE_TYPE;
    let file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    let writeLen: number = fileIo.writeSync(file.fd, FileConstants.PRESET_FILE_CONTENT);

    fileIo.readText(filePath).then((str: string) => {
      let fileList: FileItem[] = [];
      fileList.push(new FileItem(FileConstants.PRESET_FILE_NAME, FileConstants.TXT_FILE_TYPE, writeLen, str, filePath));
      AppStorage.setOrCreate('fileList', fileList);
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to read file text, error code: ${err.code}, error message: ${err.message}`);
    }).finally(() => {
      fileIo.closeSync(file);
    });

    windowStage.loadContent('pages/Index', (err) => {
      AppStorage.setOrCreate('UIContext', windowStage.getMainWindowSync().getUIContext());
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}