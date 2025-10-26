/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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
import { Logger } from '../utils/Logger';

const TAG = 'VIEW_MODEL';

export interface VideoPreparedEvent {
  duration: number;
}

export interface VideoUpdateEvent {
  time: number;
}

export interface Caption {
  text: ResourceStr;
  startTime: number;
  endTime: number;
}

export interface CaptionFont {
  family: ResourceStr;
  size: number;
  color: ResourceColor;
}

export interface CaptionFontColor {
  color: ResourceColor;
  backgroundColor: ResourceColor;
  colorName: ResourceStr;
}

export function registerMyFont(uiContext: UIContext) {
  try {
    uiContext.getFont().registerFont({
      familyName: $r('app.string.HarmonyOS_Condensed'),
      familySrc: $rawfile('HarmonyOS_Condensed.ttf')
    });
  } catch (err) {
    let error = err as BusinessError;
    Logger.error(TAG, `registerFont faile. code: ${error.code}, message:${err.message}`);
  }
}