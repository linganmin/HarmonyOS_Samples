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
* FAQ:通过resourceManager.getStringResource接口获取HSP资源文件报“Resource id invalid”错误
 */

// [Start error_in_obtaining_hsp_file]
import { common, application } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';

@Entry
@Component
struct Index {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    Column() {
      Button()
        .onClick(() => {
          // Create a context based on the module name
          let moduleName: string = 'library';
          application.createModuleContext(this.context, moduleName)
            .then((data: common.Context) => {
              console.info(`CreateModuleContext success, data: ${JSON.stringify(data)}`);
              if (data !== null) {
                this.getUIContext().getPromptAction().showToast({
                  message: ('get Context success')
                });
              }

              // Then run getStringByNameSync to obtain the string corresponding to the specified resource name
              try {
                let str = data.resourceManager.getStringByNameSync('shared_desc');
                console.info(`getStringByNameSync, data: ${JSON.stringify(str)}`);
              } catch (error) {
                let code = (error as BusinessError).code;
                let message = (error as BusinessError).message;
                console.error(`getStringByNameSync failed, error code: ${code}, message: ${message}.`);
              }
            })
            .catch((err: BusinessError) => {
              console.error(`CreateModuleContext failed, err code:${err.code}, err msg: ${err.message}`);
            });
        })
    }
  }
}
// [End error_in_obtaining_hsp_file]