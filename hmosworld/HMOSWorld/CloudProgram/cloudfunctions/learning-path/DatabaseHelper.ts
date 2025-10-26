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
import { learning_path as LearningPath} from './model/learning_path';
import { LearningPathResp } from './model/LearningPathResp.js';
import { user_learning as UserLearning} from './model/user_learning.js';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colLearningPath: CloudDBCollection<LearningPath>;
  colUserLearning: CloudDBCollection<UserLearning>;

  constructor(logger) {
    this.logger = logger;
    this.colLearningPath = cloud.database({zoneName: ZONE_NAME}).collection(LearningPath);
    this.colUserLearning = cloud.database({zoneName: ZONE_NAME}).collection(UserLearning);
  }

  async queryLearningPath(userId: string): Promise<LearningPathResp[]> {
    const pathList: LearningPathResp[] = [];
    try {
      const pathQuery: CloudDBZoneQuery<LearningPath> = this.colLearningPath.query().orderByAsc('id');
      const pathData: LearningPath[] = await pathQuery.get();
      if (pathData.length > 0) {
        let learnedPathIds: string[] = [];
        if (userId) {
          learnedPathIds = await this.queryLearnedPathIds(userId);
        }
        for (let i = 0; i < pathData.length; i++) {
          const dataQ: LearningPath = pathData[i];
          pathList.push(new LearningPathResp(
            dataQ.getId(),
            dataQ.getTag(),
            dataQ.getTitle(),
            dataQ.getZone(),
            dataQ.getUrl(),
            dataQ.getBrief(),
            learnedPathIds.indexOf(dataQ.getId()) !== -1,
          ));
        }
      }
      return pathList;
    } catch (error) {
      this.logger.error(`[learning-path] queryLearningPath error: ${error}`);
    }
  }

  async queryLearnedPathIds(userId): Promise<string[]> {
    const learnedPathIds: string[] = [];
    try {
      const userLearningQuery: CloudDBZoneQuery<UserLearning> = this.colUserLearning.query().equalTo('user_id', userId);
      const userLearningData: UserLearning[] = await userLearningQuery.get();
      for (let index = 0; index < userLearningData.length; index++) {
        const element: UserLearning = userLearningData[index];
        learnedPathIds.push(element.getPath_id());
      }
      return learnedPathIds;
    } catch (error) {
      this.logger.error(`[learning-path] queryLearnedPathIds error: ${error}`);
    }
  }
}
