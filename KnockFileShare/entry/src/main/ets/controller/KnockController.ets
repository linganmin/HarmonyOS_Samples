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

import { harmonyShare, systemShare } from '@kit.ShareKit';
import { fileUri } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { uniformTypeDescriptor } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FileUtil } from '../utils/FileUtil';
import { FileData } from '../model/FileData';

export class KnockController {
  private static controller: KnockController;
  private context: common.UIAbilityContext | undefined = undefined;

  /**
   * Initialize a KnockController instance.
   *
   * @param context common.UIAbilityContext.
   * @returns KnockController.
   */
  public static getInstance(context: common.UIAbilityContext): KnockController {
    if (!KnockController.controller) {
      KnockController.controller = new KnockController(context);
    }
    return KnockController.controller;
  }

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  // [Start FileShare]
  /**
   * Knock listening callback.
   *
   * @param target After the Huawei Share event is triggered,
   * you can call back the parameters and share them across devices.
   */
  public immersiveCallback(target: harmonyShare.SharableTarget) {
    let fileShare = AppStorage.get('KnockFileShare_fileShare') as number[];
    let videoDataList = AppStorage.get('KnockFileShare_videoDataList') as FileData[];
    if (!fileShare || fileShare.length === 0) {
      return;
    }
    let shareData: systemShare.SharedData = new systemShare.SharedData(this.getShareRecord(videoDataList[fileShare[0]]));
    for (let i = 1; i < fileShare.length; i++) {
      try {
        shareData.addRecord(this.getShareRecord(videoDataList[fileShare[i]]));
      } catch (e) {
        hilog.error(0x0000, 'KnockFileShare', `addRecord failed ${JSON.stringify(e)}`);
      }
    }
    target.share(shareData);
  }

  /**
   * Get shared data.
   *
   * @param data File data to be shared.
   * @returns systemShare.SharedRecord.
   */
  getShareRecord(data: FileData): systemShare.SharedRecord {
    let suffix = '.' + data.url.split('.').pop();
    // Obtain the UTD through the file extension.
    let utd = uniformTypeDescriptor.getUniformDataTypeByFilenameExtension(suffix);
    hilog.info(0x0000, 'KnockFileShare', `getShareRecord utd ${utd}`)
    return {
      utd: utd,
      uri: data.url,
      thumbnailUri: data.thumbnail,
      title: data.name,
      description: data.description
    };
  }
  // [End FileShare]

  // [Start FileShareListening]
  /**
   *  Add knock listening.
   */
  public immersiveListening() {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      harmonyShare.on('knockShare', (target: harmonyShare.SharableTarget) => {
        this.immersiveCallback(target);
      });
    }
  }

  /**
   *  Add knock listening in 2in1 device type.
   */
  public immersiveListeningPC() {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      window.getLastWindow(this.context).then((data) => {
        let mainWindowID: number = data.getWindowProperties().id;
        harmonyShare.on('knockShare', { windowId: mainWindowID }, (target: harmonyShare.SharableTarget) => {
          this.immersiveCallback(target);
        });
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'KnockFileShare', `getLastWindow failed ${JSON.stringify(error)}`);
      });
    }
  }

  /**
   *  remove knock listening.
   */
  public immersiveDisableListening() {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      harmonyShare.off('knockShare');
    }
  }

  /**
   *  remove knock listening.
   */
  public immersiveDisableListeningPC() {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      window.getLastWindow(this.context).then((data) => {
        let mainWindowID: number = data.getWindowProperties().id;
        harmonyShare.off('knockShare', { windowId: mainWindowID });
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'KnockFileShare', `getLastWindow failed ${JSON.stringify(error)}`);
      });
    }
  }
  // [End FileShareListening]

  // [Start dataReceive]
  /**
   * Add dataReceive listening in 2in1 device type.
   */
  public dataReceiveListeningPC() {
    if (!canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      return;
    }
    window.getLastWindow(this.context).then(((data) => {
      let mainWindowID: number = data.getWindowProperties().id;
      harmonyShare.on('dataReceive', { windowId: mainWindowID, capabilities: [
        {
          'utd': uniformTypeDescriptor.UniformDataType.MEDIA,
          'maxSupportedCount': 5
        },
        {
          'utd': uniformTypeDescriptor.UniformDataType.FILE,
          'maxSupportedCount': 5
        }
      ] },
        (receiveTarget: harmonyShare.ReceivableTarget) => {
          if (!this.context) {
            return;
          }
          // Process the received file data.
          receiveTarget.receive(fileUri.getUriFromPath(this.context.filesDir), {
            onDataReceived: (shareData: systemShare.SharedData) => {
              let shareRecords = shareData.getRecords();
              let videoDataList = AppStorage.get('KnockFileShare_videoDataList') as FileData[];
              shareRecords.forEach(async (record: systemShare.SharedRecord) => {
                if (!record.uri) {
                  return;
                }
                // Get video thumbnails.
                let fileName = record.uri.split('/').pop()?.split('.')[0];
                let thumbPath: string = videoDataList[0].thumbnail;
                if (record.uri.endsWith('mp4') || record.uri.endsWith('mkv')) {
                  thumbPath = record.uri.slice(0, record.uri.lastIndexOf('.')) + 'thumb.png';
                  let result = await new FileUtil().getVideoThumbnail(record.uri, thumbPath);
                  if (!result) {
                    thumbPath = videoDataList[0].thumbnail;
                  }
                } else if (record.uri.endsWith('png') || record.uri.endsWith('jpg') || record.uri.endsWith('jpeg')) {
                  thumbPath = record.uri;
                } else {
                  thumbPath = videoDataList[0].thumbnail;
                }

                videoDataList.push({
                  url: record.uri,
                  name: fileName,
                  description: record.description,
                  thumbnail: thumbPath,
                  index: videoDataList.length
                });
              });
            },
            onResult(resultCode: harmonyShare.ShareResultCode) {
              if (resultCode === harmonyShare.ShareResultCode.SHARE_SUCCESS) {
                hilog.info(0x0000, 'KnockFileShare', 'receive file success');
              } else {
                hilog.error(0x0000, 'KnockFileShare', 'receive failed ' + resultCode);
              }
            }
          });
        });
    })).catch((error: BusinessError) => {
      hilog.error(0x0000, 'KnockFileShare', `failed to obtain the window. cause ${error.code} ${error.message}`);
    });
  }
  // [End dataReceive]

  /**
   *  Remove dataReceive listening.
   */
  public dataReceiveDisableListeningPC() {
    if (!canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      return;
    }
    window.getLastWindow(this.context).then(((data) => {
      let mainWindowID: number = data.getWindowProperties().id;
      harmonyShare.off('dataReceive', { windowId: mainWindowID, capabilities: [
        {
          'utd': uniformTypeDescriptor.UniformDataType.MEDIA,
          'maxSupportedCount': 5
        },
        {
          'utd': uniformTypeDescriptor.UniformDataType.FILE,
          'maxSupportedCount': 5
        }
      ] });
    })).catch((error: BusinessError) => {
      hilog.error(0x0000, 'KnockFileShare', `failed to obtain the window. cause ${error.code} ${error.message}`);
    });
  }
}
