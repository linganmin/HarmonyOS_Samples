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

import AsyncLock from 'async-lock/lib/index.js';
import { cloud, CloudDBCollection, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import { user_push_token as UserPushToken } from './model/user_push_token';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colUserPushToken: CloudDBCollection<UserPushToken>;
  lock = new AsyncLock();

  constructor(logger) {
    this.logger = logger;
    this.colUserPushToken = cloud.database({ zoneName: ZONE_NAME }).collection(UserPushToken);
  }

  async setToken(userId: string, deviceId: string, pushToken: string): Promise<number> {
    let result: number = -1;
    return new Promise((resolve, reject) => {
      this.lock.acquire('set-push-token', async () => {
        let userPushToken: UserPushToken | undefined = await this.queryPushToken(deviceId);
        if (!userPushToken) {
          result = await this.createPushToken(userId, deviceId, pushToken);
          resolve(result);
          return;
        }
        if (pushToken === userPushToken.getPush_token()) {
          result = 1;
          resolve(result);
        } else {
          result = await this.updatePushToken(userId, userPushToken, pushToken);
          resolve(result);
        }
      }, (err) => {
        if (err) {
          this.logger.error(`[set-push-token] set-push-token async-lock error: ${err}`);
          reject(result);
        }
      }, null)
    })
  }


  async queryPushToken(deviceId: string): Promise<UserPushToken | undefined> {
    let userPushToken: UserPushToken | undefined;
    try {
      const cloudDBZoneQuery: CloudDBZoneQuery<UserPushToken> =
        this.colUserPushToken.query().equalTo("device_id", deviceId);
      let pushTokens: UserPushToken[] = await cloudDBZoneQuery.get();
      if (pushTokens.length > 0) {
        userPushToken = pushTokens[0];
      }
      return userPushToken;
    } catch (error) {
      this.logger.error(`[set-push-token] queryPushToken error: ${JSON.stringify(error)}`);
    }
  }

  async createPushToken(userId, deviceId, pushToken): Promise<number> {
    try {
      const userPushToken = new UserPushToken();
      userPushToken.setPush_token(pushToken);
      userPushToken.setUser_id(userId);
      userPushToken.setDevice_id(deviceId);
      userPushToken.setCreate_time(new Date());
      return await this.colUserPushToken.insert(userPushToken);
    } catch (error) {
      this.logger.error(`[set-push-token] insert UserPushToken error: ${JSON.stringify(error)}`);
    }
  }

  async updatePushToken(userId: string, userPushToken: UserPushToken, pushToken: string): Promise<number> {
    try {
      userPushToken.setUser_id(userId);
      userPushToken.setPush_token(pushToken);
      userPushToken.setUpdate_time(new Date().toString());
      return await this.colUserPushToken.upsert(userPushToken);
    } catch (error) {
      this.logger.error(`[set-push-token] update UserPushToken error:${JSON.stringify(error)}`);
    }
  }
}