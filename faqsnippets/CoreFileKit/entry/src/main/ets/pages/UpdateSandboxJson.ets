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
* FAQ:如何修改沙箱路径下json文件的指定内容
*/

// [Start UpdateSandboxJson]
import { fileIo } from '@kit.CoreFileKit';

// In the utility class, retrieve the Context from the Entry Ability and save it to AppStore, then use AppStore to retrieve it in the utility class
let context = AppStorage.get("context") as UIContext;
let filePath = context.getHostContext()!.filesDir + '/people.json';

class Student {
  name: string = 'zhangsan';
  age: number = 10;
}

let student = new Student();
// 1 Create a file and write its contents
let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
fileIo.writeSync(file.fd, JSON.stringify(student))
fileIo.close(file);
// 2 Read the contents of the JSON file through fileIo.readSync.
let data = fileIo.readTextSync(filePath);
let obj: Student = JSON.parse(data);
// 3 Change the specified content name to lisi
obj.name = 'lisi';
// 4 Rewrite JSON file
let fileModify = fileIo.openSync(filePath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC);
fileIo.writeSync(fileModify.fd, JSON.stringify(obj));
fileIo.close(fileModify);
// 5 Read the latest content
let content = fileIo.readTextSync(filePath);
console.info(`ModifySanFileContent content is :${content}`);
// [End UpdateSandboxJson]