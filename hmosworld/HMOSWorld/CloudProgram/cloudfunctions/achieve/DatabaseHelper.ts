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
import { AchieveResp } from './model/AchieveResp';
import { learning_path as LearningPath } from './model/learning_path';
import { user_learning as UserLearning } from './model/user_learning';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colLearningPath: CloudDBCollection<LearningPath>;
  colUserLearning: CloudDBCollection<UserLearning>;

  constructor(logger) {
    this.logger = logger;
    this.colLearningPath = cloud.database({ zoneName: ZONE_NAME }).collection(LearningPath);
    this.colUserLearning = cloud.database({ zoneName: ZONE_NAME }).collection(UserLearning);
  }

  async getLitAchieves(userId: string): Promise<AchieveResp[]> {
    const pathList: AchieveResp[] = [];
    try {
      const learningPathQuery: CloudDBZoneQuery<LearningPath> = this.colLearningPath.query().orderByAsc("id");
      const learningPathData: LearningPath[] = await learningPathQuery.get();
      this.logger.info(`[achieve] query learning path success. pathData=> ${learningPathData.length}`);
      if (learningPathData.length <= 0) {
        return pathList;
      }
      const learnedPaths: UserLearning[] = await this.queryLearnedPaths(userId);
      for (let i = 0; i < learningPathData.length; i++) {
        let learningPath: LearningPath = learningPathData[i];
        let top: UserLearning[] = learnedPaths.filter(tp => tp.getPath_id() === learningPath.getId());
        if (top.length > 0) {
          pathList.push(new AchieveResp(learningPath.getId(), true, top[0].getLearned_time()));
        } else {
          pathList.push(new AchieveResp(learningPath.getId(), false, null));
        }
      }
      return pathList;
    } catch (error) {
      this.logger.error(`[achieve] query learn path error: ${error}`);
    }
  }

  async queryLearnedPaths(userId: string): Promise<UserLearning[]> {
    const learnedPaths: UserLearning[] = [];
    try {
      const userLearningQuery: CloudDBZoneQuery<UserLearning> = this.colUserLearning.query().equalTo('user_id', userId);
      const userLearningData: UserLearning[] = await userLearningQuery.get();
      this.logger.info(`[achieve] query user_learning success`);
      this.logger.info(`[achieve] userLearningData=> ${userLearningData.length}`);
      for (let index = 0; index < userLearningData.length; index++) {
        let element: UserLearning = userLearningData[index];
        learnedPaths.push(element);
      }
      return learnedPaths;
    } catch (error) {
      this.logger.error(`[achieve] query learnedPathIds error: ${error}`);
    }
  }
}