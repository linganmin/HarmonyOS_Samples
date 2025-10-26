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
* FAQ:如何在Page中获取WindowStage实例
*/

// [Start get_window_stage_instance_in_page]
// Index.ets
import common from '@ohos.app.ability.common';

@Entry
@Component
struct Index {
  @State showAbility: string = 'get windowStage'

  build() {
    Row() {
      Column() {
        Text(this.showAbility)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
            console.info('Obtained WindowStage instance:',JSON.stringify(context.windowStage))
          });
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End get_window_stage_instance_in_page]