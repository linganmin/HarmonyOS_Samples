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
import { AVTranscoderManager, outputPathCommon } from '../utils/AVTranscoderManager';

@CustomDialog
struct MyCustomDialog {
  controller: CustomDialogController;
  cancel: () => void = () => {};
  confirm: () => void = () => {};

  build() {
    Column() {
      Text($r('app.string.text_cancel'))
        .textAlign(TextAlign.Center)
        .fontSize('16vp')
        .fontColor('rgba(0, 0, 0, 0.9)')
        .lineHeight('21vp')

      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        Button($r('app.string.button_cancel'), { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
          .flexGrow(1)
          .backgroundColor(Color.Transparent)
          .fontColor('#0A59F7')
          .fontSize('16vp')
          .fontWeight(500)
          .onClick(() => {
            this.cancel()
          })
        Divider()
          .vertical(true)
          .strokeWidth('0.5vp')
          .height(24)
          .color('rgba(0, 0, 0, 0.05)')
          .margin({ left: 4, right: 4 })
        Button($r('app.string.button_confirm'), { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
          .flexGrow(1)
          .backgroundColor(Color.Transparent)
          .fontColor('#0A59F7')
          .fontSize('16vp')
          .fontWeight(500)
          .onClick(() => {
            this.confirm()
          })
      }
      .height('40vp')
      .margin({ top: '8vp' })
    }
    .width('328vp')
    .padding('24vp')
    .borderRadius('32vp')
    .backgroundColor(Color.White)
  }
}

@Component
export struct VideoTranscoderPage {
  @Consume('pathInfos') pathInfos: NavPathStack;
  private context: Context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State avTranscoder: AVTranscoderManager = new AVTranscoderManager(this.context); // Get the transcoding function management class
  @State isPause: boolean = false;
  @State isFinish: boolean = false;
  @State progress: number = 0;
  private progressColors: LinearGradient = new LinearGradient([{ color: "#f7cd00", offset: 0 }, { color: "#f99b11", offset: 1 }]);

  getParamsPrint() {
    this.context.eventHub.on('myEvent', this.eventFunc);
    const params: string = JSON.stringify(this.pathInfos.getParamByName('VideoTranscoderPage')[0]);
    this.avTranscoder.setAVConfig(JSON.parse(params));
    this.avTranscoder.startTranscoderProcess();
  }

  // Conversion progress monitoring event
  eventFunc = (progress: number) => {
    this.progress = progress;
    this.isFinish = progress === 100;
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: MyCustomDialog({
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onConfirm() }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true
  })

  // Close the pop-up window
  onCancel() {
    this.dialogController.close();
  }

  // Confirm the cancellation of transcoding
  onConfirm() {
    this.avTranscoder.releaseTranscoderProcess();
    this.pathInfos.pop();
    this.dialogController.close();
  }
  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        Column() {
          Stack() {
            Progress({ value: 0, total: 100, type: ProgressType.Ring })
              .value(this.progress)
              .width('248vp')
              .height('248vp')
              .backgroundColor(Color.White)
              .color(this.progressColors)
              .style({ strokeWidth: 20 })
            Column() {
              Row() {
                Text(`${this.progress}`)
                  .fontSize('60vp')
                  .lineHeight('60vp')
                  .fontColor('rgba(0, 0, 0, 0.9)')
                  .fontWeight(700)
                Text('%')
                  .fontSize('16vp')
                  .fontColor('rgba(0, 0, 0, 0.6)')
                  .lineHeight('60vp')
              }
              .alignItems(VerticalAlign.Bottom)

              Text($r('app.string.current_process'))
                .fontSize('14vp')
                .fontColor('rgba(0, 0, 0, 0.6)')
            }

          }
          .margin({ top: '56vp' })

          Text($r('app.string.high_speed_processing'))
            .margin({ top: '24vp' })
            .fontSize('20vp')

          Text($r('app.string.tip'))
            .width('80%')
            .textAlign(TextAlign.Center)
            .fontColor('#595959')
            .fontSize('16vp')
            .margin({ top: '24vp' })
        }
        .width('100%')
        .flexGrow(1)
        .alignItems(HorizontalAlign.Center)

        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
          Button(this.isPause ? $r('app.string.button_continue') : $r('app.string.button_pause'),
            { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
            .flexGrow(1)
            .height('40vp')
            .onClick(() => {
              if (this.isFinish) {
                try {
                  this.getUIContext().getPromptAction().showToast({
                    message: $r('app.string.showToastWarnPause'),
                    duration: 2000
                  })
                  return
                } catch (err) {
                  hilog.error(0x0000, 'testTag', `getUIContext failed, code is ${err.code}, message is ${err.message}`);
                }
              }
              if (this.isPause) {
                // Resume to convert
                this.avTranscoder.resumeTranscoderProcess()
                this.isPause = false
              } else {
                // Suspend the conversion
                this.avTranscoder.pauseTranscoderProcess()
                this.isPause = true
              }
            })


          Button(this.isFinish ? $r('app.string.button_finish') : $r('app.string.button_cancel'),
            { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
            .flexGrow(1)
            .height('40vp')
            .margin({ left: '12vp' })
            .onClick(() => {
              if (this.isFinish) {
                // Conversion Complete
                const params: outputPathCommon = {
                  outputFilePath: this.avTranscoder.outputFilePath
                }
                this.pathInfos.replacePathByName('TranscoderFinishPage', params);
              } else {
                // Cancel the conversion
                this.dialogController.open();
              }
            })
        }
        .width('100%')
        .padding('16vp')
        .flexShrink(0)
      }
    }
    .title($r('app.string.transcoder_progress'))
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
    .onShown(() => {
      this.getParamsPrint();
    })
    .onHidden(() => {
      this.context.eventHub.off('myEvent', this.eventFunc);
    })
  }
}