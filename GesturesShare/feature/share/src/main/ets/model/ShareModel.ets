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

// [Start importShare]
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor } from '@kit.ArkData';
import { fileUri } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FileData, ShareType, VIDEO_SOURCES } from './FileData';
// [Start importShare]

export class ShareModel {
  private static controller: ShareModel;
  private context: common.UIAbilityContext | undefined = undefined;
  // The index of shared files.
  private fileShare: number[] = [];
  // All file data.
  private videoDataList: FileData[] = [];
  // Video playback index.
  private videoIndex: number = 0;

  /**
   * Initialize a shareModel instance.
   *
   * @param context common.UIAbilityContext.
   * @returns ShareModel.
   */
  public static getInstance(context: common.UIAbilityContext): ShareModel {
    if (!ShareModel.controller) {
      ShareModel.controller = new ShareModel(context);
    }
    return ShareModel.controller;
  }

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  // [Start ShareListening]
  /**
   *  Add gesturesShare listening.
   */
  public immersiveListening(shareType: ShareType) {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      window.getLastWindow(this.context).then((data) => {
        try {
          let mainWindowID: number = data.getWindowProperties().id;
          harmonyShare.on('gesturesShare', { windowId: mainWindowID }, (target: harmonyShare.SharableTarget) => {
            this.immersiveCallback(target, shareType);
          });
        } catch (err) {
          let error = err as BusinessError;
          hilog.error(0x0000, 'GesturesShare', `getWindowProperties error ${error.code} ${error.message}`);
        }
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'GesturesShare', `immersiveListening error ${error.code} ${error.message}`);
      })
    }
  }

  /**
   *  Remove gesturesShare listening.
   */
  public immersiveDisableListening() {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      window.getLastWindow(this.context).then((data) => {
        try {
          let mainWindowID: number = data.getWindowProperties().id;
          harmonyShare.off('gesturesShare', { windowId: mainWindowID });
        } catch (error) {
          let err = error as BusinessError;
          hilog.error(0x0000, 'GesturesShare', `getWindowProperties error ${err.code} ${err.message}`);
        }
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'GesturesShare', `immersiveDisableListening error ${error.code} ${error.message}`);
      })
    }
  }
  // [End ShareListening]

  /**
   * GesturesShare listening callback.
   *
   * @param target After the Huawei Share event is triggered,
   * you can call back the parameters and share them across devices.
   */
  // [Start ShareCallback]
  public immersiveCallback(target: harmonyShare.SharableTarget, shareType: ShareType) {
    if (shareType === ShareType.FILE_SHARE) {
      if (!this.fileShare || this.fileShare.length === 0) {
        return;
      }
      let shareData: systemShare.SharedData = this.getFileShareData();
      target.share(shareData);
    } else {
      let shareData: systemShare.SharedData = this.getLinkShareData();
      target.share(shareData);
    }
  }
  // [End ShareCallback]

  // [Start FileShareData]
  /**
   * Get file Share data.
   * @returns systemShare.SharedData.
   */
  private getFileShareData(): systemShare.SharedData {
    let shareData: systemShare.SharedData =
      new systemShare.SharedData(this.getShareRecord(this.videoDataList[this.fileShare[0]]));
    try {
      for (let i = 1; i < this.fileShare.length; i++) {
        shareData.addRecord(this.getShareRecord(this.videoDataList[this.fileShare[i]]));
      }
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'GesturesShare', `shareData.addRecord error ${error.code} ${error.message}`);
    }
    return shareData;
  }

  /**
   * Get shared data.
   *
   * @param data File data to be shared.
   * @returns systemShare.SharedRecord.
   */
  private getShareRecord(data: FileData): systemShare.SharedRecord {
    let suffix = '.' + data.url.split('.').pop();
    // Obtain the UTD through the file extension.
    let utd = uniformTypeDescriptor.getUniformDataTypeByFilenameExtension(suffix);
    hilog.info(0x0000, 'GesturesShare', `getShareRecord utd ${utd}`);
    return {
      utd: utd,
      uri: data.url,
      thumbnailUri: data.thumbnail,
      title: data.name,
      description: data.description
    };
  }
  // [End FileShareData]

  /**
   * Get link share data.
   * @returns systemShare.SharedData.
   */
  // [Start LinkShareData]
  getLinkShareData(): systemShare.SharedData {
    // share app linking.
    let videoData: FileData = VIDEO_SOURCES[this.videoIndex];
    // Video thumbnail image sandbox path.
    let filePath: string = this.context?.filesDir + `/${videoData.thumbnail}`;
    // Get video thumbnail URI path.
    let coverUri: string = fileUri.getUriFromPath(filePath);
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      // Set the shared data type to Link.
      utd: uniformTypeDescriptor.UniformDataType.HYPERLINK,
      // The shared App Linking link is replaced with the real address here.
      content: `https://www.example.com?videoIndex=${this.videoIndex}`,
      thumbnailUri: coverUri,
      title: videoData.name,
      description: videoData.description
    });
    return shareData;
  }
  // [End LinkShareData]

  public getFileShare(): number[] {
    return this.fileShare;
  }

  public setFileShare(value: number[]) {
    this.fileShare = value;
  }

  public getVideoDataList(): FileData[] {
    return this.videoDataList;
  }

  public setVideoDataList(value: FileData[]) {
    this.videoDataList = value;
  }

  public getVideoIndex(): number {
    return this.videoIndex;
  }

  public setVideoIndex(value: number) {
    this.videoIndex = value;
  }
}
