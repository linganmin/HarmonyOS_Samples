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

import { rcp } from '@kit.RemoteCommunicationKit';

const kHttpServerAddress = "https://httpbin.org";

@Entry
@Component
struct TimeOut {
  @State showToken: string = '';
  @State content: string = '';
  @State timeout: rcp.Timeout = {
    connectMs: 1000,
    transferMs: 1000
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Row() {
        Text('TimeOut')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff100f0f')
          .height(30)
          .width(220)
          .margin({ left: 4 })
      }
      .height(32)
      .width(124)
      .margin({ top: 32, left: 12 })

      Divider().color('gray').strokeWidth(1)

      Text(this.showToken)
        .fontColor(Color.Blue)
        .width('80%')
        .margin({ left: '10%' })
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.SpaceBetween
      }) {
        Text("ConnectMs:")
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff100f0f')
          .height(40)
          .width(220)

        TextArea({
          text: String(this.timeout.connectMs)
        })
          .width('80%')
          .height(40)
          .margin({ left: '10%' })
          .backgroundColor('0x317aff')
          .fontColor('#000')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .borderRadius(10)
          .type(TextAreaType.NUMBER)
          .onChange((text) => {
            const value = Number(text);
            if (!Number.isNaN(value)) {
              this.timeout.connectMs = Number.parseInt(text);
            }
          })

        Text("TransferMs:")
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff100f0f')
          .height(40)
          .width(220)
        TextArea({
          text: String(this.timeout.transferMs)
        })
          .width('80%')
          .height(40)
          .margin({ left: '10%' })
          .backgroundColor('0x317aff')
          .fontColor('#000')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .borderRadius(10)
          .type(TextAreaType.NUMBER)
          .onChange((text) => {
            const value = Number(text);
            if (!Number.isNaN(value)) {
              this.timeout.transferMs = Number.parseInt(text);
            }
          })

        Column() {
          Button('Timeout-Test')
            .width('80%')
            .height(40)
            .backgroundColor('#0A59F7')
            .fontColor(Color.White)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .borderRadius(20)
            .onClick(this.getTimeoutSyn)
            .margin({ top: 10 })
        }.width('100%')
        .alignItems(HorizontalAlign.Center)

        Text("Result:")
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff100f0f')
          .margin({ top: 10, bottom: 10 })

        Scroll() {
          Text(this.content)
            .width('100%')
            .fontColor('#ff100f0f')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .padding(8)
        }.width('100%')
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .backgroundColor('#F3F3F3')
        .borderRadius(10)
      }
      .padding(15)
    }
    .linearGradient({
      direction: GradientDirection.Top,
      repeating: true,
      colors: [['#FFFFFF', 0], ['#FFFFFF', 1]]
    })
    .height('100%')
    .width('100%')
  }

  /**
   * Example method for configuring timeout time.
   */
  private getTimeoutSyn = async () => {
    try {
      const session = rcp.createSession();
      const request = new rcp.Request(kHttpServerAddress);
      // Timeout configuration.
      request.configuration = {
        transfer: {
          timeout: this.timeout
        }
      }
      try {
        const response = await session.fetch(request);
        console.info('timeout--success', JSON.stringify(response));
        this.content = `timeout--success: ${JSON.stringify(response)}`;
      } catch (err) {
        console.error('timeout--err', JSON.stringify(err));
        this.content = `timeout--err: ${JSON.stringify(err)}`;
      } finally {
        session.close();
      }
    } catch (error) {
      console.error(`getTimeoutSyn createSession error: ${JSON.stringify(error)}`);
    }
  }
}