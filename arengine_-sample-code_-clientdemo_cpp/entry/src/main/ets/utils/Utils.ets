/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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

import { abilityAccessCtrl } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

export async function requestPermissionOnSetting(context: Context): Promise<boolean> {
  let requestResult: boolean = false;
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  await atManager.requestPermissionOnSetting(context, ['ohos.permission.CAMERA'])
    .then((data: Array<abilityAccessCtrl.GrantStatus>) => {
      Logger.info('data:' + JSON.stringify(data));
      if (data[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        requestResult = true;
      }
    })
    .catch((err: BusinessError) => {
      Logger.error('data:' + JSON.stringify(err));
    })
  return requestResult;
}
