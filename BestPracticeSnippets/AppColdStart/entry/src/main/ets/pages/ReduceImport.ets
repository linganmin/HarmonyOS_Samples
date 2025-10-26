/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
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

// [Start reduce_import]
// Optimize modules that reduce import
/*import { ConfigurationConstant, contextConstant, wantConstant } from '@kit.AbilityKit';
import { GesturePath, GesturePoint } from '@kit.AccessibilityKit';
import { distributedAccount, osAccount } from '@kit.BasicServicesKit';
import { Configuration } from '@kit.ArkUI';
import { atomicService } from '@kit.ScenarioFusionKit';
import { sim } from '@kit.TelephonyKit';*/


import { UIAbility } from '@kit.AbilityKit';


export default class EntryAbility extends UIAbility {
  // ...
}
// [End reduce_import]