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

import { insightIntent } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import AudioPlayHandler from '../entryability/intentHandlers/AudioPlayHandler';
import TextGetHandler from '../entryability/intentHandlers/TextGetHandler';

@Entry
@Component
struct SecondPage {
  @State content: ResourceStr = $r('app.string.load');
  private title = 'SecondPage';
  private audioPlayHandler = new AudioPlayHandler();
  private textGetHandler = new TextGetHandler();
  private audioHandlerInput: Record<string, string> = {
    'audioName': 'Dream It Possible.flac'
  };

  @State hiddenMessage: ResourceStr = $r('app.string.show');

  build() {
    Column() {
      Text(this.title)
        .fontSize(30)
        .fontWeight('bold')
        .fontColor('#333333')

      Row() {
        Button($r('app.string.back'))
          .width(60)
          .height(30)
          .onClick(() => this.getUIContext().getRouter().back())
      }
      .width('100%')
      .padding(16)

      // Function button area.
      Row() {
        Button($r('app.string.play'))
          .width('45%')
          .height(50)
          .backgroundColor('#409EFF')
          .fontColor(Color.White)
          .onClick(() => this.audioPlayHandler.execute(this.audioHandlerInput))

        Button($r('app.string.acquire'))
          .width('45%')
          .height(50)
          .backgroundColor('#67C23A')
          .fontColor(Color.White)
          .margin({ left: 10 })
          .onClick(() => {
            this.textGetHandler.execute().then((executeResult: insightIntent.ExecuteResult) => {
              this.hiddenMessage = String(executeResult.result?.audioName);
            }).catch((error: BusinessError) => {
              this.hiddenMessage = $r('app.string.hidden') + `error: ${error.message}`;
            })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 20 })

      Text(this.hiddenMessage)
        .fontSize(20)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .margin(10)
        .padding(15)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .width('90%')

      // DeepLink
      Text($r('app.string.deep_link'))
        .fontSize(14)
        .fontColor(Color.Grey)
        .margin({ top: 30, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F5FF')
  }
}