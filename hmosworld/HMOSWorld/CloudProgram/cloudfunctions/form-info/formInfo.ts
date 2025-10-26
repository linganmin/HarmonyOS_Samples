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

let myHandler = async function (event, _context, callback, logger) {
  const formId: string = event.body ? JSON.parse(event.body).formId : event.formId;
  const token: string = event.body ? JSON.parse(event.body).token : event.token;

  if (!formId || !token) {
    callback({
      code: 1,
      message: '[forminfo] params can not empty',
      data: null,
    });
  }

  try {
    const databaseHelper: DatabaseHelper = await new DatabaseHelper(logger);
    let result: number = await databaseHelper.insertFormInfo(formId, token);
    if (result > 0) {
      callback({
        code: 0,
        message: '[form-info] operation successful',
      });
    } else {
      callback({
        code: 1,
        message: '[form-info] operation failed',
      });
    }
  } catch (err) {
    logger.error(`[form-info] func error: ${err.message}`);
    callback({
      code: 3,
      message: '[form-info] operation exception',
      data: err,
    });
  }
};

export { myHandler };