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

// [Start knock_controller_create]
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { fileUri } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { uniformTypeDescriptor } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
// [StartExclude knock_controller_create]
import { VIDEO_SOURCES, VideoData } from '../model/VideoData';
import { Logger } from '../utils/Logger';
import { window } from '@kit.ArkUI';

const TAG = 'KnockController';
// [EndExclude knock_controller_create]
export class KnockController {
  private static controller: KnockController;
  private context: common.UIAbilityContext | undefined = undefined;
  // Knock listening status
  private isKnockListening: boolean = false;

  public static getInstance(context: common.UIAbilityContext): KnockController {
    if (!KnockController.controller) {
      KnockController.controller = new KnockController(context);
    }
    return KnockController.controller;
  }

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  // [Start share_linking]
  /**
   * knock listening callback
   * @param target After the Huawei Share event is triggered,
   * you can call back the parameters and share them across devices.
   */
  public immersiveCallback(target: harmonyShare.SharableTarget) {
    // [StartExclude knock_controller_create]
    // share app linking
    try {
      let videoIndex: number = AppStorage.get('videoIndex') as number;
      let videoData: VideoData = VIDEO_SOURCES[videoIndex];
      // Video thumbnail image sandbox path
      let filePath: string = this.context?.filesDir + `/${videoData.head}`;
      // Get video thumbnail URI path
      let coverUri: string = fileUri.getUriFromPath(filePath);
      let shareData: systemShare.SharedData = new systemShare.SharedData({
        // Set the shared data type to Link
        utd: uniformTypeDescriptor.UniformDataType.HYPERLINK,
        // The shared App Linking link is replaced with the real address here
        content: `https://www.example.com?videoIndex=${videoIndex}`,
        thumbnailUri: coverUri,
        title: videoData.name,
        description: videoData.description
      });
      // Initiate a share
      target.share(shareData).then(() => {
        Logger.info(TAG, 'Share link success');
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `Share link  error. code: ${error.code}, message: ${error.message}`);
      });
    } catch (err) {
      Logger.error(TAG, `Share link exception. code: ${err.code}, message: ${err.message}`);
    }
    // [EndExclude knock_controller_create]
  }
  // [End share_linking]

  /**
   *  Add knock listening
   */
  public immersiveListening() {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare') && !this.isKnockListening) {
      harmonyShare.on('knockShare', (target: harmonyShare.SharableTarget) => {
        this.immersiveCallback(target);
      });
      this.isKnockListening = true;
    }
  }

  /**
   *  remove knock listening
   */
  public immersiveDisableListening() {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare') && this.isKnockListening) {
      harmonyShare.off('knockShare');
      this.isKnockListening = false;
    }
  }

  /**
   *  Add knock listening in 2in1 device type.
   */
  public immersiveListeningPC() {
    try {
      if (canIUse('SystemCapability.Collaboration.HarmonyShare') && !this.isKnockListening) {
        window.getLastWindow(this.context).then((data) => {
          let mainWindowID: number = data.getWindowProperties().id;
          harmonyShare.on('knockShare', { windowId: mainWindowID }, (target: harmonyShare.SharableTarget) => {
            this.immersiveCallback(target);
          });
        })

        this.isKnockListening = true;
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getWindowProperties err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }

  /**
   *  Remove knock listening in 2in1 device type.
   */
  public immersiveDisableListeningPC() {
    try {
      if (canIUse('SystemCapability.Collaboration.HarmonyShare') && this.isKnockListening) {
        window.getLastWindow(this.context).then((data) => {
          let mainWindowID: number = data.getWindowProperties().id;
          harmonyShare.off('knockShare', { windowId: mainWindowID });
        })

        this.isKnockListening = false;
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getWindowProperties err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }
}
// [End knock_controller_create]