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
/**
 * FAQ: 如何在Native侧跨模块访问资源
 */
// [Start native_cross_module_access_res_ets]
import { application } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import testNapi from 'libnativecrossmoduleaccessres.so';

@Entry
@Component
struct Index {
  @State message: string = 'Native Cross Module Access Resource';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            application.createModuleContext(this.getUIContext().getHostContext(), 'NativeAccessRes')
              .then((data: Context) => {
                if (data) {
                  let rawfileContext: Uint8Array = testNapi.getRawFileContent(data.resourceManager, 'rawfile.txt');
                  console.log("rawfileContext" + rawfileContext);
                }
              })
              .catch((error: BusinessError) => {
                let code: number = (error as BusinessError).code;
                let message: string = (error as BusinessError).message;
                console.error(`createModuleContext failed, error.code: ${code}, error.message: ${message}`);
              })
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}

// [End native_cross_module_access_res_ets]