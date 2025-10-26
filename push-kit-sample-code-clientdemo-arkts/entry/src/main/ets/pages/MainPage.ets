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

import { Want } from '@kit.AbilityKit';
import Logger from '../utils/Logger';
import { GetTokenPage } from './GetTokenPage';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TOKEN_PAGE_NAME = 'pushToken';

@Entry({ useSharedStorage: true })
@Component
struct MainPage {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();
  @LocalStorageLink('want') @Watch('handleWant') want: Want = {};

  @Builder
  PagesMap(name: string, param: Object) {
    if (name === TOKEN_PAGE_NAME) {
      GetTokenPage()
    }
  }

  @Builder
  TitleBuilder() {
    Row() {
      Text($r('app.string.MainAbility_desc'))
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
      Button($r('app.string.clear_badge'))
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .onClick(() => this.clearBadge())
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Navigation(this.pageStack) {
      Flex({ direction: FlexDirection.Column }) {
        Button({ type: ButtonType.Normal }) {
          Row() {
            Column() {
              Text($r('app.string.apply_token_title'))
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Black)
                .decoration({
                  type: TextDecorationType.Underline,
                  color: '#0A59F7'
                })
            }
            .width(190)
            .height('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ left: 20, top: 50 })

            Column() {
              Image($r("app.media.push"))
                .width(100)
                .height(100)
            }
            .padding({ left: 30, top: 5 })
          }
          .width('100%')
          .height(140)
        }
        .width('90%')
        .height(140)
        .margin({ top: '21%', left: '5%' })
        .backgroundColor('#fff8f1e3')
        .borderRadius(24)
        .onClick(() => this.goToTokenPage())
      }
      .linearGradient({
        direction: GradientDirection.Top,
        repeating: true,
        colors: [['#FFFFFF', 0], ['#FFFFFF', 1]]
      })
      .height('100%')
      .width('100%')
    }
    .mode(NavigationMode.Stack)
    .title(this.TitleBuilder)
    .navDestination(this.PagesMap)
  }

  aboutToAppear(): void {
    Logger.info('MainPage aboutToAppear');
    this.handleWant();
  }

  private handleWant(): void {
    Logger.info('MainPage handleWant');
    // TODO: get data passed by REST API from want.parameters
    const data = this.want.parameters;
  }

  private goToTokenPage(): void {
    this.pageStack.pushPathByName(TOKEN_PAGE_NAME, null);
  }

  private async clearBadge(): Promise<void> {
    try {
      await notificationManager.setBadgeNumber(0);
      Logger.info('Succeed in clearing badge number');
    } catch (e) {
      const err: BusinessError = e;
      Logger.error('Failed to clear badge number: %{public}d %{public}s', err.code, err.message);
    }
  }
}