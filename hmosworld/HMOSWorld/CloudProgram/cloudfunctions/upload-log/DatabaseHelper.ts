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
import { aspect_info as AspectInfo } from './model/aspect_info';

const ZONE_NAME = 'HMOSWorld';

export class DatabaseHelper {
  logger;
  colAspectInfo: CloudDBCollection<AspectInfo>;

  constructor(logger) {
    this.logger = logger;
    this.colAspectInfo = cloud.database({zoneName: ZONE_NAME}).collection(AspectInfo);
  }

  async insertAspectInfo(versionName: string, methodClassName: string, methodName: string,
    time: string, isStatic: boolean, params: string, type: string): Promise<number> {
    try {
      const aspectInfo = new AspectInfo();
      aspectInfo.setVersionName(versionName);
      aspectInfo.setMethodClassName(methodClassName);
      aspectInfo.setMethodName(methodName);
      aspectInfo.setTime(time);
      aspectInfo.setIsStatic(isStatic);
      aspectInfo.setParams(params);
      aspectInfo.setType(type);
      aspectInfo.setCreateTime(new Date());
      return await this.colAspectInfo.upsert(aspectInfo);
    } catch (error) {
      this.logger.error(`[upload-log] insert aspect info failed: ${error}`);
      return -1;
    }
  }
}