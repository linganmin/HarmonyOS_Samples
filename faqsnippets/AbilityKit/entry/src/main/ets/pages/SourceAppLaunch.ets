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
* FAQ:如何判断App的启动来源
*/

// [Start SourceAppLaunch1]
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  context = this.getUIContext();

  build() {
    Row() {
      Column() {
        Button('open app')
          .onClick(() => {
            let want: Want = {
              action: 'ohos.want.action.viewData',
              entities: ['entity.system.home']
            }
            let context = this.context.getHostContext() as common.UIAbilityContext;
            context.startAbility(want, (err: BusinessError) => {
              if (err.code) {
                // 处理业务逻辑错误
                hilog.error(0x0000, 'testTag', `startAbility failed, code is ${err.code}, message is ${err.message}`);
                return;
              }
              // 执行正常业务
              hilog.info(0x0000, 'testTag', 'startAbility succeed');
            });
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End SourceAppLaunch1]

