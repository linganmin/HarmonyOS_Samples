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
* FAQ:如何解决文件的中文乱码问题
*/

// [Start HandleFileEncodingProblem]
import { util } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';

// In the utility class, retrieve the Context from the Entry Ability and save it to AppStore, then use AppStore to retrieve it in the utility class
let context = AppStorage.get("context") as UIContext;
// Create a file to write Chinese characters
let filePath = context.getHostContext()!.filesDir + "/test0.txt";
let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
// Write a paragraph of content to a file
let writeLen = fileIo.writeSync(file.fd, "Hello, world");
fileIo.closeSync(file);
console.info(`GarbledCnCharacters The length of str is: ${writeLen}`);
let stream = fileIo.createStreamSync(filePath, "r+");
let buffer = new ArrayBuffer(4096);
stream.readSync(buffer);
// Set the encoding format to "utf-8"
let textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
// Retrieve the corresponding text after decoding the input
let readString = textDecoder.decodeToString(new Uint8Array(buffer), { stream: false });
console.info(`GarbledCnCharacters read content is:${readString}`);
// [End HandleFileEncodingProblem]