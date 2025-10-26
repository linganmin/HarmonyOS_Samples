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

import { cloud, CloudDBCollection, CloudDBZoneQuery} from '@hw-agconnect/cloud-server';
import { collect as Collect} from './model/collect';
import { user as User} from './model/user';
import { UserDataResp } from './model/UserDataResp';
import { user_like as UserLike} from './model/user_like';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colCollect: CloudDBCollection<Collect>;
  colUser: CloudDBCollection<User>;
  colUserLike: CloudDBCollection<UserLike>;

  constructor(logger) {
    this.logger = logger;
    this.colCollect = cloud.database({zoneName: ZONE_NAME}).collection(Collect);
    this.colUser = cloud.database({zoneName: ZONE_NAME}).collection(User);
    this.colUserLike = cloud.database({zoneName: ZONE_NAME}).collection(UserLike);
  }

  async queryUser(userId: string): Promise<UserDataResp> {
    try {
      const cloudDBZoneQuery: CloudDBZoneQuery<User> = this.colUser.query().equalTo("id", userId);
      const userList: User[] = await cloudDBZoneQuery.get();
      if (userList.length > 0) {
        const user: User = userList[0];
        const likedIds: string[] = await this.queryLikedIds(userId);
        const collectedIds: string[] = await this.queryCollectedIds(userId);
        return new UserDataResp(
          user.getId(),
          user.getUsername(),
          user.getPortrait(),
          user.getDescription(),
          user.getNickname(),
          user.getUser_type(),
          likedIds,
          collectedIds);
      } else {
        return undefined;
      }
    } catch (error) {
      this.logger.error(`[user-data] queryUser error: ${error}`);
    }
  }

  async queryLikedIds(userId): Promise<string[]> {
    const likedIds: string[] = [];
    try {
      const likeQuery: CloudDBZoneQuery<UserLike> = this.colUserLike.query().equalTo('user_id', userId);
      const likeData: UserLike[] = await likeQuery.get();
      for (let index = 0; index < likeData.length; index++) {
        const element: UserLike = likeData[index];
        likedIds.push(element.getResource_id());
      }
      return likedIds;
    } catch (error) {
      this.logger.error(`[user-data] queryLikedIds error: ${error}`);
    }
  }

  async queryCollectedIds(userId): Promise<string[]> {
    const collectedIds: string[] = [];
    try {
      const collectedQuery: CloudDBZoneQuery<Collect> = this.colCollect.query().equalTo('user_id', userId);
      const collectedData: Collect[] = await collectedQuery.get();
      for (let index = 0; index < collectedData.length; index++) {
        const element: Collect = collectedData[index];
        collectedIds.push(element.getResource_id());
      }
      return collectedIds;
    } catch (error) {
      this.logger.error(`[user-data] queryCollectedIds error: ${error}`);
    }
  }
}