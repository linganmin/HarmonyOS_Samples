/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PromptAction } from '@kit.ArkUI';
import { GameStartStep, TAG, DOMAINID } from '../common/CommonConstants';
import { GameStepDetect, StepDetectResult, StepDetectProgress } from '../task/GameStepDetect';

@Entry
@Component
struct Index {
  @State progress: number = 0;
  @State totalCount: number = 0;
  @State successCount: number = 0;
  @State bytesWritten: string = '';
  @State totalWritten: string = '';
  @State totalFileNumer: number = 0;
  @State displayVersion : string = '';
  @State step : GameStartStep = GameStartStep.STEP1;
  @State uiContext: Context = this.getUIContext().getHostContext() as common.Context;

  Sleep(ms: number):Promise<void> {
    return new Promise((resolve) => {
      setTimeout(resolve, ms);
    })
  }

  async aboutToAppear(): Promise<void> {
    hilog.info(DOMAINID, TAG, 'aboutToAppear start.');
    this.step = GameStartStep.STEP1;
    await this.Sleep(500);
    // Detect task.
    let stepDetect : GameStepDetect = new GameStepDetect(this.uiContext);
    stepDetect.addProgressListener((inputProgress)=>{
      let stepDetectProgress : StepDetectProgress = inputProgress as StepDetectProgress;
      hilog.info(DOMAINID, TAG, `GameStepDetect progress: ${stepDetectProgress.progress}`);
      this.progress = stepDetectProgress.progress;
      this.totalCount = stepDetectProgress.totalCount;
      this.successCount = stepDetectProgress.successCount;
    })
    stepDetect.Start();
    let result  = await stepDetect.WaitProgressEnd();
    let stepDetectResult = result as StepDetectResult;
    hilog.info(DOMAINID, TAG, `stepDetectResult ${JSON.stringify(stepDetectResult)}`);
    await this.Sleep(1000);
    // Get next step.
    this.step = stepDetectResult.nextStep === 2 ? GameStartStep.STEP2 : GameStartStep.STEP1;
    if (this.step === GameStartStep.STEP2) {
      this.displayVersion = stepDetectResult.version;
    } else {
      let uiContext = this.getUIContext();
      let promptAction: PromptAction = uiContext.getPromptAction();
      promptAction.showDialog({
        message: $r('app.string.Dialog_Text'),
        buttons: [
          {
            text: 'OK',
            color: '#000000'
          }
        ]
      })
        .then(data => {
          console.info(TAG, 'showDialog success, click button: ' + data.index);
          this.uiContext.getApplicationContext().killAllProcesses();
        })
        .catch((err: Error) => {
          console.error(TAG, `showDialog error: : ${err}`);
          this.uiContext.getApplicationContext().killAllProcesses();
        })
    }
  }

  @Builder
  GameStartStep1Style() {
    Column() {
      Row() {
        Text($r('app.string.Checking_for_updates'))
          .fontSize(10)
          .fontWeight(600)
          .fontColor(0xf2ebd7)
          .alignSelf(ItemAlign.Start)
        Blank()
          .width(40)
      }
      .position({ x: 30, y: '80.5%' })
      .padding({ left: 5, right: 15, bottom: 8 })
      .width('100%')
    }
    Column() {
      Progress({
        value: this.progress,
        total: 100,
        type: ProgressType.Linear
      }).width('90%')
        .padding({ bottom: 2 })
        .height(24)
        .position({ x: 30, y: '84%' })
        .backgroundColor('#F0FFFF')
        .color('#FF9912')
        .enabled(false)
    }
    Column() {
      Row() {
        Text(this.uiContext.resourceManager.getStringSync($r('app.string.Downloading_resources')) +
          ` ${this.successCount} / ${this.totalCount} `)
          .fontSize(10)
          .fontWeight(600)
          .fontColor(0xf2ebd7)
          .alignSelf(ItemAlign.Start)
        Blank()
          .width(40)
      }
      .height(20)
      .position({ x: 25, y: '90%' })
      .padding({ left: 5, right: 15, bottom: 8 })
      .width('100%')
    }
  }

  @Builder
  GameStartStep2Style() {
    Column() {
      Row() {
        Text($r('app.string.Touch_Enter'))
          .fontSize(18)
          .fontWeight(600)
          .fontColor(0xf2ebd7)
          .fontStyle(FontStyle.Italic)
          .alignSelf(ItemAlign.Start)
        Blank()
          .width(40)
      }
      .position({ x: 350, y: '70%' })
      .padding({ left: 5, right: 15, bottom: 8 })
      .width('100%')
    }
    Column() {
      Row() {
        Text(this.uiContext.resourceManager.getStringSync($r('app.string.Version_No')) +  String(this.displayVersion))
          .fontSize(10)
          .fontWeight(600)
          .fontColor(0xf2ebd7)
          .alignSelf(ItemAlign.Start)
        Blank()
          .width(10)
      }.height(20)
      .position({ x: 720, y: '90%' })
      .padding({ left: 5, right: 15, bottom: 8 })
      .width('100%')
    }

  }

  @Builder
  GameStartStepStyle() {
    if (this.step === GameStartStep.STEP1) {
      this.GameStartStep1Style()
    }
    if (this.step === GameStartStep.STEP2) {
      this.GameStartStep2Style()
    }
  }
  build() {
    Column({ space: 5 }) {
      this.GameStartStepStyle();
    }.backgroundImage($r('app.media.homepage'), ImageRepeat.NoRepeat)
    .backgroundImageSize(ImageSize.Cover)
    .width('100%')
    .height(400)
    .border({ width: 1 })
  }
}