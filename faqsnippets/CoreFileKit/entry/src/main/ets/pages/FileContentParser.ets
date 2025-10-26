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
* FAQ:如何读取指定文件内容，并转为具体对象
*/

// [Start FileContentParser]
import { Context } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';

@Entry
@Component
struct Index {
  private context: Context | undefined = this.getUIContext().getHostContext();
  private str: string = '';

  getRawFile(): ESObject {
    //Call the getRawFileContent interface to retrieve the content of a JSON file and read it as a string
    this.getUIContext().getHostContext()!.resourceManager.getRawFileContent('test.json', (err, data) => {
      try {
        this.str = buffer.from(data.buffer).toString();
        console.info(JSON.stringify(this.str));
      } catch (e) {
        console.info(JSON.stringify(e));
      }
    })
    //You can also call the getRawFileContentSync interface to retrieve the content of the JSON file and read it as a string
    try {
      let data: Uint8Array = this.context!.resourceManager.getRawFileContentSync('test.json');
      this.str = buffer.from(data.buffer).toString();
    } catch (e) {
      console.info(JSON.stringify(e));
    }
    // Convert string to ESObject
    let obj: ESObject = JSON.parse(this.str);
    console.info('ESObject', JSON.stringify(obj));
    return obj;
  }

  build() {
    Column() {
      Button('get')
        .onClick(() => {
          this.getRawFile();
        })
    }.width('100%')
  }
}
// [End FileContentParser]