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

import { BusinessError } from '@kit.BasicServicesKit';
import { pushService } from '@kit.PushKit';
import Logger from '../utils/Logger';

@Component
export struct GetTokenPage {
  @State showFlag: string = 'Click the button to get push token.';

  @Builder
  TitleBuilder() {
    Row() {
      Text($r('app.string.apply_token_title'))
    }
    .width('100%')
    .height('100%')
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column }) {
        Text(this.showFlag)
          .fontColor(Color.Blue)
          .width('80%')
          .margin({ left: '10%' })
        Flex({
          direction: FlexDirection.Column,
          justifyContent: FlexAlign.SpaceBetween
        }) {
          Button($r('app.string.apply_token_button'))
            .width('80%')
            .height(40)
            .margin({ left: '10%' })
            .backgroundColor('#fff38a07')
            .fontColor(Color.White)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .borderRadius(20)
            .onClick(() => this.getToken())
        }
        .height(144)
        .margin({ top: 36 })
      }
      .linearGradient({
        direction: GradientDirection.Top,
        repeating: true,
        colors: [['#FFFFFF', 0], ['#FFFFFF', 1]]
      })
      .height('100%')
      .width('100%')
    }.title(this.TitleBuilder)
  }

  private async getToken(): Promise<void> {
    try {
      const pushToken = await pushService.getToken();
      Logger.info('Get push token successfully');
      this.showFlag = 'Successfully got push token, please save it.';
      // TODO: please send the pushToken to your application server
    } catch (e) {
      this.showFlag = 'Failed to get push token, please check the error log!';
      const err: BusinessError = e;
      Logger.error('Failed to get push token: %{public}d %{public}s', err.code, err.message);
    }
  }
}