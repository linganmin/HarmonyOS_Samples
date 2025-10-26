/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
 * 最佳实践：应用安全编码实践
 * 场景二十五：建议对跨信任边界传入的Want进行合法性判断-确保访问的对象属性存在
 */


// [Start check_want_one]
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIAbility, Want, AbilityConstant } from '@kit.AbilityKit';

// Check function
function checkWant(want: Want) {
  if (want === null || want.parameters === null
    || want === undefined || want.parameters === undefined) {
    return false;
  }
  return true;
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    if (checkWant(want)) {
      hilog.info(0x0000, 'privacy', 'invalid want');
    } else {
      hilog.info(0x0000, 'privacy', 'correct want');
    }
  }
}
// [End check_want_one]