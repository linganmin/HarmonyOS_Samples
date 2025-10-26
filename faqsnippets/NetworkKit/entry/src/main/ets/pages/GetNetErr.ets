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
* FAQ:无网络环境下使用同步方法获取网络状态报错
*/

// [Start GetNetErr]
import { connection } from '@kit.NetworkKit'
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct GetErrInfo {
  getErrInfo() {
    try {
      let netHandle = connection.getDefaultNetSync();
      let connectionproperties = connection.getConnectionPropertiesSync(netHandle);
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.log('error: ' + JSON.stringify(error));
    }
  }

  build() {
    Row() {
      Column() {
        Button('获取网络类型')
          .onClick(() => {
            this.getErrInfo();

          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End GetNetErr]

