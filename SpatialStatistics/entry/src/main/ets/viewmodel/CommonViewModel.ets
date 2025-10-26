/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Logger from '../utils/Logger';

/**
 * public method.
 */
export class CommonViewModel {
  /**
   * The Resource type is converted to a string type.
   */
  getResourceString(context: Context,resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = context.resourceManager.getStringSync(resource.id);
    } catch (error) {
      Logger.error(`getResourceString err: ${JSON.stringify(error)}`);
    }
    return resourceString;
  }
}

export default new CommonViewModel();