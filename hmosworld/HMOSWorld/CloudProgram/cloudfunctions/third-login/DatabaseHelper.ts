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

import { cloud, CloudDBCollection, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import { LoginParams } from './model/LoginParams';
import { user as User } from './model/user';
import { UserResp } from './model/UserResp';

const ZONE_NAME = 'HMOSWorld';
const HW_ACCOUNT_LOGIN = 2;

export class DatabaseHelper {
  logger;
  colUser: CloudDBCollection<User>;

  constructor(logger) {
    this.logger = logger;
    this.colUser = cloud.database({ zoneName: ZONE_NAME }).collection(User);
  }

  async queryUser(loginParams: LoginParams): Promise<UserResp> {
    try {
      let userResp: UserResp;
      let userResult: User;
      // Huawei account login.
      if (loginParams.userType === HW_ACCOUNT_LOGIN && loginParams.unionId !== '') {
        // Run the unionId command to check whether the user exists, and create a user if the user does not exist.
        userResult = await this.accountLogin(loginParams);
      } else {
        const cloudDBZoneQuery: CloudDBZoneQuery<User> =
          this.colUser.query().equalTo("username", loginParams.username).equalTo("password", loginParams.password);
        const userList: User[] = await cloudDBZoneQuery.get();
        if (userList.length > 0) {
          userResult = userList[0];
        }
      }

      if (userResult) {
        userResp = new UserResp(
          userResult.getId(),
          userResult.getUsername(),
          userResult.getPortrait(),
          userResult.getDescription(),
          userResult.getNickname(),
          userResult.getUser_type()
        );
      }
      return userResp;
    } catch (error) {
      this.logger.error(`[third-login] queryUser error: ${error}`);
    }
  }

  async accountLogin(loginParams: LoginParams): Promise<User> {
    let userResult: User;
    const cloudDBZoneQuery: CloudDBZoneQuery<User> = this.colUser.query().equalTo("union_id", loginParams.unionId);
    const userList: User[] = await cloudDBZoneQuery.get();
    // If the user data already exists, return directly; otherwise, insert the user data.
    if (userList.length > 0) {
      userResult = userList[0];
    } else {
      const maxIdUserQuery: CloudDBZoneQuery<User> = this.colUser.query().orderByDesc("id").limit(1);
      const maxIdUserData: User[] = await maxIdUserQuery.get();
      let newUserId = 'u10000001';
      if (maxIdUserData.length > 0) {
        const maxIdUser: User = maxIdUserData[0];
        const userId: string = maxIdUser.getId();
        const id = userId.replace('u', '');
        newUserId = 'u' + (Number.parseInt(id) + 1);
      }
      const createResult: number = await this.createUser(loginParams, newUserId);
      if (createResult > 0) {
        const userList: User[] = await cloudDBZoneQuery.get();
        userResult = userList[0];
      }
    }
    return userResult;
  }

  async createUser(loginParams: LoginParams, newUserId: string): Promise<number> {
    try {
      const createUser = new User();
      createUser.setId(newUserId);
      createUser.setPortrait(loginParams.portrait);
      createUser.setNickname(loginParams.nickname);
      createUser.setUnion_id(loginParams.unionId);
      createUser.setUser_type(HW_ACCOUNT_LOGIN);
      createUser.setDescription('这个人很懒，什么也没留下');
      return await this.colUser.upsert(createUser);
    } catch (error) {
      this.logger.error(`[third-login] createUser error: ${error}`);
      return -1;
    }
  }
}