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
import { user_topic as UserTopic} from './model/user_topic';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colUserTopic: CloudDBCollection<UserTopic>;

  constructor(logger) {
    this.logger = logger;
    this.colUserTopic = cloud.database({zoneName: ZONE_NAME}).collection(UserTopic);
  }

  async modifyTopic(followIds: string, userId: string): Promise<number> {
    const ids: string[] = followIds.split(',');
    try {
      const userTopicQuery: CloudDBZoneQuery<UserTopic> = this.colUserTopic.query().equalTo("user_id", userId);
      const userTopics: UserTopic[] = await userTopicQuery.get();
      if (userTopics.length > 0) {
        await this.colUserTopic.delete(userTopics);
      }
      return await this.insertTopic(ids, userId);
    } catch (error) {
      this.logger.error(`[topic-modify] modifyTopic error: ${error}`);
      return -1;
    }
  }

  async insertTopic(followIds: string[], userId: string): Promise<number> {
    try {
      const topicList: UserTopic[] = [];
      for (let i = 0; i < followIds.length; i++) {
        const userTopic = new UserTopic();
        userTopic.setId(followIds[i] + '' + userId);
        userTopic.setUser_id(userId);
        userTopic.setTopic_id(followIds[i]);
        topicList.push(userTopic);
      }
      return await this.colUserTopic.upsert(topicList);
    } catch (error) {
      this.logger.error(`[topic-modify] insertTopic error: ${error}`);
      return -1;
    }
  }
}