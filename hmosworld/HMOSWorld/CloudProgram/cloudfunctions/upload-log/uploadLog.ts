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
  const versionName: string = event.body ? JSON.parse(event.body).versionName : event.versionName;
  const methodClassName: string = event.body ? JSON.parse(event.body).methodClassName : event.methodClassName;
  const methodName: string = event.body ? JSON.parse(event.body).methodName : event.methodName;
  const time: string = event.body ? JSON.parse(event.body).time : event.time;
  const isStatic: boolean = event.body ? JSON.parse(event.body).isStatic : event.isStatic;
  const params: string = event.body ? JSON.parse(event.body).params : event.params;
  const type: string = event.body ? JSON.parse(event.body).type : event.type;

  try {
    const databaseHelper: DatabaseHelper = new DatabaseHelper(logger);
    const result: number =
      await databaseHelper.insertAspectInfo(versionName, methodClassName, methodName, time, isStatic, params, type);
    if (result > 0) {
      callback({
        code: 0,
        message: "[upload-log] operation successful",
        data: result,
      });
    } else {
      callback({
        code: 1,
        message: "[upload-log] operation failed",
        data: null,
      });
    }
  } catch (err) {
    logger.error(`[upload-log] func error: ${err.message}`);
    callback({
      code: 3,
      message: '[upload-log] operation exception',
      data: err,
    });
  }
};

export { myHandler };