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

import { DatabaseHelper } from './DatabaseHelper';
import { ResourceResp } from './model/ResourceResp';
import { form_info as FormInfo } from './model/form_info';

let myHandler = async function (_event, context, callback, logger) {

  try {
    const credential = JSON.parse(context.env.PROJECT_CREDENTIAL);
    const databaseHelper: DatabaseHelper = new DatabaseHelper(logger);
    // Obtain the data of push cards.
    const resultList: ResourceResp[] = await databaseHelper.queryResData();
    // Request token for verification.
    const authorization: string = await databaseHelper.getToken();
    // Carry out risk control verification on the pictures issued by the plan and obtain the addresses of the verified pictures.
    await databaseHelper.convertUrl(resultList, credential, authorization);
    // Obtain information about the registration card.
    const formInfos: FormInfo[] = await databaseHelper.queryFormInfo();
    if (formInfos === undefined) {
      callback({
        code: 1,
        message: '[push-data] operation failed'
      });
    }
    // Send a request to refresh the content of the card.
    for (let index = 0; index < formInfos.length; index++) {
      databaseHelper.pushData(resultList, formInfos[index], credential, authorization).then(() => {
      });
    }
    callback({
      code: 0,
      message: '[push-data] operation successful'
    });

  } catch (err) {
    logger.error(`[push-message] func error: ${err}`);
    callback({
      code: 3,
      message: '[push-data] operation exception'
    });
  }
}

export { myHandler };