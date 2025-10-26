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
import { resource as Resource } from './model/resource';
import { ResourceResp } from './model/ResourceResp';
import { topic as Topic } from './model/topic';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colResource: CloudDBCollection<Resource>;
  colTopic: CloudDBCollection<Topic>;

  constructor(logger) {
    this.logger = logger;
    this.colResource = cloud.database({ zoneName: ZONE_NAME }).collection(Resource);
    this.colTopic = cloud.database({ zoneName: ZONE_NAME }).collection(Topic);
  }

  async queryHotResource(): Promise<ResourceResp[]> {
    try {
      const topics: Topic[] = await this.queryTopic();
      const resList: ResourceResp[] = await this.queryResourceList(topics);
      return resList;
    } catch (error) {
      this.logger.error(`[resource-hot] queryHotResource error: ${error}`);
    }
  }

  async queryResourceList(topics: Topic[]): Promise<ResourceResp[]> {
    const resList: ResourceResp[] = [];
    try {
      // Retrieve the top 10 pieces of resource data based on their page views.
      const resourceQuery: CloudDBZoneQuery<Resource> = this.colResource.query().orderByDesc("views_count").limit(10);
      const resourceData: Resource[] = await resourceQuery.get();
      if (resourceData.length > 0) {
        for (let i = 0; i < resourceData.length; i++) {
          const dataQ: Resource = resourceData[i];
          resList.push(new ResourceResp(
            dataQ.getId(),
            dataQ.getTitle(),
            dataQ.getBrief(),
            dataQ.getHeader_src(),
            dataQ.getType(),
            dataQ.getWeb_url(),
            dataQ.getPublish_date(),
            this.getTopicNames(topics, dataQ.getTopics()),
            dataQ.getViews_count(),
            dataQ.getCollect_count(),
            dataQ.getLikes_count(),
            dataQ.getTag(),
            dataQ.getBanner_src(),
            dataQ.getMedia_src(),
            null, // isLiked
            null, // isCollected
            null// isViewed
          ));
        }
      }
      return resList;
    } catch (error) {
      this.logger.error(`[resource-hot] queryResourceList error: ${error}`);
    }
  }

  async queryTopic(): Promise<Topic[]> {
    const cloudDBZoneQuery: CloudDBZoneQuery<Topic> = this.colTopic.query();
    return await cloudDBZoneQuery.get();
  }

  getTopicNames(topics: Topic[], tidStr: string): string[] {
    const topicNames: string[] = [];
    const topicIds: string[] = tidStr.split(',');
    for (let index = 0; index < topicIds.length; index++) {
      const tid: string = topicIds[index];
      const name: Topic[] = topics.filter(tp => tp.getId() === tid);
      topicNames.push(name[0].getName());
    }
    return topicNames;
  }
}