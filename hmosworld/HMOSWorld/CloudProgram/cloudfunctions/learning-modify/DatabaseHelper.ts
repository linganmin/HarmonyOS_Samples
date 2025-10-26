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

import { cloud, CloudDBCollection} from '@hw-agconnect/cloud-server';
import { user_learning as UserLearning } from './model/user_learning';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colUserLearning: CloudDBCollection<UserLearning>;

  constructor(logger) {
    this.logger = logger;
    this.colUserLearning = cloud.database({zoneName: ZONE_NAME}).collection(UserLearning);
  }

  async insertUserLearning(userId: string, pathId: string): Promise<number> {
    try {
      const userLearningObj: UserLearning = new UserLearning();
      userLearningObj.setPath_id(pathId);
      userLearningObj.setUser_id(userId);
      userLearningObj.setLearned_time(new Date());
      userLearningObj.setId(userId + pathId);
      return await this.colUserLearning.upsert(userLearningObj);
    }
    catch (error) {
      this.logger.error(`[learning-modify] insertUserLearning error: ${error}`);
      return -1;
    }
  }
}