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

import { cloud, CloudDBCollection, CloudDBZoneObjectOperator, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import { resource as Resource } from './model/resource';
import { user_like as UserLike } from './model/user_like';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colResource: CloudDBCollection<Resource>;
  colUserLike: CloudDBCollection<UserLike>;

  constructor(logger) {
    this.logger = logger;
    this.colResource = cloud.database({ zoneName: ZONE_NAME }).collection(Resource);
    this.colUserLike = cloud.database({ zoneName: ZONE_NAME }).collection(UserLike);
  }

  async insertLike(userId: string, resourceId: string): Promise<number | undefined> {
    try {
      const likeObj = new UserLike();
      likeObj.setResource_id(resourceId);
      likeObj.setUser_id(userId);
      likeObj.setId(userId + resourceId);
      const resp: number = await this.colUserLike.upsert(likeObj);
      this.updateLikeCount(resourceId, 1);
      return resp;
    } catch (error) {
      this.logger.error(`[like] insert like error: ${error}`);
      return -1;
    }
  }

  async deleteLike(userId: string, resourceId: string): Promise<number | undefined> {
    try {
      const cloudDBZoneQuery: CloudDBZoneQuery<UserLike> =
        this.colUserLike.query().equalTo("user_id", userId).equalTo("resource_id", resourceId);
      const collectData: UserLike[] = await cloudDBZoneQuery.get();
      const resp2: number = await this.colUserLike.delete(collectData);
      this.updateLikeCount(resourceId, -1);
      return resp2;
    } catch (error) {
      this.logger.error(`[like] delete like error: ${error}`);
      return -1;
    }
  }

  async updateLikeCount(resourceId: string, addCount: number) {
    try {
      const resourceQuery: CloudDBZoneQuery<Resource> = this.colResource.query().equalTo("id", resourceId);
      const resourceData: Resource[] = await resourceQuery.get();
      if (resourceData.length > 0) {
        const updateResource: Resource = resourceData[0]
        const operator = CloudDBZoneObjectOperator.build(updateResource).increment('likes_count', addCount);
        await this.colResource.update(operator);
      }
    } catch (error) {
      this.logger.error(`[like] updateLikeCount error: ${error}`);
    }
  }
}