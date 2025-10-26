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

import { Permissions } from '@kit.AbilityKit';
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { RequestPermissionUtil } from '@ohos/mediaservice';
import { AppStore } from '../common/store/AppStore';
import { confirmServiceMap, DialogText } from '../common/utils/ConfirmService';
import { DataConfig } from '../common/store/DataInterface';

@HMRouter({ pageUrl: 'SceneConfirm', dialog: true })
@Component
export struct SceneConfirm {
  @StorageLink('configSource') @Watch('configSourceChange') configSource: Array<DataConfig> | undefined = AppStorage.get('configSource')!;
  private title: string | Resource = '';
  private content: string | Resource = '';

  initConfigSource() {
    const sceneIndex: number = AppStore.getInstance().currentSceneIndex;
    const stepIndex: number = AppStore.getInstance().currentStepIndex;

    this.title = this.configSource![sceneIndex].steps[stepIndex].dialogTitle;
    this.content = this.configSource![sceneIndex].steps[stepIndex].dialogContent;
    if (this.configSource![sceneIndex].steps[stepIndex].service) {
      const serviceName: string = this.configSource![sceneIndex].steps[stepIndex].service;
      if (!serviceName) {
        return;
      }
      const dialogText: DialogText | undefined = confirmServiceMap.get(serviceName)?.();
      if (dialogText) {
        this.title = dialogText.title;
        this.content = dialogText.content;
      }
    }
  }

  aboutToAppear(): void {
    this.initConfigSource();
  }

  configSourceChange() {
    this.initConfigSource();
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.shadow'))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
      Column() {
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({
            top: 20,
            left: 20,
            right: 20
          });
        Text(this.content)
          .fontSize(16)
          .margin({
            top: 20,
            left: 20,
            right: 20
          })
          .width('90%')
          .textAlign(TextAlign.Center);
        Row() {
          Button($r('app.string.common_cancel'), { buttonStyle: ButtonStyleMode.TEXTUAL })
            .onClick(() => {
              HMRouterMgr.pop();
            })
            .margin({
              top: 20,
              bottom: 20
            })
            .width('45%')
            .fontColor($r('app.color.primary_button'))
            .fontWeight(FontWeight.Bold);

          Button($r('app.string.common_confirm'), { buttonStyle: ButtonStyleMode.TEXTUAL })
            .onClick(async () => {
              if (this.configSource![AppStore.getInstance().currentSceneIndex].audioType === 'recording') {
                const permissionMic: Permissions = 'ohos.permission.MICROPHONE';
                HMRouterMgr.pop();
                let isGranted: boolean = await RequestPermissionUtil.reqPermissionsFromUser(permissionMic);
                if (!isGranted) {
                  this.getUIContext().getPromptAction().showToast({
                    message: $r('app.string.sound_recording_forbidden_tips')
                  });
                  return;
                } else {
                  HMRouterMgr.push({
                    pageUrl: 'SceneCheck'
                  });
                }
              } else {
                HMRouterMgr.replace({
                  pageUrl: 'SceneCheck'
                });
              }
            })
            .margin({
              top: 20,
              bottom: 20
            })
            .width('45%')
            .fontColor($r('app.color.primary_button'))
            .fontWeight(FontWeight.Bold);
        };
      }
      .width('90%')
      .borderRadius(20)
      .backgroundColor(Color.White);
    };
  }
}