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
import { ListResp } from './model/ListResp';
import { resource as Resource } from './model/resource';
import { ResourceResp } from './model/ResourceResp';
import { topic as Topic } from './model/topic';
import { topic_resource as TopicResource } from './model/topic_resource';
import { user_topic as UserTopic } from './model/user_topic';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colResource: CloudDBCollection<Resource>;
  colTopic: CloudDBCollection<Topic>;
  colTopicResource: CloudDBCollection<TopicResource>;
  colUserTopic: CloudDBCollection<UserTopic>;

  constructor(logger) {
    this.logger = logger;
    this.colResource = cloud.database({ zoneName: ZONE_NAME }).collection(Resource);
    this.colTopic = cloud.database({ zoneName: ZONE_NAME }).collection(Topic);
    this.colTopicResource = cloud.database({ zoneName: ZONE_NAME }).collection(TopicResource);
    this.colUserTopic = cloud.database({ zoneName: ZONE_NAME }).collection(UserTopic);
  }

  async queryResource(userId: string, type: string, pageNum: number, pageSize: number): Promise<ListResp> {
    try {
      const topics: Topic[] = await this.queryTopic();
      return await this.queryResourceList(userId, type, pageNum, pageSize, topics);
    } catch (error) {
      this.logger.error(`[resource-list] queryResource error: ${error}`);
    }
  }

  async queryTopic(): Promise<Topic[]> {
    const cloudDBZoneQuery: CloudDBZoneQuery<Topic> = this.colTopic.query();
    return await cloudDBZoneQuery.get();
  }

  async queryResourceList(userId: string, type: string, pageNum: number, pageSize: number,
    topics: Topic[]): Promise<ListResp> {
    let totalCount = 0;
    try {
      const resourceQuery: CloudDBZoneQuery<Resource> = this.colResource.query().equalTo('type', type);
      // If the user passes the userId, the system queries the resource data under the topic that the user is interested in.
      if (userId) {
        const followedTopicIds: string[] = await this.queryFollowedTopicIds(userId);
        const resourceIds: string[] = await this.queryFollowedTopicResourceIds(followedTopicIds, type);
        totalCount = resourceIds.length;
        resourceQuery.in('id', resourceIds);
        resourceQuery.limit(pageSize, (pageNum - 1) * pageSize);
      } else { // No Querying the resource list
        totalCount = await resourceQuery.countQuery('id');
        resourceQuery.limit(pageSize, (pageNum - 1) * pageSize);
      }
      const resList: ResourceResp[] = [];
      if (pageNum <= Math.ceil(totalCount / pageSize)) {
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
      }
      return new ListResp(pageNum, pageSize, Math.ceil(totalCount / pageSize), totalCount,
        totalCount > pageNum * pageSize, resList);
    } catch (error) {
      this.logger.error(`[resource-list] queryResource error: ${error}`);
    }
  }

  async queryFollowedTopicIds(userId: string): Promise<string[]> {
    const topicQuery: CloudDBZoneQuery<UserTopic> = this.colUserTopic.query().equalTo('user_id', userId);
    const topicData: UserTopic[] = await topicQuery.get();
    const followedTopicIds: string[] = [];
    for (let i = 0; i < topicData.length; i++) {
      followedTopicIds.push(topicData[i].getTopic_id());
    }
    return followedTopicIds;
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

  async queryFollowedTopicResourceIds(topicIds: string[], type: string): Promise<string[]> {
    const resourceIds: string[] = [];
    try {
      const topicResourceQuery: CloudDBZoneQuery<TopicResource> = this.colTopicResource.query();
      if (topicIds.length > 0) {
        topicResourceQuery.in('topic_id', topicIds);
      }
      topicResourceQuery.equalTo('type', type);
      const topicResourceRespData: TopicResource[] = await topicResourceQuery.get();
      for (let index = 0; index < topicResourceRespData.length; index++) {
        const element: TopicResource = topicResourceRespData[index];
        if (!resourceIds.includes(element.getResource_id())) {
          resourceIds.push(element.getResource_id());
        }
      }
      return resourceIds;
    } catch (error) {
      this.logger.error(`[resource-list] queryFollowedTopicResourceIds error: ${error}`);
    }
  }
}