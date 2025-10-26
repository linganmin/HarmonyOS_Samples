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

import { authentication } from '@kit.AccountKit';
import { common, Want } from '@kit.AbilityKit';
import Logger from '../utils/Logger';
import { SubscribePage } from './SubscribePage';
import { BusinessError } from '@kit.BasicServicesKit';

const SUBSCRIBE_PAGE_NAME = 'subscribePage';

enum LoginState {
  INIT = 0,
  SUCCESS = 1,
  FAILED = 2,
}

@Entry({ useSharedStorage: true })
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();
  @LocalStorageLink('want') @Watch('handleWant') want: Want = {};
  @State loginState: LoginState = LoginState.INIT;

  @Builder
  TitleBuilder() {
    Row() {
      Text($r('app.string.MainAbility_desc'))
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
      if (this.loginState === LoginState.SUCCESS) {
        Text($r('app.string.logined'))
          .fontColor('#333333')
      } else if (this.loginState === LoginState.FAILED) {
        Button($r('app.string.login_btn'))
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .onClick(() => this.loginWithHuaweiID())
      }
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20,
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  PagesMap(name: string) {
    if (name === SUBSCRIBE_PAGE_NAME) {
      SubscribePage()
    }
  }

  build() {
    Navigation(this.pageStack) {
      Flex({ direction: FlexDirection.Column }) {
        Button({ type: ButtonType.Normal }) {
          Row() {
            Column() {
              Text($r('app.string.subscribe_title'))
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
        .onClick(() => this.goToSubscribePage())
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
    Logger.info('Page Index aboutToAppear');
    this.handleWant();
    this.loginWithHuaweiID();
  }

  private handleWant(): void {
    Logger.info('MainPage handleWant');
    // TODO: get data passed by REST API from want.parameters
    const data = this.want.parameters;
  }

  private async loginWithHuaweiID(): Promise<void> {
    try {
      const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
      loginRequest.forceLogin = true;
      loginRequest.state = Date.now().toString();
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const controller = new authentication.AuthenticationController(context);
      const rsp: authentication.LoginWithHuaweiIDResponse = await controller.executeRequest(loginRequest);

      if (rsp.state !== loginRequest.state) {
        Logger.error('Failed to login. Request state: %{public}s, response state: %{public}s', loginRequest.state,
          rsp.state!);
        this.loginState = LoginState.FAILED;
        return;
      }
      if (!rsp.data) {
        Logger.error('Failed to get the Huawei ID data');
        this.loginState = LoginState.FAILED;
        return;
      }

      Logger.info('Succeeded in logining');
      this.loginState = LoginState.SUCCESS;
      const openID = rsp.data.openID;
      // TODO: please send the openID to your application server
    } catch (e) {
      const err: BusinessError = e;
      Logger.error('Failed to login: %{public}d %{public}s', err.code, err.message);
      this.loginState = LoginState.FAILED;
    }
  }

  private goToSubscribePage(): void {
    this.pageStack.pushPathByName(SUBSCRIBE_PAGE_NAME, null);
  }
}