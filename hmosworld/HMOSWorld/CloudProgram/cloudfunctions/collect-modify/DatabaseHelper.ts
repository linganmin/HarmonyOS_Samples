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
import { collect as Collect } from './model/collect';
import { resource as Resource } from './model/resource';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colCollect: CloudDBCollection<Collect>;
  colResource: CloudDBCollection<Resource>;

  constructor(logger) {
    this.logger = logger;
    this.colCollect = cloud.database({ zoneName: ZONE_NAME }).collection(Collect);
    this.colResource = cloud.database({ zoneName: ZONE_NAME }).collection(Resource);
  }

  async insertCollect(userId: string, resourceId: string): Promise<number | undefined> {
    try {
      const collectObj = new Collect();
      collectObj.setResource_id(resourceId);
      collectObj.setUser_id(userId);
      collectObj.setId(userId + resourceId);
      collectObj.setCollect_time(new Date());
      return await this.colCollect.upsert(collectObj);
    } catch (error) {
      this.logger.error(`[collect-modify] insert collect error ${error}`);
      return -1;
    }
  }

  async deleteCollect(userId: string, resourceId: string): Promise<number | undefined> {
    try {
      const cloudDBZoneQuery: CloudDBZoneQuery<Collect> =
        this.colCollect.query().equalTo("user_id", userId).equalTo("resource_id", resourceId);
      const collectData: Collect[] = await cloudDBZoneQuery.get();
      if (collectData.length > 0) {
        this.updateCollectedCount(resourceId, -1);
      }
      return await this.colCollect.delete(collectData);
    } catch (error) {
      this.logger.error(`[collect-modify] delete collect error ${error}`);
      return -1;
    }
  }

  async updateCollectedCount(resourceId: string, addCount: number) {
    try {
      const resourceQuery: CloudDBZoneQuery<Resource> = this.colResource.query().equalTo("id", resourceId);
      const resourceData: Resource[] = await resourceQuery.get();
      if (resourceData.length > 0) {
        const updateResource: Resource = resourceData[0];
        const resourceOperator: CloudDBZoneObjectOperator =
          CloudDBZoneObjectOperator.build(updateResource).increment('collect_count', addCount);
        await this.colResource.update(resourceOperator);
      }
    } catch (error) {
      this.logger.error(`[collect-modify] update collect error ${error}`);
    }
  }
}