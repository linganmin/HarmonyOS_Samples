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

import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { sim } from '@kit.TelephonyKit';
import { util } from '@kit.ArkTS';
import { Logger } from './Logger';

const TAG = 'MediaTools';

export class MediaTools {
  static async getPixelMapFromResource(context: common.UIAbilityContext,
    name: resourceManager.Resource): Promise<PixelMap> {
    let resourceMgr = context.resourceManager;
    let fileData: Uint8Array = await resourceMgr.getMediaContent(name);
    return await image.createImageSource(fileData.buffer as ArrayBuffer).createPixelMap();
  }

  public static hasSim(): boolean {
    let firstSim = sim.hasSimCardSync(0);
    let secondSim = sim.hasSimCardSync(1);
    if (firstSim || secondSim) {
      return true;
    }
    return false;
  }

  static async getStringFromResource(
    name: string) {
    let context: common.UIAbilityContext | undefined = AppStorage.get('context');
    if (!context) {
      Logger.error(TAG, 'context is undefined');
    }
    let resourceMgr = context!.resourceManager;
    let res = await resourceMgr.getStringByName(name);
    return res;
  }

  static getMediaContent(resource: Resource): string {
    let context: common.UIAbilityContext | undefined = AppStorage.get('context');
    if (!context) {
      Logger.error(TAG, 'context is undefined');
    }
    let uint8Array = context?.resourceManager.getMediaContentSync(resource);
    let textDecoder = util.TextDecoder.create();
    let resStr = textDecoder.decodeToString(uint8Array);
    return resStr;
  }
}