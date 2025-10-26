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

// [Start system_date_time]
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
// [Start entry_form_ability]
// [Start want]
import { Want } from '@kit.AbilityKit';
// [Start form_binding_data]
// [Start form_info]
import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
// [StartExclude entry_form_ability]
import { CardListItemData, CommonData, FormData } from '../common/CommonData';
// [StartExclude form_info]
// [StartExclude form_binding_data]
// [StartExclude system_date_time]
import { CommonConstants } from '../common/CommonConstants';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';

// [EndExclude entry_form_ability]
// [EndExclude form_binding_data]
const TAG: string = 'EntryFormAbility';

// [EndExclude system_date_time]
// [EndExclude form_info]
export default class EntryFormAbility extends FormExtensionAbility {
  // [StartExclude form_binding_data]
  // [StartExclude form_info]
  onAddForm(want: Want): formBindingData.FormBindingData {
    if (!want || !want.parameters) {
      hilog.error(0x0000, TAG, `FormAbility onAddForm want or want.parameters is undefined`);
      return formBindingData.createFormBindingData('');
    }
    while (0) {
      let formName: string = want.parameters[formInfo.FormParam.NAME_KEY] as string;
      let formId: string = want.parameters[formInfo.FormParam.IDENTITY_KEY] as string;
      // [StartExclude system_date_time]
      // [StartExclude entry_form_ability]
      let util = PreferencesUtil.getInstance();
      let preferences = util.getPreferences(this.context);
      if (!preferences) {
        break;
      }
      // Save form id using preferences.
      util.addFormId(preferences, formId);

      // [StartExclude want]
      // [EndExclude system_date_time]
      if (formName === 'card_info_refresh') {
        let formData = new FormData(formId);
        formData.formTime = systemDateTime.getTime().toString();
        let formInfo: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        return formInfo;
      }

      // [EndExclude want]
      let key: string = `${formId}_show_index`;
      let data = util.getFormInitData(key, preferences);
      if (formName === 'card_info_update') {
        // Save the index of the data items currently displayed on the card.
        util.preferencesPut(preferences, key, data.id);
        let formData = new FormData(formId);
        formData.cardList.push(data);
        let formInfo: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
        return formInfo;
      }
    }
    // [EndExclude entry_form_ability]
    return formBindingData.createFormBindingData('');
  }

  // [StartExclude want]
  // [StartExclude entry_form_ability]
  // [StartExclude system_date_time]
  // [EndExclude form_info]
  onUpdateForm(formId: string) {
    // [StartExclude form_info]
    // Called to notify the form provider to update a specified form.
    hilog.info(0x0000, TAG, `FormAbility onUpdateForm, formId = ${formId}`);
    // [EndExclude form_info]
    let formData = new FormData(formId);
    // [StartExclude form_info]
    formData.formTime = systemDateTime.getTime().toString();

    let util = PreferencesUtil.getInstance();
    let preferences = util.getPreferences(this.context);
    if (!preferences) {
      return;
    }
    let key: string = `${formId}_show_index`;
    try {
      if (preferences.hasSync(key)) {
        let index = preferences.getSync(key, 0) as number;
        let newIndex = (index + 1) % 12;
        let dataItem: CardListItemData = (preferences.getSync('dataArr', []) as CardListItemData[])[newIndex];
        dataItem.favour = (preferences.getSync('statusArr', []) as boolean[])[newIndex];
        util.preferencesPut(preferences, key, newIndex);
        formData.cardList = [dataItem];
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `hasSync failed, error code=${err.code}, message=${err.message}`);
    }
    // [EndExclude form_info]
    let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
    formProvider.updateForm(formId, formMsg).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `updateForm failed, error code=${err.code}, message=${err.message}`);
    });
  }

  // [StartExclude form_info]
  // [EndExclude form_binding_data]
  onFormEvent(formId: string, message: string) {
    // [StartExclude form_binding_data]
    // Called when a specified message event defined by the form provider is triggered.
    hilog.info(0x0000, TAG, `FormAbility onFormEvent, formId = ${formId}, message: ${JSON.stringify(message)}`);
    // [EndExclude form_binding_data]
    let formData = new FormData(formId);
    // [StartExclude form_binding_data]
    let util = PreferencesUtil.getInstance();
    let preferences = util.getPreferences(this.context);
    if (!preferences) {
      return;
    }
    try {
      let index: number = preferences.getSync(CommonConstants.DATA_INDEX, 0) as number;
      formData.cardList = CommonData.getData(index);
      util.preferencesPut(preferences, CommonConstants.DATA_INDEX, index + 1);
      // [EndExclude form_binding_data]
      let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
      formProvider.updateForm(formId, formMsg).then(() => {
        hilog.info(0x0000, TAG, 'updateForm success.');
      }).catch((error: Error) => {
        let err = error as BusinessError;
        hilog.error(0x0000, TAG, `updateForm failed. error code=${err.code}, message=${err.message}`);
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `getSync failed, error code=${err.code}, message=${err.message}`);
    }
  }

  // [StartExclude form_binding_data]
  onAcquireFormState(_want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }

  async onRemoveForm(formId: string): Promise<void> {
    hilog.info(0x00, TAG, `remove formId: ${formId}`);
    PreferencesUtil.getInstance().removeFormId(this.context, formId);
  }

  // [EndExclude entry_form_ability]
  // [EndExclude system_date_time]
  // [EndExclude form_binding_data]
  // [EndExclude want]
  // [EndExclude form_info]
}

// [End entry_form_ability]
// [End system_date_time]
// [End form_binding_data]
// [End want]
// [End form_info]