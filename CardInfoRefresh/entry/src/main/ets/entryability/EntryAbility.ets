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
// [Start ability_constant]
// [Start entry_ability]
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { formBindingData, formInfo, formProvider } from '@kit.FormKit';
import { rpc } from '@kit.IPCKit';
import { CardListItemData, CommonData, FormData } from '../common/CommonData';
// [StartExclude ability_constant]
// [StartExclude entry_ability]
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';
import { CommonConstants } from '../common/CommonConstants';

// [EndExclude entry_ability]
// [EndExclude ability_constant]
const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  // [StartExclude ability_constant]
  private callFunc = (data: rpc.MessageSequence): MyParcelable => {
    try {
      let params: Record<string, string> = JSON.parse(data.readString());
      if (params.formId !== undefined) {
        let formId: string = params.formId;
        let formData = new FormData(formId);
        // [StartExclude util]
        let util = PreferencesUtil.getInstance();
        let preferences = util.getPreferences(this.context);
        if (!preferences) {
          return new MyParcelable(1);
        }
        let index: number = preferences.getSync(CommonConstants.DATA_INDEX, 0) as number;
        formData.cardList = CommonData.getData(index);
        util.preferencesPut(preferences, CommonConstants.DATA_INDEX, index + 1);
        // [EndExclude util]
        let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        formProvider.updateForm(formId, formMsg).then((data) => {
          hilog.info(0x0000, TAG, 'updateForm success.', JSON.stringify(data));
        }).catch((error: Error) => {
          let err = error as BusinessError;
          hilog.error(0x0000, TAG, `updateForm failed. error code=${err.code}, message=${err.message}`);
        });
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `callFunc failed, error code=${err.code}, message=${err.message}`);
    }
    return new MyParcelable(1);
  };
  // [StartExclude entry_ability]
  private callUpdateFunc = (data: rpc.MessageSequence): MyParcelable => {
    try {
      let params: Record<string, string> = JSON.parse(data.readString());
      if (params.formId !== undefined) {
        let index: number = Number.parseInt(params.msgId);

        let util = PreferencesUtil.getInstance();
        let preferences = util.getPreferences(this.context);
        if (!preferences) {
          return new MyParcelable(1);
        }
        let dataItem: CardListItemData = (preferences.getSync('dataArr', []) as CardListItemData[])[index];
        let statusArr: boolean[] = preferences.getSync('statusArr', []) as boolean[];
        if (statusArr.length === 0) {
          statusArr = new Array(12).fill(false);
        }
        statusArr[index] = !statusArr[index];
        dataItem.favour = statusArr[index];

        preferences.putSync('statusArr', statusArr);
        preferences.flush(() => {
          AppStorage.setOrCreate('statusArr', [...statusArr]);
        });

        let idArr = PreferencesUtil.getInstance().getFormIds(preferences);
        if (idArr.length > 0) {
          idArr.forEach((formId: string) => {
            if (!preferences) {
              return;
            }
            if (preferences.getSync(`${formId}_show_index`, -1) as number === index) {
              let formData = new FormData(formId);
              formData.cardList = [dataItem];
              let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
              formProvider.updateForm(formId, formMsg)
                .then(() => {
                  hilog.info(0x0000, TAG, `updateForm success.`);
                })
                .catch((error: Error) => {
                  let err = error as BusinessError;
                  hilog.error(0x0000, TAG, `updateForm failed: error code=${err.code}, message=${err.message}`);
                });
            }
          })
        }
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `callUpdateFunc failed, error code=${err.code}, message=${err.message}`);
    }
    return new MyParcelable(1);
  };

  // [EndExclude entry_ability]
  // [EndExclude ability_constant]
  onCreate(want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    // [StartExclude ability_constant]
    // [StartExclude entry_ability]
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onCreate');
    this.initData();
    // [EndExclude ability_constant]
    this.updateInfo(want);
    // [StartExclude ability_constant]
    // [EndExclude entry_ability]
    try {
      this.callee.on('updateCardInfo', this.callFunc);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `on updateCardInfo failed, error code=${err.code}, message=${err.message}`);
    }
    // [StartExclude entry_ability]
    try {
      this.callee.on('updateFormFavour', this.callUpdateFunc);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `on updateFormFavour failed, error code=${err.code}, message=${err.message}`);
    }
    // [EndExclude entry_ability]
    // [EndExclude ability_constant]
  }

  // [StartExclude entry_ability]
  // [StartExclude ability_constant]
  initData(): void {
    let util = PreferencesUtil.getInstance();
    let preferences = util.getPreferences(this.context);
    let dataArr: CardListItemData[] = [];
    let keyDataArr: string = 'dataArr';
    if (!preferences) {
      return;
    }
    try {
      if (!preferences.hasSync(keyDataArr)) {
        CommonConstants.CARD_LIST_DATA_FIRST.forEach((item) => {
          dataArr.push(item);
        });
        CommonConstants.CARD_LIST_DATA_SECOND.forEach((item) => {
          dataArr.push(item);
        });
        CommonConstants.CARD_LIST_DATA_THIRD.forEach((item) => {
          dataArr.push(item);
        });
        preferences.putSync('dataArr', dataArr);
      } else {
        dataArr = preferences.getSync('dataArr', []) as CardListItemData[];
      }
      let statusArr: boolean[] = new Array(12).fill(false);
      let keyStatusArr: string = 'statusArr';
      if (!preferences.hasSync(keyStatusArr)) {
        preferences.putSync(keyStatusArr, statusArr);
      } else {
        statusArr = preferences.getSync('statusArr', []) as boolean[];
      }

      preferences.flush(() => {
        AppStorage.setOrCreate('dataArr', dataArr);
        AppStorage.setOrCreate('statusArr', statusArr);
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `initData failed, error code=${err.code}, message=${err.message}`);
    }
  }

  // [EndExclude ability_constant]
  onNewWant(want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    this.updateInfo(want);
  }

  private updateInfo(want: Want) {
    if (!want || !want.parameters || want.parameters[formInfo.FormParam.IDENTITY_KEY] === undefined) {
      return;
    }
    let message: string = (JSON.parse(want.parameters?.params as string))?.message;
    if (message === 'Router refresh card.') {
      let formId = want.parameters[formInfo.FormParam.IDENTITY_KEY].toString();
      let formData = new FormData(formId);
      // [StartExclude ability_constant]
      let util = PreferencesUtil.getInstance();
      let preferences = util.getPreferences(this.context);
      if (!preferences) {
        return;
      }
      try {
        let index: number = preferences.getSync(CommonConstants.DATA_INDEX, 0) as number;
        formData.cardList = CommonData.getData(index);
        util.preferencesPut(preferences, CommonConstants.DATA_INDEX, index + 1);
        // [EndExclude ability_constant]
        let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        formProvider.updateForm(formId, formMsg)
          .then((data) => {
            hilog.info(0x0000, TAG, 'updateForm success.', JSON.stringify(data));
          })
          .catch((error: Error) => {
            let err = error as BusinessError;
            hilog.error(0x0000, TAG, `updateForm failed.error code=${err.code}, message=${err.message}`);
          });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, TAG, `updateInfo failed, error code=${err.code}, message=${err.message}`);
      }
    }
  }

  // [EndExclude entry_ability]
  // [StartExclude ability_constant]
  onDestroy(): void {
    // [StartExclude entry_ability]
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onDestroy');
    // [EndExclude entry_ability]
    try {
      this.callee.off('updateCardInfo');
      // [StartExclude entry_ability]
      this.callee.off('updateFormFavour');
      // [EndExclude entry_ability]
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `Failed to disconnect callee. Cause: error code=${err.code}, message=${err.message}`);
    }
  }

  // [StartExclude entry_ability]
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageCreate');
    windowStage.getMainWindow((error: BusinessError, data) => {
      if (error && error.code) {
        hilog.error(0x0000, TAG,
          `Failed to get main window. Cause: error code=${error.code}, message=${error.message}`);
        return;
      }
      data.setWindowLayoutFullScreen(true).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `setWindowLayoutFullScreen failed, error code=${err.code}, message=${err.message}`);
      });
      try {
        AppStorage.setOrCreate('topHeight', data.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height);
        AppStorage.setOrCreate('bottomHeight',
          data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, TAG, `onWindowStageCreate failed, error code=${err.code}, message=${err.message}`);
      }
    });

    windowStage.loadContent('pages/Index', (err) => {
      if (err && err.code) {
        hilog.error(0x0000, TAG, `Failed to load the content. Cause: error code=${err.code}, message=${err.message}`);
        return;
      }
      hilog.info(0x0000, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, TAG, '%{public}s', 'Ability onBackground');
  }

  // [EndExclude entry_ability]
  // [EndExclude ability_constant]
}

// [End ability_constant]

class MyParcelable implements rpc.Parcelable {
  num: number;

  constructor(num: number) {
    this.num = num;
  }

  marshalling(dataOut: rpc.MessageSequence): boolean {
    try {
      dataOut.writeInt(this.num);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MyParcelable', `marshalling failed, error code=${err.code}, message=${err.message}`);
    }
    return true;
  }

  unmarshalling(dataIn: rpc.MessageSequence): boolean {
    try {
      this.num = dataIn.readInt();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MyParcelable', `unmarshalling failed, error code=${err.code}, message=${err.message}`);
    }
    return true;
  }
}

// [End entry_ability]