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
* FAQ: 在系统设置修改了应用权限，应用能否监听到权限的变化
 */

// [Start monitor_changes_in_permissions]
import { abilityAccessCtrl, Permissions } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let permissionList: Array<Permissions> = ['ohos.permission.APPROXIMATELY_LOCATION'];
    try {
      atManager.on('selfPermissionStateChange', permissionList, (data: abilityAccessCtrl.PermissionStateChangeInfo) => {
        console.info('receive permission state change, data:' + JSON.stringify(data));
      });
    } catch (err) {
      console.error(`catch err->${JSON.stringify(err)}`);
    }
  }

  build() {
    // ...
  }
}
// [End monitor_changes_in_permissions]