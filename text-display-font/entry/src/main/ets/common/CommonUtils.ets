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

import { display } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'PreferenceUtils';
const TEXT_FONT_SIZE = 'textFontSize';
const TEXT_FONT_WEIGHT = 'textFontWeight';
const TEXT_FONT = 'textFont';

// [Start GetFont]
export class PreferenceUtils {
  preference?: preferences.Preferences;

  // Get Preferences instance
  getTextFontPreference(context: Context) {
    try {
      this.preference = preferences.getPreferencesSync(context, { name: 'TextFontPreference' });
      hilog.info(0x0000, TAG, 'create preference success');
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, TAG, `create preference failed. code: ${error.code}, message:${err.message}`);
    }
  }

  // [StartExclude GetFont]
  // Save the modified font size
  saveModifyFontSize(fontValue: number) {
    try {
      this.preference?.putSync(TEXT_FONT_SIZE, fontValue);
      this.preference?.flush((err: BusinessError) => {
        if (err) {
          hilog.error(0x0000, TAG, `Failed to flush. code:${err.code}, message:${err.message}`);
          return;
        }
      })
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, TAG,
        `putSync or flush fontSize preference data failed. code: ${error.code}, message:${err.message}`);
    }
  }

  // Get font size
  getFontSize(): number {
    let textFontSize: number = 0;
    try {
      textFontSize = this.preference?.getSync(TEXT_FONT_SIZE, 0) as number;
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, TAG, `getSync fontSize preference data failed. code: ${error.code}, message:${err.message}`);
    }
    return textFontSize;
  }

  // Save the modified font thickness
  saveModifyFontWeight(fontValue: number) {
    try {
      this.preference?.putSync(TEXT_FONT_WEIGHT, fontValue);
      this.preference?.flush((err: BusinessError) => {
        if (err) {
          hilog.error(0x0000, TAG, `Failed to flush. code:${err.code}, message:${err.message}`);
          return;
        }
        hilog.info(0x0000, TAG, 'Succeeded in flushing.');
      })
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, TAG,
        `putSync or flush fontWeight preference data failed. code: ${error.code}, message:${err.message}`);
    }
  }

  // Get font thickness
  getFontWeight(): number {
    let textFontWeight: number = 0;
    try {
      textFontWeight = this.preference?.getSync(TEXT_FONT_WEIGHT, 400) as number;
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, TAG, `getSync fontWeight preference data failed. code: ${error.code}, message:${err.message}`);
    }
    return textFontWeight;
  }
  // [EndExclude GetFont]

  // Save Font
  saveModifyFont(textFont: string) {
    try {
      this.preference?.putSync(TEXT_FONT, textFont);
      this.preference?.flush((err: BusinessError) => {
        if (err) {
          hilog.error(0x0000, TAG, `Failed to flush. code:${err.code}, message:${err.message}`);
          return;
        }
        hilog.info(0x0000, TAG, 'Succeeded in flushing.');
      })
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, TAG,
        `putSync or flush font preference data failed. code: ${error.code}, message:${err.message}`);
    }
  }

  // Get Font
  getFont(): string {
    let textFont: string = '';
    try {
      textFont = this.preference?.getSync(TEXT_FONT, '') as string;
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, TAG, `getSync font preference data failed. code: ${error.code}, message:${err.message}`);
    }
    return textFont;
  }
}

export default new PreferenceUtils();

// [Start GetFont]

// [Start Register_Font]
// Register font
export function registerMyFont(uiContext: UIContext) {
  try {
    // Register HarmonyOS Italic font through registrant Font
    uiContext.getFont().registerFont({
      familyName: $r('app.string.HarmonyOS_Italic'),
      familySrc: $rawfile('HarmonyOS_SansItalic.ttf')
    });
    // Register HarmonyOS Condensed font through registrant Font
    uiContext.getFont().registerFont({
      familyName: $r('app.string.HarmonyOS_Condensed'),
      familySrc: $rawfile('HarmonyOS_Condensed.ttf')
    });
  } catch (err) {
    let error = err as BusinessError;
    hilog.error(0x0000, TAG, `registerFont failed. code: ${error.code}, message:${err.message}`);
  }
}
// [End Register_Font]

// [Start Fp2px_Util]
// Convert fp to px
export function fp2pxUtil(fp: number): string {
  const pxStr: string = 'px';
  let pxVal: number = 0;
  let displayClass: display.Display | null = null;
  try {
    displayClass = display.getDefaultDisplaySync();
    pxVal = fp * (displayClass.densityDPI / 160);
  } catch (err) {
    let error = err as BusinessError;
    hilog.error(0x0000, TAG, `get densityDPI failed. code: ${error.code}, message:${err.message}`);
  }
  return pxVal + pxStr;
}
// [End Fp2px_Util]