/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { BusinessError } from '@kit.BasicServicesKit';
import { window } from "@kit.ArkUI";
import { common } from "@kit.AbilityKit";
import Logger from '../common/Logger';

const TAG = 'GetWindowStageDemo';

@Builder
export function GetWindowStageBuilder() {
  GetWindowStageDemo()
}

@Component
export struct GetWindowStageDemo {
  @StorageLink('windowStageFromUIAbility') windowStageFromUIAbility: window.WindowStage | undefined = undefined;
  @State result: ResourceStr = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    NavDestination() {
      Column() {
        TextArea({ text: this.result })
          .width('100%')
          .height(168)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .focusOnTouch(false)

        Column({ space: 12 }) {
          Button($r('app.string.get_WindowStage_in_UIAbility'))
            .width('100%')
            .onClick(() => {
              try {
                let windowRect = this.windowStageFromUIAbility?.getMainWindowSync().getWindowProperties().windowRect;
                this.result = $r('app.string.get_window_height_width_1', windowRect?.width, windowRect?.height);
              } catch (err) {
                let error = err as BusinessError;
                Logger.error(TAG, `getMainWindowSync err, code: ${error.code}, mesage: ${error.message}`);
              }
            })

          Button($r('app.string.get_WindowStage_by_UIAbilityContext'))
            .width('100%')
            .onClick(() => {
              try {
                let windowStageFromUIAbilityContext = this.context.windowStage;
                let windowRect = windowStageFromUIAbilityContext.getMainWindowSync().getWindowProperties().windowRect;
                this.result = $r('app.string.get_window_height_width_2', windowRect?.width, windowRect?.height);
              } catch (err) {
                let error = err as BusinessError;
                Logger.error(TAG, `getMainWindowSync err, code: ${error.code}, mesage: ${error.message}`);
              }
            })
        }
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_secondary'))
      .height('100%')
      .width('100%')
      .padding(16)
    }
    .title($r('app.string.get_window_stage'))
    .backgroundColor($r('sys.color.background_secondary'))
  }
}