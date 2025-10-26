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
import { collect as Collect } from './model/collect';
import { resource as Resource } from './model/resource';
import { ResourceResp } from './model/ResourceResp';
import { topic as Topic } from './model/topic';
import { user_history as UserHistory } from './model/user_history';
import { user_like as UserLike } from './model/user_like';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colCollect: CloudDBCollection<Collect>;
  colResource: CloudDBCollection<Resource>;
  colUserLike: CloudDBCollection<UserLike>;
  colUserHistory: CloudDBCollection<UserHistory>;
  colTopic: CloudDBCollection<Topic>;

  constructor(logger) {
    this.logger = logger;
    this.colCollect = cloud.database({ zoneName: ZONE_NAME }).collection(Collect);
    this.colResource = cloud.database({ zoneName: ZONE_NAME }).collection(Resource);
    this.colTopic = cloud.database({ zoneName: ZONE_NAME }).collection(Topic);
    this.colUserHistory = cloud.database({ zoneName: ZONE_NAME }).collection(UserHistory);
    this.colUserLike = cloud.database({ zoneName: ZONE_NAME }).collection(UserLike);
  }

  async queryResource(userId: string): Promise<ResourceResp[]> {
    const resList: ResourceResp[] = [];
    try {
      // Query the user's historical browsing data.
      const historyQuery: CloudDBZoneQuery<UserHistory> =
        this.colUserHistory.query().orderByDesc("browse_time").equalTo('user_id', userId);
      const historyData: UserHistory[] = await historyQuery.get();
      if (historyData.length <= 0) {
        return resList;
      }

      const historyIds: string[] = [];
      for (let i = 0; i < historyData.length; i++) {
        const historyItem: UserHistory = historyData[i];
        historyIds.push(historyItem.getResource_id());
      }

      // Obtain resource information based on the query of historical data.
      const resourceQuery: CloudDBZoneQuery<Resource> = this.colResource.query().in("id", historyIds);
      const resourceData: Resource[] = await resourceQuery.get();
      if (resourceData.length <= 0) {
        return resList;
      }

      const likedIds: string[] = await this.queryLikedIds(userId);
      const collectedIds: string[] = await this.queryCollectedIds(userId);

      resourceData.sort(function (a, b) {
        return historyIds.indexOf(a.getId()) - historyIds.indexOf(b.getId());
      });
      let topics: Topic[] = await this.queryTopic();
      for (let i = 0; i < resourceData.length; i++) {
        const dataQ = resourceData[i];
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
          likedIds.indexOf(dataQ.getId()) !== -1, // isLiked
          collectedIds.indexOf(dataQ.getId()) !== -1, // isCollected
          false
        ));
      }
      return resList;
    } catch (error) {
      this.logger.error(`[history] query resource error : ${error}`);
    }
  }

  async queryLikedIds(userId: string): Promise<string[]> {
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
      this.logger.error(`[history] queryLikedIds error : ${error}`);
    }
  }

  async queryCollectedIds(userId: string): Promise<string[]> {
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
      this.logger.error(`[history] queryCollectedIds error : ${error}`);
    }
  }

  async queryTopic(): Promise<Topic[]> {
    const cloudDBZoneQuery: CloudDBZoneQuery<Topic> = this.colTopic.query();
    const listData: Topic[] = await cloudDBZoneQuery.get();
    return listData;
  }

  getTopicNames(topics: Topic[], tidStr: string): string[] {
    const topicNames: string[] = [];
    const topicIds: string[] = tidStr.split(',');
    for (let index = 0; index < topicIds.length; index++) {
      const tid = topicIds[index];
      const tp: Topic[] = topics.filter(tp => tp.getId() === tid);
      topicNames.push(tp[0].getName());
    }
    return topicNames;
  }
}