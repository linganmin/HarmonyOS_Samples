/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { wantAgent } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const REQUEST_CODE: number = 0

class WantAgentUtil {
  /**
   * create wantAgent for start ability
   *
   * @param bundleName
   * @param abilityName
   * @return return the created WantAgent object.
   */
  async createWantAgentForStartAbility(bundleName: string, abilityName: string) {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: bundleName,
          abilityName: abilityName
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: REQUEST_CODE
    }
    try {
      let tmpWantAgent = await wantAgent.getWantAgent(wantAgentInfo);
      return tmpWantAgent;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'WantAgentUtil', `Failed to get wantAgent: code=${err.code}, message=${err.message}`);
      throw error as Error;
    }
  }

  /**
   * create wantAgent for common event
   *
   * @param mAction
   * @return return the created WantAgent object.
   */
  async createWantAgentForCommonEvent(action: string) {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{ action: action }],
      actionType: wantAgent.OperationType.SEND_COMMON_EVENT,
      requestCode: REQUEST_CODE
    }
    try {
      let tmpWantAgent = await wantAgent.getWantAgent(wantAgentInfo);
      return tmpWantAgent;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'WantAgentUtil', `Failed to get wantAgent: %{public}s`, err.message);
      throw error as Error;
    }
  }
}

export let wantAgentUtil = new WantAgentUtil();