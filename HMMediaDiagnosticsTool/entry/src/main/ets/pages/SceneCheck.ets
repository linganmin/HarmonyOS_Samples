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

import { audio } from '@kit.AudioKit';
import { HMLifecycle, HMLifecycleContext, HMRouter, HMRouterMgr, IHMLifecycle } from '@hadss/hmrouter';
import { AudioCapturerController, AudioRendererController } from '@ohos/mediaservice';
import { Header } from '../components/Header';
import { CheckList } from '../components/CheckList';
import { AppStore } from '../common/store/AppStore';
import { SceneOption } from '../common/store/Score';
import { IconContent } from '../components/IconContent';
import { DataConfig } from '../common/store/DataInterface';

@HMLifecycle({ lifecycleName: 'SceneCheckLifecycle' })
export class SceneCheckLifecycle implements IHMLifecycle {
  private data: Array<DataConfig> = AppStorage.get('configSource')!;

  onBackPressed(ctx: HMLifecycleContext): boolean {
    let currentAudioType: string | undefined = AppStore.getInstance().currentAudioType;
    if (!currentAudioType) {
      return false;
    }
    if (currentAudioType === 'recording') {
      AudioCapturerController.getInstance().stop();
    } else {
      AudioRendererController.getInstance(audio.StreamUsage[currentAudioType]).stop();
    }
    return false;
  }

  onShown(ctx: HMLifecycleContext): void {
    const sceneIndex = AppStore.getInstance().currentSceneIndex;
    const stepIndex = AppStore.getInstance().currentStepIndex;

    const optionIndex = AppStore.getInstance().optionRecord[sceneIndex]?.optionIndex[stepIndex];
    if (optionIndex !== undefined) {
      AppStore.getInstance().currentOptionIndex = optionIndex;
    }

    AppStore.getInstance().currentAudioType = this.data[sceneIndex].audioType;
  }
}

@HMRouter({ pageUrl: 'SceneCheck', lifecycle: 'SceneCheckLifecycle' })
@Component
export struct SceneCheck {
  @StorageLink('configSource') configSource: Array<DataConfig> | undefined = AppStorage.get('configSource')!;
  @State currentOptionIndex: number | null = null;
  private currentSceneIndex: number = 0;
  private currentStepIndex: number = 0;

  aboutToAppear(): void {
    this.currentSceneIndex = AppStore.getInstance().currentSceneIndex;
    this.currentStepIndex = AppStore.getInstance().currentStepIndex;

    AppStore.getInstance().currentAudioType = this.configSource![this.currentSceneIndex].audioType;
    let currentAudioType: string | undefined = AppStore.getInstance().currentAudioType;
    if (currentAudioType && currentAudioType !== 'recording') {
      AudioRendererController.getInstance(audio.StreamUsage[currentAudioType]).play();
    }
    if (currentAudioType === 'recording') {
      AudioCapturerController.getInstance().start();
    }

    // Previous step, selected items need to be recorded and displayed on the page.
    if (this.currentSceneIndex < AppStore.getInstance().optionRecord.length) {
      const sceneOption = AppStore.getInstance().optionRecord[this.currentSceneIndex];
      if (!AppStore.getInstance().isMultiStep) { // Set up for no multi-step scene directly
        this.currentOptionIndex = sceneOption.optionIndex[0];
      } else if (this.currentStepIndex <
      sceneOption.optionIndex.length) { // Multi-step scene need to determine which steps have already been selected
        this.currentOptionIndex = sceneOption.optionIndex[this.currentStepIndex];
      } else {
        this.currentOptionIndex = null;
      }
    }
  }

  addScore() {
    const sceneIndex: number = AppStore.getInstance().currentSceneIndex;
    const stepIndex: number = AppStore.getInstance().currentStepIndex;

    let optionItem: SceneOption;
    if (sceneIndex === AppStore.getInstance().optionRecord.length) {
      // a new step
      optionItem = new SceneOption();
      optionItem.index = sceneIndex;
      optionItem.required = this.configSource![sceneIndex].required;
      optionItem.scene = this.configSource![sceneIndex].scene;
      optionItem.sceneName = this.configSource![sceneIndex].sceneName;
      optionItem.score = this.configSource![sceneIndex].highestScore;
      optionItem.jumpIndex = AppStore.getInstance().currentStepIndex;
      AppStore.getInstance().optionRecord[sceneIndex] = optionItem;
    } else {
      optionItem = AppStore.getInstance().optionRecord[sceneIndex];
    }

    optionItem.optionIndex[stepIndex] = AppStore.getInstance().currentOptionIndex;
    optionItem.isSkiped = false;
    if (AppStore.getInstance().isMultiStep) {
      if (this.currentOptionIndex !== 0 && optionItem.score > 0) {
        optionItem.score = optionItem.score - this.configSource![sceneIndex].stepDeduction;
        optionItem.score = Math.max(optionItem.score, 0);
      }
    } else {
      optionItem.score = this.currentOptionIndex === 0 ? this.configSource![sceneIndex].highestScore : 0;
    }
  }

  build() {
    Column() {
      Column() {
        Header({ description: this.configSource![this.currentSceneIndex].sceneDescription });

        IconContent({
          iconSrc: this.configSource![this.currentSceneIndex].pageIcon,
          sceneText: this.configSource![this.currentSceneIndex].sceneText!,
          isInteractive: this.configSource![this.currentSceneIndex].isInteractive,
        });

        CheckList({
          checkList: this.configSource![this.currentSceneIndex].steps[this.currentStepIndex].options,
          currentOptionIndex: this.currentOptionIndex
        });
      };

      Row() {
        Button($r('app.string.common_retry'), { type: ButtonType.Capsule, stateEffect: false })
          .layoutWeight(1)
          .height(40)
          .margin({ right: 8 })
          .fontColor($r('app.color.primary_button'))
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .onClick(() => {
            HMRouterMgr.pop();
            let currentAudioType: string | undefined = AppStore.getInstance().currentAudioType;
            if (!currentAudioType) {
              return;
            }
            AudioRendererController.getInstance(audio.StreamUsage[currentAudioType]).stop();
            AudioCapturerController.getInstance().stop();
          });
        Button($r('app.string.common_continue'), { type: ButtonType.Capsule, stateEffect: false })
          .layoutWeight(1)
          .height(40)
          .margin({ left: 8 })
          .fontColor($r('app.color.primary_button'))
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .onClick(() => {
            if (this.currentOptionIndex === null) {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.common_select') });
              return;
            }

            let pageUrl = 'SceneHome';
            this.addScore();
            if (AppStore.getInstance().currentStepIndex < this.configSource![this.currentSceneIndex].steps.length - 1) {
              AppStore.getInstance().currentStepIndex++;
            } else if (AppStore.getInstance().currentSceneIndex < this.configSource!.length - 1) {
              AppStore.getInstance()
                .optionRecord[AppStore.getInstance().currentSceneIndex]
                .jumpIndex = AppStore.getInstance().currentStepIndex;
              AppStore.getInstance().currentSceneIndex++;
              AppStore.getInstance().initSceneStatus();
            } else {
              AppStore.getInstance()
                .optionRecord[AppStore.getInstance().currentSceneIndex]
                .jumpIndex = AppStore.getInstance().currentStepIndex;
              AppStore.getInstance().currentSceneIndex++;
              pageUrl = 'ScorePage';
            }

            let currentAudioType: string | undefined = AppStore.getInstance().currentAudioType;
            if (currentAudioType && currentAudioType !== 'recording') {
              AudioRendererController.getInstance(audio.StreamUsage[currentAudioType]).stop();
            }
            if (currentAudioType === 'recording') {
              AudioCapturerController.getInstance().stop();
            }
            HMRouterMgr.push({
              pageUrl: pageUrl
            });
          });
      }
      .width('100%')
      .margin({ bottom: 12 })
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 16,
      right: 16,
      bottom: 16
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}