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
import { ListResp } from './model/ListResp';

let myHandler = async function (event, _context, callback, logger) {
  let pathId: string = event.body ? JSON.parse(event.body).pathId : event.pathId;
  let pageNum: number = event.body ? JSON.parse(event.body).pageNum : event.pageNum;
  let pageSize: number = event.body ? JSON.parse(event.body).pageSize : event.pageSize;

  if (!pathId || !pageNum || !pageSize) {
    callback({
      code: 1,
      message: '[learning-comments] param can not empty',
      data: null,
    });
    return;
  }

  try {
    const databaseHelper: DatabaseHelper = new DatabaseHelper(logger);
    let result: ListResp[] = await databaseHelper.queryComment(pathId, pageNum, pageSize);

    if (result) {
      callback({
        code: 0,
        message: '[learning-comments] request successful',
        data: result,
      });
    } else {
      callback({
        code: 1,
        message: '[learning-comments] request failed',
        data: null,
      });
    }
  } catch (err) {
    logger.error(`[learning-comments] func error: ${err.message}`);
    callback({
      code: 3,
      message: '[learning-comments] operation exception',
      data: err,
    });
  }
};

export { myHandler };