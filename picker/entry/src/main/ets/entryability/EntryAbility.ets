/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { UIAbility, AbilityConstant, Want, abilityAccessCtrl, Permissions } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import MediaFileUri from '../media/MediaFileUri';
import Logger from '../common/Logger';

const TAG = 'EntryAbility: ';

export default class EntryAbility extends UIAbility {
  private mediaFileUri: MediaFileUri = new MediaFileUri();
  private windowStage: window.WindowStage | null = null;
  private loadFlag: Boolean = false;
  private loadFileSize: number = 0;
  private loadFileName: string = '';
  private loadFileContent: string = '';
  private loadUri: string | undefined = '';
  private storage: LocalStorage = new LocalStorage();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
    this.getPermission(want);
  }

  getWantInfo(want: Want): void {
    if (want === null || want === undefined) {
      Logger.info(TAG, 'getWantInfo want is null');
      return;
    }

    let srcUri = want.uri;
    if (srcUri === null || srcUri === undefined) {
      Logger.info(TAG, 'getWantInfo srcUri is null');
      return;
    }

    let parameters = want.parameters;
    if (parameters === null || parameters === undefined) {
      Logger.info(TAG, 'getWantInfo parameters is null');
      return;
    }

    let keyFd = want.parameters?.keyFd;
    if (keyFd === null || keyFd === undefined) {
      Logger.info(TAG, 'getWantInfo keyFd is null');
      return;
    }

    this.loadFlag = true;
    this.loadUri = want.uri;

    this.storage.setOrCreate('loadFlag', this.loadFlag);
    this.storage.setOrCreate('loadUri', this.loadUri);
    this.storage.setOrCreate('loadFileName', this.loadFileName);
    this.storage.setOrCreate('loadFileSize', this.loadFileSize);
    this.storage.setOrCreate('loadFileContent', this.loadFileContent);

    Logger.info(TAG, 'getWantInfo Ability loadFlag: ' + this.loadFlag);
    Logger.info(TAG, 'getWantInfo Ability loadUri: ' + want.uri);
    Logger.info(TAG, 'getWantInfo Ability loadFileName: ' + this.loadFileName);
    Logger.info(TAG, 'getWantInfo Ability loadFileSize: ' + this.loadFileSize);
    Logger.info(TAG, 'getWantInfo Ability loadFileContent: ' + this.loadFileContent);

    this.loadEditFilePage();
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onNewWant');
    this.getWantInfo(want);
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    this.windowStage = windowStage;

    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content. Data: ' + JSON.stringify(data) ?? '');

      let uiContext:  UIContext | undefined = windowStage.getMainWindowSync().getUIContext()
      AppStorage.setOrCreate('uiContext', uiContext);
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
  }

  loadEditFilePage(): void {
    this.windowStage?.loadContent('pages/EditFile', this.storage, (err, data) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content. Data: ' + JSON.stringify(data) ?? '');
    });
  }

  getPermission(want: Want): void {
    let array: Array<Permissions> = ['ohos.permission.MEDIA_LOCATION'];
    let context = this.context;
    let atManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser will determine whether to trigger a pop-up window based on the authorization status of the permission.
    atManager.requestPermissionsFromUser(context, array).then((data) => {
      Logger.info(TAG, 'data type:' + typeof (data));
      Logger.info(TAG, 'data:' + data);
      Logger.info(TAG, 'data permissions:' + data.permissions);
      Logger.info(TAG, 'data result:' + data.authResults);

      this.mediaFileUri.getAllFiles();
      Logger.info(TAG, 'getPermission getWantInfo');
      this.getWantInfo(want);
    }).catch((err: BusinessError) => {
      Logger.error(TAG, 'Failed to start ability' + err.code);
    });
  }
}