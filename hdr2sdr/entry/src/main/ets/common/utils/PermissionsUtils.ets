/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
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

import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const context = (AppStorage.get('uiContext') as UIContext).getHostContext() as common.UIAbilityContext;
const TAG = '[permissions]'
const permissions: Array<Permissions> = [
  'ohos.permission.MICROPHONE',
  'ohos.permission.CAMERA',
  'ohos.permission.WRITE_MEDIA'
];

export function PermissionsFromUser(): void {
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  atManager.requestPermissionsFromUser(context, permissions).then((data) => {
    let grantStatus: Array<number> = data.authResults;
    let length: number = grantStatus.length;
    for (let i = 0; i < length; i++) {
      if (grantStatus[i] === 0) {
        hilog.info(0x0000, TAG, 'User authorized.');
      } else {
        hilog.info(0x0000, TAG, 'User denied authorization.');
        return;
      }
    }
  }).catch((err: BusinessError) => {
    hilog.error(0x0000, TAG, `Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
  })
}