/*
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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

import { common } from '@kit.AbilityKit';
import consts from '../module/Consts';
import { preferences } from '@kit.ArkData';
import Logger from '../module/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = '[Sample_CustomCommonEvent_HistoryFeature]';

export default class HistoryFeature {
  constructor(abilityContext: common.UIAbilityContext) {
    this.innerContext = abilityContext;
  }

  async getData() {
    await this.init()
    return new Promise<string[][]>((resolve) => {
      resolve(this.dataSource);
    })
  }

  private async init() {
    let prefer: preferences.Preferences | null = null
    if (this.innerContext) {
      await preferences.getPreferences(this.innerContext, consts.DATA_BASE_NAME).then((pref) => {
        prefer = pref;
      }).catch((err: BusinessError) => {
        Logger.error(`getPreferences failed, Code:${err.code}, message:${err.message}`);
      });
    }
    if (!prefer) {
      return;
    }
    let records: Array<string> = [];
    await (prefer as preferences.Preferences).get(consts.DATA_BASE_KEY_TOTAL_TIMES, [])
      .then((value: preferences.ValueType) => {
        records = value as Array<string>;
      }).catch((err: BusinessError) => {
        Logger.error(`get failed, Code:${err.code}, message:${err.message}`);
      });
    for (let item of records) {
      await (prefer as preferences.Preferences).get(item, []).then((detail: preferences.ValueType) => {
        if (JSON.stringify(detail) !== '[]') {
          this.dataSource.push(detail as Array<string>);
        }
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `Failed to get value code is ${error.code}`);
      })
    }
  }

  private dataSource: Array<Array<string>> = [];
  private innerContext: common.UIAbilityContext | null = null;
}