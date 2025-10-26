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
* FAQ:在多模块工程中，如何获取har/hsp中的rawfile资源
*/

// [Start GetRawfile]
import { application, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { buffer } from '@kit.ArkTS';

@Entry
@Component
struct Index {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    Column() {
      Button('get rawFile content')
        .onClick(() => {
          application.createModuleContext(this.context, 'hsp')
            .then((data) => {
              let rawFileData = data.resourceManager.getRawFileContentSync('hsp.txt');
              let hspContent: string = buffer.from(rawFileData.buffer).toString();
            })
            .catch((error: BusinessError) => {
              console.error(`createModuleContext failed, error.code: ${error.code}, error.message: ${error.message}`);
            })
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}
// [End GetRawfile]