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

import { common } from '@kit.AbilityKit';
import { getAppFilesDirFromHar } from 'har';
import { getAppFilesDirFromHsp } from 'hsp';

@Builder
export function GetApplicationContextBuilder() {
  GetApplicationContextDemo()
}

@Component
export struct GetApplicationContextDemo {
  @State result: ResourceStr = '';
  @StorageLink('appFilesDirFromUIAbility') appFilesDirFromUIAbility: string = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  // get ApplicationContext in UI
  private applicationContext = this.context.getApplicationContext();

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
          Button($r('app.string.get_ApplicationContext_in_UIAbility'))
            .width('100%')
            .onClick(() => {
              this.result = $r('app.string.get_application_filesDir', 'UIAbility', this.appFilesDirFromUIAbility);
            })

          Button($r('app.string.get_ApplicationContext_in_UI'))
            .width('100%')
            .onClick(() => {
              this.result = $r('app.string.get_application_filesDir', 'UI', this.applicationContext.filesDir);
            })

          Button($r('app.string.get_ApplicationContext_in_HAR'))
            .width('100%')
            .onClick(() => {
              this.result = $r('app.string.get_application_filesDir', 'HAR', getAppFilesDirFromHar(this.context));
            })

          Button($r('app.string.get_ApplicationContext_in_HSP'))
            .width('100%')
            .onClick(() => {
              this.result = $r('app.string.get_application_filesDir', 'HSP', getAppFilesDirFromHsp(this.context));
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
    .title($r('app.string.get_application_context'))
    .backgroundColor($r('sys.color.background_secondary'))
  }
}