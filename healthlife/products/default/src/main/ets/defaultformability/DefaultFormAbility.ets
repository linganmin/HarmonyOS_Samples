/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { FormInfo } from 'common';
import FormUtils from 'common/src/main/ets/utils/FormUtils';

// hilog tag
const TAG = 'DefaultFormAbility';

export default class DefaultFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    if (!want || !want.parameters) {
      hilog.error(0x0000, TAG, `FormAbility onAddForm want or want.parameters is undefined`);
      return formBindingData.createFormBindingData('');
    }
    // Obtain the current card information and add it to the card information base table.
    let formId: string = want.parameters[formInfo.FormParam.IDENTITY_KEY] as string;
    let formName: string = want.parameters[formInfo.FormParam.NAME_KEY] as string;
    let formDimension: number = want.parameters[formInfo.FormParam.DIMENSION_KEY] as number;
    let formInfoObj: FormInfo = new FormInfo(formId, formName, formDimension);
    FormUtils.insertFormData(this.context, formInfoObj);
    hilog.info(0x0000, TAG, `FormAbility onAddForm to init form is ${formName}`);
    // Called to return a FormBindingData object.
    const formData = '';
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    FormUtils.updateForms();
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
    FormUtils.deleteForm(this.context, formId);
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
}