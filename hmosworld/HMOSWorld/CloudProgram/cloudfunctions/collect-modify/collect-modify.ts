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
  const userId: string = event.body ? JSON.parse(event.body).userId : event.userId;
  const resourceId: string = event.body ? JSON.parse(event.body).resourceId : event.resourceId;
  const operation: number = event.body ? JSON.parse(event.body).operation : event.operation;

  if (!userId || !resourceId) {
    callback({
      code: 1,
      message: '[collect-modify] param can not empty',
      data: null,
    });
  }

  let result: number | undefined;
  try {
    const databaseHelper: DatabaseHelper = new DatabaseHelper(logger);
    if (operation === 1) {
      result = await databaseHelper.insertCollect(userId, resourceId);
    } else if (operation === 0) {
      result = await databaseHelper.deleteCollect(userId, resourceId);
    }
    if (result > 0) {
      callback({
        code: 0,
        message: '[collect-modify] operation successful',
        data: null,
      });
    } else {
      callback({
        code: 1,
        message: '[collect-modify] operation failed',
        data: null,
      });
    }
  } catch (err) {
    logger.error(`[collect-modify] func error: ${err.message}`);
    callback({
      code: 3,
      message: '[collect-modify] operation exception',
      data: err,
    });
  }
};

export { myHandler };