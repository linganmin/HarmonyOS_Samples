/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import Logger from "./Logger";
import { BusinessError } from "@kit.BasicServicesKit";

let context = AppStorage.get('UIContext') as UIContext;

export class CommonUtils {
  showToast(message: string | Resource) {
    try {
      context.getPromptAction().showToast({
        message: message,
        duration: 1000
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error('showToast failed,code is' + ` ${err.code}, message is ${err.message}`);
    }
  }
}

let commonUtils = new CommonUtils();

export default commonUtils as CommonUtils;