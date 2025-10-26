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
* FAQ:如何获取状态管理框架代理前的原始对象
*/

// [Start obtain_state_management_framework]
import { UIUtils } from '@kit.ArkUI';

@Observed
class UserInfo {
  name: string = 'Tom';
}

@Entry
@Component
struct GetTargetDemo {
  @State info: UserInfo = new UserInfo();

  build() {
    Column() {
      Text(`info.name: ${this.info.name}`)
      Button('Change the properties of the proxy object')
        .onClick(() => {
          this.info.name = 'Alice'; // The Text component can refresh
        })
      Button('更改原始对象的属性')
        .onClick(() => {
          let rawInfo: UserInfo = UIUtils.getTarget(this.info);
          if (rawInfo) {
            rawInfo.name = 'Bob'; // The Text component cannot be refreshed
          }
        })
    }
  }
}

// [End obtain_state_management_framework]