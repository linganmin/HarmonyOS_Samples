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

import { cloud, CloudDBCollection} from '@hw-agconnect/cloud-server';
import { form_info as FormInfo } from './model/form_info';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colFormInfo: CloudDBCollection<FormInfo>;

  constructor(logger) {
    this.logger = logger;
    this.colFormInfo = cloud.database({zoneName: ZONE_NAME}).collection(FormInfo);
  }

  async removeFormInfo(formId: string, token: string) {
    try {
      const formInfo = new FormInfo();
      const id = formId + token;
      formInfo.setId(id);
      formInfo.setForm_id(formId);
      formInfo.setToken(token);
      return await this.colFormInfo.delete(formInfo);
    } catch (error) {
      this.logger.error(`[removeforminfo] removeFormInfo error: ${error}`);
      return -1;
    }
  }
}