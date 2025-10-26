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
* FAQ:UIAbility和UIExtensionAbility有什么区别？分别推荐在什么场景使用
 */

// [Start ui_ext_ability]
import { UIExtensionAbility, AbilityConstant } from '@kit.AbilityKit';

export default class UIExtAbility extends UIExtensionAbility {
  onCreate(launchParam: AbilityConstant.LaunchParam) {
    console.log(`onCreate, launchParam: ${JSON.stringify(launchParam)}`);
  }
}
// [End ui_ext_ability]