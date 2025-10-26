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
import { LoginParams } from './model/LoginParams';
import { UserResp } from './model/UserResp';

let myHandler = async function (event, _context, callback, logger) {
  const userType: number = event.body ? JSON.parse(event.body).userType : event.userType;
  const username: string = event.body ? JSON.parse(event.body).username : event.username;
  const password: string = event.body ? JSON.parse(event.body).password : event.password;
  const unionId: string = event.body ? JSON.parse(event.body).unionId : event.unionId;
  const nickname: string = event.body ? JSON.parse(event.body).nickname : event.nickname;
  const portrait: string = event.body ? JSON.parse(event.body).portrait : event.portrait;

  const loginParams = new LoginParams(userType, unionId, username, password, nickname, portrait);

  try {
    const databaseHelper: DatabaseHelper = new DatabaseHelper(logger);
    const user: UserResp = await databaseHelper.queryUser(loginParams);
    if (user) {
      callback({
        code: 0,
        message: '[third-login] request successful',
        data: user,
      });
    } else {
      callback({
        code: 1,
        message: '[third-login] request failed',
        data: null,
      });
    }
  } catch (err) {
    logger.error(`[third-login] func error: ${err.message}`);
    callback({
      code: 3,
      message: '[third-login] operation exception',
      data: err,
    });
  }
};

export { myHandler };