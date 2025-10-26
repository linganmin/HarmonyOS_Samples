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

import { AbilityConstant, bundleManager, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { nfcController, tag } from '@kit.ConnectivityKit';
import { JSON } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

let nfcTagElementName: bundleManager.ElementName;
let foregroundRegister: boolean;

async function readerModeCb(error: BusinessError, tagInfo: tag.TagInfo) {
  if (!error) {
    if (canIUse('SystemCapability.Communication.NFC.Tag')) {
      // Obtain NFC tag objects of specific technology types.
      if (tagInfo === null || tagInfo === undefined) {
        hilog.error(0x0000, 'testTag', 'readerModeCb tagInfo is invalid');
        return;
      }
      if (tagInfo.uid === null || tagInfo.uid === undefined) {
        hilog.error(0x0000, 'testTag', 'readerModeCb uid is invalid');
        return;
      }
      if (tagInfo.technology === null || tagInfo.technology === undefined || tagInfo.technology.length === 0) {
        hilog.error(0x0000, 'testTag', 'readerModeCb technology is invalid');
        return;
      }
      AppStorage.setOrCreate('tagInfo', tagInfo);


      let nfcA: tag.NfcATag | null = null;
      for (let i = 0; i < tagInfo.technology.length; i++) {
        if (tagInfo.technology[i] === tag.NFC_A) {
          try {
            nfcA = tag.getNfcA(tagInfo); // Get Tag object of NfcA type.
          } catch (error) {
            hilog.error(0x0000, 'testTag', 'readerModeCb getNfcA error = %{public}s', JSON.stringify(error));
            return;
          }
        }
        if (tagInfo.technology[i] === tag.NFC_B) {
          try {
            tag.getNfcB(tagInfo); // Get Tag object of NfcB type.
          } catch (error) {
            hilog.error(0x0000, 'testTag', 'readerModeCb getNfcB error = %{public}s', JSON.stringify(error));
            return;
          }
        }
        if (tagInfo.technology[i] === tag.NFC_F) {
          try {
            tag.getNfcF(tagInfo); // Get Tag object of NfcF type.
          } catch (error) {
            hilog.error(0x0000, 'testTag', 'readerModeCb getNfcF error = %{public}s', JSON.stringify(error));
            return;
          }
        }
        if (tagInfo.technology[i] === tag.NFC_V) {
          try {
            tag.getNfcV(tagInfo); // Get Tag object of NfcV type.
          } catch (error) {
            hilog.error(0x0000, 'testTag', 'readerModeCb getNfcV error = %{public}s', JSON.stringify(error));
            return;
          }
        }
        // Add other technology types.
      }

      // use the NFC_A technology to access this nfc tag.
      if (nfcA === undefined) {
        hilog.error(0x0000, 'testTag', 'readerModeCb getNfcA is invalid');
        return;
      }

      // Connect to this nfc tag using NFC_A technology.
      if (nfcA) {
        try {
          nfcA.connect();
        } catch (error) {
          hilog.error(0x0000, 'testTag', 'readerModeCb nfcA.connect() error = %{public}s', JSON.stringify(error));
          return;
        }
        try {
          if (!nfcA.isConnected()) {
            hilog.error(0x0000, 'testTag', 'readerModeCb nfcA.connect() false.');
            return;
          }
        } catch (error) {
          hilog.error(0x0000, 'testTag',`isConnected failed, Code:${error.code}, message:${error.message}`);
        }
        // Transmit data to the connected tag.
        let cmdData = [0x01, 0x02, 0x03, 0x04]; // Please change the raw data to be correct.
        try {
          // Send instructions to NfcA type tags.
          nfcA.transmit(cmdData)
            .then((response: number[]) => {
              hilog.info(0x0000, 'testTag', 'readerModeCb nfcA.transmit() response = %{public}s.',
                JSON.stringify(response));
            })
            .catch((err: BusinessError) => {
              hilog.info(0x0000, 'testTag', 'readerModeCb nfcA.transmit() err = %{public}s.',
                JSON.stringify(err));
              return;
            })
        } catch (error) {
          hilog.info(0x0000, 'testTag', 'readerModeCb nfcA.transmit() error = %{public}s.', JSON.stringify(error));
          return;
        }
      } else {
        hilog.info(0x0000, 'testTag', 'readerModeCb error %{public}s.', JSON.stringify(error));
      }
    }
  }
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      hilog.error(0x0000, 'testTag',`setColorMode failed, Code:${error.code}, message:${error.message}`);
    }
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    // Judge whether the device supports NFC capability.
    if (!canIUse('SystemCapability.Communication.NFC.Core')) {
      hilog.error(0x0000, 'testTag', 'nfc unavailable.')
      return;
    }

    nfcTagElementName = {
      bundleName: want.bundleName ?? '',
      abilityName: want.abilityName ?? '',
      moduleName: want.moduleName
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
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

    if (nfcTagElementName) {
      if (canIUse('SystemCapability.Communication.NFC.Tag')) {
        let techList: number[] =
          [tag.NFC_A, tag.NFC_B, tag.NFC_F, tag.NFC_V, tag.ISO_DEP, tag.NDEF, tag.NDEF_FORMATABLE, tag.MIFARE_CLASSIC,
            tag.MIFARE_ULTRALIGHT];
        try {
          tag.on('readerMode', nfcTagElementName, techList, readerModeCb);
          foregroundRegister = true;
        } catch (error) {
          hilog.error(0x0000, 'testTag', 'on readerMode error = %{public}s', JSON.stringify(error));
        }

        // NFC switch status event.
        if (canIUse('SystemCapability.Communication.NFC.Core')) {
          nfcController.on('nfcStateChange', () => {
            try {
              tag.on('readerMode', nfcTagElementName, techList, readerModeCb);
              foregroundRegister = true;
            } catch (error) {
              hilog.error(0x0000, 'testTag', 'on readerMode error = %{public}s', JSON.stringify(error));
            }
          })
        }
      }
    }
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');

    if (foregroundRegister) {
      if (canIUse('SystemCapability.Communication.NFC.Tag')) {
        foregroundRegister = false;
        try {
          tag.off('readerMode', nfcTagElementName, readerModeCb);
        } catch (error) {
          hilog.error(0x0000, 'testTag', 'off readerMode error = %{public}s', JSON.stringify(error));
        }
      }
    }
  }
}