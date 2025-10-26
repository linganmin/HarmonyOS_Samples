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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { convertDate2Str } from './Utils';
import RdbUtils from '../database/RdbUtils';
import { DayInfo } from '../model/database/DayInfo';
import { FormInfo } from '../model/database/FormInfo';
import DayInfoApi from '../database/tables/DayInfoApi';
import FormInfoApi from '../database/tables/FormInfoApi';
import FormStorageModel from '../model/FormStorageModel';
import { DayTaskInfo } from '../model/database/DayTaskInfo';
import DayTaskInfoApi from '../database/tables/DayTaskInfoApi';
import { CommonConstants as Const } from '../constants/CommonConstants';

// hilog tag.
const TAG: string = 'FormUtils';

class FormUtils {
  /**
   * Added service card information.
   * @param { Context } context context.
   * @param { FormInfo } formInfo service card info.
   * @returns { void }
   */
  public insertFormData(context: Context, formInfo: FormInfo): void {
    RdbUtils.createRdb(context).then(() => {
      FormInfoApi.insert(formInfo).then((formId: number) => {
        hilog.info(0x0000, TAG, `Insert formInfo successed, form info is ${formInfo.toString()}`);
        this.updateForms();
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG,
          `Insert formInfo failed, form info is ${formInfo.toString()}, code is ${err.code}, message is ${err.message}`);
      });
    });
  }

  /**
   * Query and updated data displayed on the all service card.
   * @returns { void }
   */
  public updateForms(): void {
    FormInfoApi.queryAll().then((formInfos: FormInfo[]) => {
      formInfos.forEach((item: FormInfo) => {
        this.updateByFormName(item);
      })
    })
  }

  /**
   * Update the displayed content based on the service card info.
   * @param { FormInfo } formInfo service card info.
   * @returns { void }
   */
  public updateByFormName(formInfo: FormInfo): void {
    const date = convertDate2Str(new Date());
    let updateDate: FormStorageModel = {};
    if (formInfo.formName === Const.FORM_NAME_AGENCY &&
      Number(formInfo.formDimension) === Const.DEFAULT_DIMENSION_2X4) {
      DayTaskInfoApi.queryDayTaskInfo(date).then((dayTaskInfos: DayTaskInfo[]) => {
        updateDate.dayTaskInfos = dayTaskInfos;
        this.updateFormByDate(updateDate, formInfo);
      })
    } else if (formInfo.formName === Const.FORM_NAME_PROGRESS &&
      Number(formInfo.formDimension) === Const.DEFAULT_DIMENSION_2X2) {
      DayInfoApi.queryByKey(date).then((dayInfo: DayInfo | null) => {
        if (!dayInfo) {
          dayInfo = new DayInfo(date, 0, 0);
        }
        updateDate.targetTaskNum = dayInfo.targetTaskNum;
        updateDate.finTaskNum = dayInfo.finTaskNum;
        updateDate.percentage = dayInfo.calculatePercentage();
        this.updateFormByDate(updateDate, formInfo);
      })
    }
  }

  /**
   * Update the displayed content based on the service card info and date.
   * @param { FormStorageModel } updateDate data that needs to be updated.
   * @param { FormInfo } formInfo service card info.
   * @returns { void }
   */
  private updateFormByDate(updateDate: FormStorageModel, formInfo: FormInfo) {
    let formData = formBindingData.createFormBindingData(updateDate);
    formProvider.updateForm(formInfo.formId, formData).then(() => {
      hilog.info(0x0000, TAG,
        `Form update successed, form info is ${formInfo.toString()}, formData is ${formData.data.toString()}`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG,
        `Form update failed, form info is ${formInfo.toString()}, formData is ${formData.data.toString()}, code is ${err.code}, message is ${err.message}`);
    });
  }

  /**
   * Deleted service card information by card id.
   * @param { Context } context context.
   * @param { string } formId service card id.
   * @returns { void }
   */
  public deleteForm(context: Context, formId: string): void {
    RdbUtils.createRdb(context).then(() => {
      FormInfoApi.delete(formId).then(() => {
        hilog.info(0x0000, TAG, `Delete formInfo successed, formId is ${formId}`);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG,
          `Delete formInfo failed, formId is ${formId}, code is ${err.code}, message is ${err.message}`);
      });
    })
  }
}

export default new FormUtils();