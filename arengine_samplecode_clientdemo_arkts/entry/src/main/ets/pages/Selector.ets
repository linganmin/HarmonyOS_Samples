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

import { abilityAccessCtrl, PermissionRequestResult } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';
import { requestPermissionOnSetting } from '../utils/Utils';

@Entry
@Component
struct Selector {
  pageInfos: NavPathStack = new NavPathStack();
  private hasPermission: boolean = false;
  @State context: Context = this.getUIContext().getHostContext() as Context;

  build(): void {
    Navigation(this.pageInfos) {
      Column() {
        this.sampleButton('ARWorld');
        this.sampleButton('ARMesh');
        this.sampleButton('ARDepth');
        this.sampleButton('ARImage');
        this.sampleButton('ARSemanticDense');
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')
      .height('100%')
    }
    .onAppear(() => {
      this.requestPermissionOnFirstStartup();
    })
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
  }

  @Builder
  sampleButton(sampleName: string): void {
    Button(sampleName, { type: ButtonType.Normal, stateEffect: true })
      .borderRadius(8)
      .width('50%')
      .height('5%')
      .onClick(async () => {
        if (!this.hasPermission) {
          this.hasPermission = await requestPermissionOnSetting(this.context);
          if (!this.hasPermission) {
            return;
          }
        }
        this.pageInfos.clear();
        this.pageInfos.pushDestinationByName(sampleName, null);
      })
  }

  private requestPermissionOnFirstStartup(): void {
    abilityAccessCtrl.createAtManager()
      .requestPermissionsFromUser(this.context, ['ohos.permission.CAMERA'])
      .then((data: PermissionRequestResult) => {
        let grantStatus: number[] = data.authResults;
        if (grantStatus[0] === 0) {
          this.hasPermission = true;
          Logger.info('Succeeded in getting requestPermission.');
        } else {
          this.hasPermission = false;
          Logger.error('Failed to get requestPermission, user rejected.');
        }
      })
      .catch((err: BusinessError) => {
        Logger.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}.`);
      })
  }
}
