/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

/*
* FAQ:如何通过resourceManager获取rawFile路径下的文件
 */

// [Start get_raw]
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

// Passing in '' indicates obtaining a list of files in the root directory of rawfile
try {
  let context = AppStorage.get("context") as UIContext;
  context.getHostContext()!.resourceManager.getRawFileList('', (error: BusinessError, value: Array<string>) => {
    if (error != null) {
      console.error(`callback getRawFileList failed, error code: ${error.code}, message: ${error.message}.`);
    } else {
      let rawFile = value;
    }
  });
} catch (error) {
  let code = (error as BusinessError).code;
  let message = (error as BusinessError).message;
  console.error(`callback getRawFileList failed, error code: ${code}, message: ${message}.`);
}
// [End get_raw]