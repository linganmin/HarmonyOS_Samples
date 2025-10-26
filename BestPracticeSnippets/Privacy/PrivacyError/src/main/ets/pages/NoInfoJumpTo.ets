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
 * 场景五：建议隐式启动应用组件时避免携带个人数据错误示例
 */

// [Start want_info_error]
import { Want } from '@kit.AbilityKit';
// [StartExclude want_info_error]
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext!.getHostContext()!;
class NoInfo {
  private context = context as common.UIAbilityContext;

  wantNoInfo(): void {
    // [EndExclude want_info_error]
    let wantInfo:Want = {
      deviceId: '',
      action: 'ability.want.test',
      parameters: {
        'password': 'xxxxxxxx'
      }
    };
    try{
      let data = this.context.startAbility(wantInfo);
      hilog.info(0x0000, 'privacy', 'startAbility success ' + JSON.stringify(data));
    } catch (err) {
      hilog.error(0x0000, 'privacy', 'startAbility  with error message: ' + err.message + ', error code: ' + err.code);
    }
    // [End want_info_error]
  }
}
