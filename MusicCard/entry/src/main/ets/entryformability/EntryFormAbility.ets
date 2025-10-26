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

import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../constants/CommonConstants';
import { FormRdbHelper } from '../database/FormRdbHelper';
import { FormInfo } from '../viewmodel/FormInfo';
import FormUtils from '../utils/FormUtils';

const TAG = 'EntryFormAbility';
const IMAGE_URL1 =
  'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-w9dgx/' +
    'cover1.png?token=578c1e5e-c745-4afd-9a7b-7ffb43c823a1';
const IMAGE_URL2 =
  'https://agc-storage-drcn.platform.dbankcloud.cn/v0/default-bucket-w9dgx/' +
    'cover4.png?token=9ff69ef3-b596-4270-b4a7-c1ffff24a3d0';

// [Start entry_form_ability]
// [Start dynamic_lyrics_entry_form_ability]
// [Start dynamic_lyrics_lasting_card_info]
// [Start dynamic_lyrics_card_info_init]
// [Start music_control_card_add_init]
// [Start music_control_card_lasting_info]
// [Start music_recommended_card_update_image]
// [Start music_heart_card_update]
export default class EntryFormAbility extends FormExtensionAbility {
  // [StartExclude music_heart_card_update]
  onAddForm(want: Want) {
    // [StartExclude music_control_card_add_init]
    hilog.info(0x0000, TAG, 'onAddForm');
    // [EndExclude music_control_card_add_init]
    if (want.parameters) {
      let formId = want.parameters['ohos.extra.param.key.form_identity'] as string;
      let formName = want.parameters['ohos.extra.param.key.form_name'] as string;
      // [StartExclude music_control_card_add_init]
      // [StartExclude music_recommended_card_update_image]
      // [End onaddform_export]
      let formDimension = want.parameters['ohos.extra.param.key.form_dimension'] as string;
      // [StartExclude dynamic_lyrics_entry_form_ability]
      // [StartExclude dynamic_lyrics_card_info_init]

      let formInfo = new FormInfo();
      formInfo.formId = formId;
      formInfo.formDimension = formDimension;
      formInfo.formName = formName;
      hilog.info(0x0000, TAG, `onAddForm formInfo: ${JSON.stringify(formInfo)}`);
      FormRdbHelper.getInstance(this.context).insertForm(formInfo);
      // [EndExclude dynamic_lyrics_card_info_init]
      // [EndExclude music_control_card_add_init]
      // [StartExclude dynamic_lyrics_lasting_card_info]
      // [StartExclude dynamic_lyrics_card_info_init]
      // [StartExclude music_control_card_lasting_info]
      this.trigger3DLiveRequest(formId);

      if (formName.includes('PlayControlCard')) {
        FormUtils.updateMusicControlCard(formId, true);
      }
      // [StartExclude music_control_card_add_init]
      // [StartExclude form_name]

      if (formName === 'LyricsCard') {
        FormUtils.updateLyricsCard(this.context, formInfo.formId);
      }
      // [EndExclude dynamic_lyrics_entry_form_ability]
      // [EndExclude dynamic_lyrics_card_info_init]

      if (formName === 'DynamicLyrics') {
        FormUtils.updateMusicControlCard(formId, true);
      }
      // [EndExclude music_recommended_card_update_image]

      // [StartExclude dynamic_lyrics_card_info_init]
      // [StartExclude dynamic_lyrics_entry_form_ability]
      if (formName === 'RecommendedMusic1x2' || formInfo.formName === 'RecommendedMusic2x4') {
        FormUtils.updateRecommendedCard(this.context, formInfo.formId, IMAGE_URL1);
      }
      // [EndExclude dynamic_lyrics_card_info_init]
      // [EndExclude form_name]
      // [EndExclude music_control_card_add_init]
      // [EndExclude music_control_card_lasting_info]
    }
    // [EndExclude dynamic_lyrics_lasting_card_info]
    return formBindingData.createFormBindingData('');
  }

  // [StartExclude music_control_card_lasting_info]
  // [StartExclude music_control_card_add_init]
  // [StartExclude music_recommended_card_update_image]

  // [StartExclude dynamic_lyrics_card_info_init]

  // [StartExclude dynamic_lyrics_lasting_card_info]
  // [StartExclude on_casttonormal_form]
  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
    hilog.info(0x0000, TAG, 'onCastToNormalForm');
  }
  // [EndExclude music_heart_card_update]

  onUpdateForm(formId: string) {
    // [StartExclude music_heart_card_update]
    // Called to notify the form provider to update a specified form.
    hilog.info(0x0000, TAG, `onUpdateForm formId：${formId}`);
    // [EndExclude music_heart_card_update]
    FormRdbHelper.getInstance(this.context)
      .queryFormById(formId)
      .then((formInfo) => {
        // [StartExclude music_heart_card_update]
        hilog.info(0x0000, TAG, `onUpdateForm formName: ${formInfo.formName}`);
        // update Recommended Card
        if (formInfo.formName === 'RecommendedMusic1x2' || formInfo.formName === 'RecommendedMusic2x4') {
          FormUtils.updateRecommendedCard(this.context, formInfo.formId, IMAGE_URL2);
        }
        // update Lyrics Card
        // [EndExclude music_heart_card_update]
        if (formInfo.formName === 'LyricsCard') {
          FormUtils.updateLyricsCard(this.context, formInfo.formId);
        }
        // [StartExclude music_heart_card_update]

        if (formInfo.formName === 'DynamicLyrics') {
          FormUtils.updateDynamicLyricsControlCard(this.context, formInfo.formId);
        }
        // [EndExclude music_heart_card_update]
      });
  }
  // [StartExclude music_heart_card_update]

  // [Start trigger]
  private trigger3DLiveRequest(formId: string) {
    formProvider.getFormRect(formId).then((data: formInfo.Rect) => {
      let cardWidth = data.width * CommonConstants.LIVE_CARD_RATIO;
      let cardHeight = data.height * CommonConstants.LIVE_CARD_RATIO;
      let leftOffset = (data.width - cardWidth) / 2;
      let topOffset = (data.height - cardHeight) / 2;
      formProvider.requestOverflow(formId, {
        area: {
          left: leftOffset,
          top: topOffset,
          width: cardWidth,
          height: cardHeight
        },
        duration: 3500
      }).then(() => {
        hilog.info(0x0000, TAG, 'requestOverflow result succeed');
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, TAG, `requestOverflow catch error, code: ${error.code}, message: ${error.message}`)
      })
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, TAG, `getFormRect catch error, code: ${error.code}, message: ${error.message}`)
    })
    return;
  }
  // [End trigger]

  // [Start overflow]
  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
    let shortMessage: string = JSON.parse(message)['message'];
    hilog.info(0x0000, TAG, 'onFormEvent');
    if (shortMessage === 'requestOverFlow') {
      this.trigger3DLiveRequest(formId);
    }
  }
  // [End overflow]

  // [EndExclude on_casttonormal_form]
  // [EndExclude dynamic_lyrics_lasting_card_info]
  // [EndExclude music_control_card_lasting_info]
  onRemoveForm(formId: string) {
    hilog.info(0x0000, TAG, 'onRemoveForm');
    // Called to notify the form provider that a specified form has been destroyed.
    FormRdbHelper.getInstance(this.context).deleteForm(formId);
  }

  // [End dynamic_lyrics_lasting_card_info]
  // [StartExclude dynamic_lyrics_lasting_card_info]
  // [StartExclude on_acquire_formstate]
  // [StartExclude music_control_card_lasting_info]
  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }

  // [EndExclude on_acquire_formstate]
  // [EndExclude dynamic_lyrics_entry_form_ability]
  // [EndExclude dynamic_lyrics_lasting_card_info]
  // [EndExclude dynamic_lyrics_card_info_init]
  // [EndExclude music_control_card_add_init]
  // [EndExclude music_control_card_lasting_info]
  // [EndExclude music_recommended_card_update_image]
  // [EndExclude music_heart_card_update]
}

// [End music_control_card_add_init]
// [End music_control_card_lasting_info]
// [End entry_form_ability]
// [End dynamic_lyrics_entry_form_ability]
// [End dynamic_lyrics_card_info_init]
// [End music_recommended_card_update_image]
// [End music_heart_card_update]