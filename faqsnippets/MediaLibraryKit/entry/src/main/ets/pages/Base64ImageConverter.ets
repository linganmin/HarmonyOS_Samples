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
* FAQ:base64字符串如何转为图片并保存
*/

// [Start Base64ImageConverter]
import { buffer } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { fileUri } from "@kit.CoreFileKit";
import { hilog } from '@kit.PerformanceAnalysisKit';

// In the utility class, retrieve the Context from the Entry Ability and save it to AppStore, then use AppStore to retrieve it in the utility class
let context = AppStorage.get("context") as UIContext;
let filesDir = context.getHostContext()!.filesDir;

// Data is the base64 string that needs to be converted, and returns the sandbox path URI
export async function writeFile(data: string): Promise<string> {
  let uri = ''
  try {
    let filePath = filesDir + "/1.png";
    uri = fileUri.getUriFromPath(filePath);
    let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    console.info("file fd: " + file.fd);
    const reg = new RegExp("data:image/\\w+;base64,")
    const base64 = data.replace(reg, "");
    console.log("base64flag", base64)
    const dataBuffer = buffer.from(base64, 'base64')
    let writeLen = fileIo.writeSync(file.fd, dataBuffer.buffer);
    hilog.info(0xA0c0d0,'uri',uri)
    fileIo.closeSync(file);
  }
  catch (Error) {
    hilog.error(0xA0c0d0,'Error',Error.code)
  }
  return uri;
}
// [End Base64ImageConverter]