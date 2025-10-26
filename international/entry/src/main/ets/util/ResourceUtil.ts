/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
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

import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

class ResourceUtil {
  async getString(id: number, context: common.Context): Promise<string> {
    let rscManager = context.resourceManager;
    let str: string = '';
    try {
      str = rscManager.getStringSync(id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'ResourceUtil', `getStringSync failed, error code=${err.code}, message=${err.message}`);
    }
    return str;
  }

  async getStringArray(id: number, context: common.Context): Promise<Array<string>> {
    let rscManager = context.resourceManager;
    let strArray: Array<string> = [];
    try {
      strArray = rscManager.getStringArrayValueSync(id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'ResourceUtil',
        `getStringArrayValueSync failed, error code=${err.code}, message=${err.message}`);
    }
    return strArray;
  }

  async getPluralString(id: number, num: number, context: common.Context): Promise<string> {
    let rscManager = context.resourceManager;
    let plural: string = '';
    try {
      plural = rscManager.getIntPluralStringValueSync(id, num);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'ResourceUtil',
        `getIntPluralStringValueSync failed, error code=${err.code}, message=${err.message}`);
    }
    return plural;
  }

  async getDirection(context: common.Context): Promise<string> {
    let rscManager = context.resourceManager;
    let configuration = await rscManager.getConfiguration();
    if (configuration.direction === 1) { // 1 is Horizontal，0 is Vertical
      return 'Horizontal';
    } else {
      return 'Vertical';
    }
  }
}

export default new ResourceUtil();