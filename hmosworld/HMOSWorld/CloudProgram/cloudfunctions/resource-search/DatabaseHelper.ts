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
import { topic_resource as TopicResource } from './model/topic_resource';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colResource: CloudDBCollection<Resource>;
  colTopic: CloudDBCollection<Topic>;
  colTopicResource: CloudDBCollection<TopicResource>;

  constructor(logger) {
    this.logger = logger;
    this.colResource = cloud.database({ zoneName: ZONE_NAME }).collection(Resource);
    this.colTopic = cloud.database({ zoneName: ZONE_NAME }).collection(Topic);
    this.colTopicResource = cloud.database({ zoneName: ZONE_NAME }).collection(TopicResource);
  }

  async queryResource(keyWords: string): Promise<ResourceResp[]> {
    try {
      const topics: Topic[] = await this.queryTopic();
      return await this.queryResourceList(keyWords, topics);
    } catch (error) {
      this.logger.error(`[resource-search] queryResource error: ${error}`);
    }
  }

  async queryResourceList(keyWords: string, topics: Topic[]): Promise<ResourceResp[]> {
    try {
      const resourceQuery1: CloudDBZoneQuery<Resource> =
        await this.colResource.query().contains("title", keyWords).orderByDesc("publish_date");
      const resourceQuery2: CloudDBZoneQuery<Resource> =
        await this.colResource.query().contains("brief", keyWords).orderByDesc("publish_date");
      const resourceData1: Resource[] = await resourceQuery1.get();
      const resourceData2: Resource[] = await resourceQuery2.get();
      let resourceData3: Resource[] = [];

      const topicIds: string[] = this.getTopicIdsByName(keyWords, topics);
      if (topicIds.length > 0) {
        let resourceIds: string[] = await this.queryFollowedTopicResourceIds(topicIds);
        const resourceQuery3: CloudDBZoneQuery<Resource> = await this.colResource.query().in('id', resourceIds);
        resourceData3 = await resourceQuery3.get();
      }

      if (resourceData1.length > 0 || resourceData2.length > 0 || resourceData3.length > 0) {
        const resourceData: Resource[] = { ...resourceData1, ...resourceData1, ...resourceData3 };
        const uniqueValues = new Set(Object.values(resourceData));
        const mergedAndUniqueArray: Resource[] = Array.from(uniqueValues);
        return this.getResourceList(mergedAndUniqueArray, topics);
      }
    } catch (error) {
      this.logger.error(`[resource-search] queryResourceList error: ${error}`);
    }
  }

  getResourceList(resourceData, topics): ResourceResp[] {
    const resList: ResourceResp[] = [];
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
    return resList;
  }

  async queryFollowedTopicResourceIds(topicIds: string[]): Promise<string[]> {
    try {
      const resourceIds: string[] = [];
      const topicResourceQuery: CloudDBZoneQuery<TopicResource> = this.colTopicResource.query();
      if (topicIds.length > 0) {
        topicResourceQuery.in('topic_id', topicIds);
      }
      const topicResourceRespData: TopicResource[] = await topicResourceQuery.get();
      for (let index = 0; index < topicResourceRespData.length; index++) {
        const element: TopicResource = topicResourceRespData[index];
        if (!resourceIds.includes(element.getResource_id())) {
          resourceIds.push(element.getResource_id());
        }
      }
      return resourceIds;
    } catch (error) {
      this.logger.error(`[resource-search] queryFollowedTopicResourceIds error: ${error}`);
    }
  }

  async queryTopic(): Promise<Topic[]> {
    const cloudDBZoneQuery: CloudDBZoneQuery<Topic> = this.colTopic.query();
    return await cloudDBZoneQuery.get();
  }

  getTopicIdsByName(topicName: string, topics: Topic[]): string[] {
    const topicIds: string[] = [];
    for (let index = 0; index < topics.length; index++) {
      const top: Topic = topics[index];
      const name: string = top.getName();
      if (name.includes(topicName)) {
        topicIds.push(top.getId());
      }
    }
    return topicIds;
  }

  getTopicNames(topics: Topic[], tidStr: string): string[] {
    const topicNames: string[] = [];
    const topicIds: string[] = tidStr.split(',');
    for (let index = 0; index < topicIds.length; index++) {
      const tid = topicIds[index];
      const name: Topic[] = topics.filter(tp => tp.getId() === tid);
      topicNames.push(name[0].getName());
    }
    return topicNames;
  }
}