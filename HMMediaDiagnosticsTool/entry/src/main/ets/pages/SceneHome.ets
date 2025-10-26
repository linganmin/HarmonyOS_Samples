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

import { HMLifecycle, HMLifecycleContext, HMRouter, HMRouterMgr, IHMLifecycle } from '@hadss/hmrouter';
import { Header } from '../components/Header';
import { MainContent } from '../components/MainContent';
import { Step } from '../common/store/Score';
import { AppStore } from '../common/store/AppStore';
import { DataConfig } from '../common/store/DataInterface';

@HMLifecycle({ lifecycleName: 'SceneHomeLifecycle' })
@Observed
export class SceneHomeLifecycle implements IHMLifecycle {
  private data: Array<DataConfig> = AppStorage.get('configSource')!;

  onBackPressed(ctx: HMLifecycleContext): boolean {
    if (AppStore.getInstance().currentStepIndex > 0) {
      AppStore.getInstance().currentStepIndex--;
    } else if (AppStore.getInstance().currentSceneIndex > 0) {
      AppStore.getInstance().currentSceneIndex--;
      const sceneIndex = AppStore.getInstance().currentSceneIndex;
      AppStore.getInstance().isMultiStep = this.data[sceneIndex].steps.length > 1;
      AppStore.getInstance().currentStepIndex = AppStore.getInstance().optionRecord[sceneIndex].jumpIndex;
    }
    return false;
  }
}

@HMRouter({ pageUrl: 'SceneHome', lifecycle: 'SceneHomeLifecycle' })
@Component
export struct SceneHome {
  @StorageLink('configSource') @Watch('configSourceChange') configSource: Array<DataConfig> | undefined =
    AppStorage.get('configSource')!;
  @State checkPoint: string[] = [];
  @State bestExperience: string[] = [];
  @State stepTips: string[] = [];
  @State description: string = '';
  @State private sceneIndex: number = AppStore.getInstance().currentSceneIndex;
  scroller: Scroller = new Scroller();

  initConfigSource() {
    this.checkPoint = this.configSource![this.sceneIndex].checkPoint;
    this.bestExperience = this.configSource![this.sceneIndex].bestExperience;
    this.description = this.configSource![this.sceneIndex].sceneDescription;

    if (this.configSource![this.sceneIndex].steps.length > 1) {
      this.stepTips = this.configSource![this.sceneIndex].steps.map((item: Step) => item.text || '');
      AppStore.getInstance().isMultiStep = true;
    } else {
      this.stepTips = this.configSource![this.sceneIndex].stepTips;
    }
  }

  aboutToAppear(): void {
    this.initConfigSource();
  }

  configSourceChange() {
    this.initConfigSource();
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          Header({ description: this.description });

          MainContent({
            checkPoint: this.checkPoint,
            bestExperience: this.bestExperience,
            stepTips: this.stepTips
          });
        }
        .constraintSize({ minHeight: '100%' });
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .layoutWeight(1);

      Column() {
        Text((this.sceneIndex + 1) + '/13')
          .margin({
            top: 10,
            bottom: 22
          });

        Row() {
          if (this.sceneIndex > 0) {
            Button($r('app.string.common_previous'), { type: ButtonType.Capsule, stateEffect: false })
              .width('48%')
              .height(40)
              .fontColor($r('app.color.primary_button'))
              .backgroundColor('rgba(0, 0, 0, 0.05)')
              .onClick(() => {
                AppStore.getInstance().currentSceneIndex--;
                this.sceneIndex--;

                const lastStepLength = AppStore.getInstance().optionRecord[this.sceneIndex].jumpIndex;
                const stepIndex = AppStore.getInstance().currentStepIndex;

                let stackLength = (lastStepLength + 1 + stepIndex) * 2;
                if (AppStore.getInstance().optionRecord[this.sceneIndex].isSkiped) {
                  stackLength = stackLength - 1;
                }
                AppStore.getInstance().isMultiStep = this.configSource![this.sceneIndex].steps.length > 1;
                AppStore.getInstance().currentStepIndex = 0;
                for (let i = 0; i < stackLength; i++) {
                  HMRouterMgr.pop();
                }
              });
          }
          Button($r('app.string.common_skip'), { type: ButtonType.Capsule, stateEffect: false })
            .width(this.sceneIndex > 0 ? '48%' : '100%')
            .height(40)
            .fontColor($r('app.color.primary_button'))
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .onClick(() => {
              HMRouterMgr.push({
                pageUrl: 'SkipConfirm'
              });
            });
        }
        .width('100%')
        .margin({ bottom: 12 })
        .justifyContent(FlexAlign.SpaceBetween);

        Button($r('app.string.common_start'), { type: ButtonType.Capsule, stateEffect: false })
          .width('100%')
          .height(40)
          .onClick(() => {
            HMRouterMgr.push({
              pageUrl: 'SceneConfirm'
            });
          });
      };
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