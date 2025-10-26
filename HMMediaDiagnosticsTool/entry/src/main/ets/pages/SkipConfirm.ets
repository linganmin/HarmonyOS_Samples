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

import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { AppStore } from '../common/store/AppStore';
import { DataConfig } from '../common/store/DataInterface';
import { SceneOption } from '../common/store/Score';

@HMRouter({ pageUrl: 'SkipConfirm', dialog: true })
@Component
export struct SceneConfirm {
  @StorageLink('configSource') configSource: Array<DataConfig> | undefined = AppStorage.get('configSource')!;

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.shadow'))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

      Column() {
        Text($r('app.string.skip_dialog_title'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({
            top: 20,
            left: 20,
            right: 20
          });
        Text($r('app.string.skip_dialog_content'))
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
            .onClick(() => {
              const sceneIndex = AppStore.getInstance().currentSceneIndex;
              // record when skipping new steps
              if (AppStore.getInstance().currentSceneIndex === AppStore.getInstance().optionRecord.length) {
                const skippedStepRecord: SceneOption = new SceneOption();
                skippedStepRecord.index = sceneIndex;
                skippedStepRecord.scene = this.configSource![sceneIndex].scene;
                skippedStepRecord.sceneName = this.configSource![sceneIndex].sceneName;
                skippedStepRecord.required = this.configSource![sceneIndex].required;
                skippedStepRecord.score = this.configSource![sceneIndex].highestScore;
                skippedStepRecord.isSkiped = true;
                skippedStepRecord.jumpIndex = AppStore.getInstance().currentStepIndex;
                AppStore.getInstance().optionRecord[sceneIndex] = skippedStepRecord;
              } else {
                AppStore.getInstance().optionRecord[sceneIndex].isSkiped = true;
                AppStore.getInstance().optionRecord[sceneIndex].jumpIndex = AppStore.getInstance().currentStepIndex;
              }

              let pageUrl = 'SceneHome';
              AppStore.getInstance().currentSceneIndex++;
              AppStore.getInstance().initSceneStatus();
              if (AppStore.getInstance().currentSceneIndex === this.configSource!.length) {
                pageUrl = 'ScorePage';
              }

              HMRouterMgr.replace({
                pageUrl: pageUrl
              });
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