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
* FAQ:如何读取rawfile中的xml文件并转化为String类型
*/

// [Start RawXmlFileToStringParser]
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';

// In the utility class, retrieve the Context from the Entry Ability and save it to AppStore, then use AppStore to retrieve it in the utility class
let context = AppStorage.get("context") as UIContext;

try {
  context.getHostContext()!.resourceManager.getRawFileContent('test.xml', (error, value) => {
    if (error != null) {
      console.log('error is ' + error);
    } else {
      let rawFile = value;
      let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM : true });
      let rawFileString = textDecoder.decodeToString( rawFile , {stream: false});
    }
  });
} catch (error) {
  let code = (error as BusinessError).code;
  let message = (error as BusinessError).message;
  console.error(`callback getRawFileContent failed, error code: ${code}, message: ${message}.`);
}
// [End RawXmlFileToStringParser]