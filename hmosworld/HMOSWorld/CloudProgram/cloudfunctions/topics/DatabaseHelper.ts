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
import { topic as Topic} from './model/topic';
import { TopicResponse } from './model/TopicResponse';
import { user_topic as UserTopic} from './model/user_topic';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colTopic: CloudDBCollection<Topic>;
  colUserTopic: CloudDBCollection<UserTopic>;

  constructor(logger) {
    this.logger = logger;
    this.colTopic = cloud.database({zoneName: ZONE_NAME}).collection(Topic);
    this.colUserTopic = cloud.database({zoneName: ZONE_NAME}).collection(UserTopic);
  }

  async queryTopics(userId: string): Promise<TopicResponse[]> {
    const userTopicsIds: string[] = [];
    const userTopicQuery: CloudDBZoneQuery<UserTopic> = this.colUserTopic.query().equalTo("user_id",userId);
    const userTopics: UserTopic[] = await userTopicQuery.get();
    if (userTopics.length > 0) {
      for (let i = 0; i < userTopics.length; i++) {
        userTopicsIds.push(userTopics[i].getTopic_id());
      }
    }

    const cloudDBZoneQuery: CloudDBZoneQuery<Topic> = this.colTopic.query();
    const topicData: Topic[] = await cloudDBZoneQuery.get();
    const responseList: TopicResponse[] = [];
    if (topicData.length > 0) {
      for (let i = 0; i < topicData.length; i++) {
        const topic: Topic = topicData[i];
        const flag: boolean = userTopicsIds.indexOf(topic.getId())!==-1 ? true : false;
        responseList.push(new TopicResponse(topic.getId(), topic.getName(), topic.getType(), topic.getIcon(), flag));
      }
    }
    return responseList;
  }
}