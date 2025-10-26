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
import { JSON, MessageEvents, worker } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { getAbilityNameFromHar } from 'har';
import { getAbilityNameFromHsp } from 'hsp';
import Logger from '../common/Logger';

const TAG = 'GetUIAbilityContextDemo';

@Builder
export function GetUIAbilityContextBuilder() {
  GetUIAbilityContextDemo()
}

@Component
export struct GetUIAbilityContextDemo {
  @StorageLink('abilityNameFromUIAbility') abilityNameFromUIAbility: string = '';
  @State abilityNameFromUI: string = '';
  @State abilityNameFromWorker: string = '';
  @State result: ResourceStr = '';
  private workerInstance: worker.ThreadWorker = new worker.ThreadWorker('entry/ets/workers/MyWorker.ets');
  // get UIAbilityContext object in UI.
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.abilityNameFromUI = this.context.abilityInfo.name;
    this.workerInit();
  }

  workerInit(): void {
    try {
      // Send the UIAbilityContext object as a message to the Worker thread
      this.workerInstance.postMessage({ 'context': this.context });
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `postMessage err, code: ${error.code}, mesage: ${error.message}`);
    }

    // Receive a message from the worker
    this.workerInstance.onmessage = ((message: MessageEvents) => {
      let data = message.data as Record<string, string>;
      if (data) {
        this.abilityNameFromWorker = data.abilityNameFromWorker;
      }
    });

    // worker error callback
    this.workerInstance.onerror = (error => {
      Logger.error(`workerInstance onerror: ${JSON.stringify(error)}`)
    });
  }

  aboutToDisappear(): void {
    try {
      this.workerInstance.terminate();
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `terminate err, code: ${error.code}, mesage: ${error.message}`);
    }
  }

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
          Button($r('app.string.get_UIAbilityContext_in_UIAbility'))
            .width('100%')
            .onClick(() => {
              this.result = $r('app.string.get_AbilityName', 'UIAbility', this.abilityNameFromUIAbility);
            })

          Button($r('app.string.get_UIAbilityContext_in_UI'))
            .width('100%')
            .onClick(() => {
              this.result = $r('app.string.get_AbilityName', 'UI', this.abilityNameFromUI);
            })

          Button($r('app.string.get_UIAbilityContext_in_HAR'))
            .width('100%')
            .onClick(() => {
              this.result = $r('app.string.get_AbilityName', 'HAR', getAbilityNameFromHar(this.context));
            })

          Button($r('app.string.get_UIAbilityContext_in_HSP'))
            .width('100%')
            .onClick(() => {
              this.result = $r('app.string.get_AbilityName', 'HSP', getAbilityNameFromHsp(this.context));
            })

          Button($r('app.string.get_UIAbilityContext_in_Worker'))
            .width('100%')
            .onClick(() => {
              this.result = $r('app.string.get_AbilityName', 'Worker', this.abilityNameFromWorker);
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
    .title($r('app.string.get_ui_ability_context'))
    .backgroundColor($r('sys.color.background_secondary'))
  }
}