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

//Please replace the network address during testing.
const kHttpServerAddress = 'https://example.com';
const TEST_REQUEST_URL = '/test';

@Entry
@Component
struct BaseAddress {
  @State content: string = '';

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Row() {
        Text('BaseAddress')
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

      Column() {
        Text('Base url:')
          .fontColor('#ff100f0f')
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
        Text(kHttpServerAddress)
          .fontColor('#ff100f0f')
          .fontSize(14)
        Text('The request url:')
          .fontColor('#ff100f0f')
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
        Text(TEST_REQUEST_URL)
          .width('100%')
          .fontColor('#ff100f0f')
          .fontSize(14)

        Button('BaseAddress-Test')
          .width('80%')
          .height(40)
          .margin({ left: '10%' })
          .backgroundColor('#0A59F7')
          .fontColor(Color.White)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .borderRadius(20)
          .onClick(this.getTokenSyn)
          .alignSelf(ItemAlign.Center)
          .margin({ top: 10 })
      }.width('100%')
      .padding(15)
      .alignItems(HorizontalAlign.Start)

      Column() {
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
        }
        .width('100%')
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .backgroundColor('#F3F3F3')
        .borderRadius(10)
      }
      .layoutWeight(1)
      .padding(15)
      .alignItems(HorizontalAlign.Start)
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
   * Example method for configuring the base address.
   */
  private getTokenSyn = async () => {
    try {
      const session = rcp.createSession({
        baseAddress: kHttpServerAddress
      });
      try {
        // Input relative address.
        const resp = await session.get(TEST_REQUEST_URL);
        this.content = `Url: \n${resp.request.url.toString()}\n\nResponse: \n${resp.toString()}`;
        console.info(`Url: ${resp.request.url.toString()}, getTokenSyn succeeded: ${resp.toString()}`);
      } catch (err) {
        this.content = `Failed: ${JSON.stringify(err)}`;
        console.error(this.content);
      } finally {
        session.close();
      }
    } catch (error) {
      console.error(`getTokenSyn createSession error: ${JSON.stringify(error)}`);
    }
  }
}