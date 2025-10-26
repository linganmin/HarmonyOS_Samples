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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { CommonConstants } from '../common/CommonConstants';
import Logger from '../utils/Logger';
import { DataUtils } from '../utils/DataUtils';
import { ContentInfo, ImageInfo } from '../model/ContentInfo';
import { commonType, distributedDataObject } from '@kit.ArkData';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { FileUtils } from '../utils/FileUtils';

export default class EntryAbility extends UIAbility {
  private readonly tag: string = 'EntryAbility';
  private distributedObject: distributedDataObject.DataObject | undefined = undefined;

  // [Start oncreate]
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    DataUtils.context = this.context;
    // set circulation status INACTIVE
    this.context.setMissionContinueState(AbilityConstant.ContinueState.INACTIVE, (result) => {
      Logger.info(`restoreDistributedObject setMissionContinueState code: ${result.code}`);
    });
    this.restoreDistributedObject(want, launchParam);
    Logger.info(this.tag, '%{public}s', 'Ability onCreate');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.restoreDistributedObject(want, launchParam);
  }

  private restoreDistributedObject(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    if (launchParam.launchReason !== AbilityConstant.LaunchReason.CONTINUATION) {
      return;
    }
    // File copying takes a long time, resulting in the page lifecycle aboutToAppear being executed first.
    let imageInfoArr: ImageInfo[] = [];
    AppStorage.setOrCreate(CommonConstants.KEY_IMAGE_INFO, imageInfoArr);
    let contentInfo: ContentInfo = new ContentInfo(undefined, undefined, undefined, undefined);
    this.distributedObject = distributedDataObject.create(this.context, contentInfo);
    // Add a data restored listener.
    this.distributedObject.on('status',
      (sessionId: string, networkId: string, status: 'online' | 'offline' | 'restored') => {
        if (status === 'restored') {
          if (!this.distributedObject) {
            return;
          }
          AppStorage.setOrCreate(CommonConstants.KEY_TITLE, this.distributedObject['title']);
          AppStorage.setOrCreate(CommonConstants.KEY_DESCRIPTION, this.distributedObject['description']);
          let attachments = this.distributedObject['attachments'] as commonType.Assets;
          if (attachments) {
            for (const attachment of attachments) {
              let sourceUri: string = fileUri.getUriFromPath(`${this.context.distributedFilesDir}/${attachment.name}`);
              let destination: string = this.context.filesDir;
              FileUtils.copyFileToDestination(sourceUri, destination);
              let uri: string = `${this.context.filesDir}/${attachment.name}`;
              let imageInfo = FileUtils.createPixelMap(uri);
              if (imageInfo) {
                imageInfoArr.push(imageInfo);
              }
            }
          }
          AppStorage.set(CommonConstants.KEY_IMAGE_INFO, imageInfoArr);
          AppStorage.setOrCreate(CommonConstants.KEY_RESTORE_IMAGE_INFO, imageInfoArr);
        }
      });
    let sessionId: string = want.parameters?.distributedSessionId as string;
    this.distributedObject.setSessionId(sessionId);
    this.context.restoreWindowStage(new LocalStorage());
  }

  // [End oncreate]

  // Migrating data to other devices
  // [Start on_continue]
  async onContinue(wantParam: Record<string, Object | undefined>): Promise<AbilityConstant.OnContinueResult> {
    try {
      // get distribute id
      let sessionId: string = distributedDataObject.genSessionId();
      wantParam.distributedSessionId = sessionId;
      // set images assets info
      let imageInfoArray = AppStorage.get<Array<ImageInfo>>(CommonConstants.KEY_IMAGE_INFO);
      let assets: commonType.Assets = [];
      if (imageInfoArray) {
        for (let i = 0; i < imageInfoArray.length; i++) {
          let append = imageInfoArray[i];
          let attachment: commonType.Asset = this.getAssetInfo(append);
          assets.push(attachment);
        }
      }
      // set distribute data object
      let contentInfo: ContentInfo = new ContentInfo(
        AppStorage.get(CommonConstants.KEY_TITLE),
        AppStorage.get(CommonConstants.KEY_DESCRIPTION),
        AppStorage.get(CommonConstants.KEY_IMAGE_INFO),
        assets
      );
      let source = contentInfo.flatAssets();
      // save data to distribute
      this.distributedObject = distributedDataObject.create(this.context, source);
      Logger.info(this.tag, `onContinue source: ${JSON.stringify(source)}`);
      this.distributedObject.setSessionId(sessionId);
      await this.distributedObject.save(wantParam.targetDevice as string).catch((err: BusinessError) => {
        Logger.error(this.tag, `Failed to save. Code: ${err.code}, message: ${err.message}`);
      });
    } catch (error) {
      Logger.error(this.tag, 'distributedDataObject failed', `code ${(error as BusinessError).code}`);
    }
    return AbilityConstant.OnContinueResult.AGREE;
  }

  private getAssetInfo(append: ImageInfo): commonType.Asset {
    let filePath = this.context.distributedFilesDir + '/' + append.imageName;
    fs.statSync(filePath);
    let uri: string = fileUri.getUriFromPath(filePath);
    let stat = fs.statSync(filePath);
    let attachment: commonType.Asset = {
      name: append.imageName,
      uri: uri,
      path: filePath,
      createTime: stat.ctime.toString(),
      modifyTime: stat.ctime.toString(),
      size: stat.size.toString()
    };
    Logger.info(this.tag, `getAssetInfo attachment = ${JSON.stringify(attachment)}`);
    return attachment;
  }

  // [End on_continue]

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(this.tag, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.info(this.tag, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(this.tag, 'Succeeded in loading the content.');
      windowStage.getMainWindowSync().setWindowBackgroundColor(CommonConstants.GRAY_COLOR);
      windowStage.getMainWindowSync().setWindowLayoutFullScreen(true);
    });
  }

  // [Start on_restore]
  onWindowStageRestore(windowStage: window.WindowStage) {
    windowStage.loadContent('pages/GraphicCreationPage', (err, data) => {
      // [StartExclude on_restore]
      if (err.code) {
        Logger.error(this.tag, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(this.tag, 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
      // [EndExclude on_restore]
    });
  }

  // [End on_restore]

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(this.tag, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(this.tag, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(this.tag, '%{public}s', 'Ability onBackground');
  }
}
