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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { assetDownloadManager ,AssetAccelerationExtensionAbility, AssetAccelerationExtensionInfo,
  ContentRequestType } from '@kit.GraphicsAccelerateKit';
import AssetAccelManifest from '../common/AssetAccelManifest';
import { CommonConstants, TAG, DOMAINID } from '../common/CommonConstants';
import { AssetSessionStorage } from '../session/AssetSessionStorage';

export default class AssetAccelExtAbility extends AssetAccelerationExtensionAbility {
  async onDownloadContentRequest(requestType: ContentRequestType, manifestURL: string,
    assetAccelerationExtensionInfo: AssetAccelerationExtensionInfo):
    Promise<assetDownloadManager.AssetDownloadConfig[]> {
    hilog.info(DOMAINID,
      TAG, `onDownloadContentRequest enter, requestType: ${requestType}, manifestURL: ${manifestURL}.`);
    try {
      let remoteManifestInfo: AssetAccelManifest.AssetAccelPackageVersion =
        await AssetAccelManifest.requestRemoteManifest(manifestURL);
      remoteManifestInfo.versionNo = remoteManifestInfo.versionNo + '';
      let storage :AssetSessionStorage = await AssetSessionStorage.create((this.context as common.UIExtensionContext));
      let isExist : boolean = await storage.containGroupData(remoteManifestInfo.versionNo);
      if (!isExist) {
        storage.insertDownloadResourceInfoByGroupID(remoteManifestInfo.versionFiles.versionFile,
          remoteManifestInfo.versionNo);
      }
      const limit = 200;
      let configs: assetDownloadManager.AssetDownloadConfig[] =
        await storage.queryUnSubmitResources(remoteManifestInfo.versionNo, limit);
      storage.updateSubmitStatus(configs);
      return configs;
    } catch (error) {
      hilog.error(DOMAINID,
        TAG, `failed to requestRemoteManifest, errCode: ${error.code}, errMessage: ${error.message}`);
    }
    return [];
  }

  async onBackgroundDownloadSucceeded(downloadTask: assetDownloadManager.AssetDownloadTask,
    filePath: string): Promise<void> {
    hilog.info(DOMAINID,
      TAG, `onBackgroundDownloadSucceeded enter, taskId is ${downloadTask.taskId}, filePath = ${filePath}`);
    try {
      let exist = fs.accessSync(`${filePath}`);
      if (!exist) {
        hilog.info(DOMAINID, TAG, `${filePath} not exist; system error`);
        return;
      }
      const localAssetPath =
        `${(this.context as common.UIExtensionContext).filesDir}/${CommonConstants.ASSET_RESOURCE_DIR_NAME}`;
      if (!fs.accessSync(localAssetPath)) {
        fs.mkdirSync(localAssetPath);
      }
      const groupPath = `${localAssetPath}/${downloadTask.config?.groupId}`;
      if (!fs.accessSync(groupPath)) {
        fs.mkdirSync(groupPath);
      }
      let storage :AssetSessionStorage = await AssetSessionStorage.create(this.context as common.UIExtensionContext);
      await storage.updateSuccessData(downloadTask.config.url);
      fs.renameSync(`${filePath}`, `${groupPath}/${downloadTask.config?.fileName}`);
      hilog.info(DOMAINID, TAG, `${filePath} rename to ${groupPath}/${downloadTask.config?.fileName}`);
    } catch (error) {
      hilog.error(DOMAINID,
        TAG, `failed to transferring resources, errCode: ${error.code}, errMessage: ${error.message}`);
    }
    return;
  }

  async onBackgroundDownloadFailed(downloadTask: assetDownloadManager.AssetDownloadTask,
    fault: assetDownloadManager.DownloadFault): Promise<void> {
    // If the `baDownload` fails to download, the extension is notified about it.
    // You can log error info, but do not use 'startForegroundDownload' API to resubmit the task
    hilog.info(DOMAINID,
      TAG, `onBackgroundDownloadFailed enter, download url: ${downloadTask.config.url}, err: ${fault}`);
    let storage :AssetSessionStorage = await AssetSessionStorage.create(this.context as common.UIExtensionContext);
    await storage.updateFailedData(downloadTask.config.url);
  }

  async onExtensionWillTerminate(error?: BusinessError): Promise<void> {
    if (!error) {
      hilog.info(DOMAINID, TAG, `onExtensionWillTerminate enter, BusinessError is null`);
      return;
    }
    hilog.error(DOMAINID, TAG, `onExtensionWillTerminate enter, BusinessError：${error?.code}, msg: ${error?.message}`);
  }
};

