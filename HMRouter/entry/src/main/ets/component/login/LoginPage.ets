/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { PageConstant } from '../../constant/PageConstant';
import { LoginConstants } from '../../component/common/constants/LoginConstants';

@HMRouter({pageUrl: PageConstant.LOGIN_PAGE, dialog: true,animator:'PayCardDialog'})
@Component
export struct LoginPage {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;

  handleLogin() {
    let targetName = HMRouterMgr.getCurrentParam() as number;
    AppStorage.setOrCreate('isLogin', true);
    if(targetName) {
      HMRouterMgr.to('MainPage')
        .withNavigation(this.queryNavigationInfo()?.navigationId)
        .withParam(targetName)
        .withAnimator(false)
        .replaceAsync()
    } else {
      HMRouterMgr.pop({animator: false});
    }
  }

  build() {
    Flex({direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween}) {
      Column() {
        Row() {
          Image($r('app.media.ic_bottomsheet_close3x'))
            .width(30)
            .height(30)
            .objectFit(ImageFit.Contain)
            .margin({top: 20, right: 20})
            .onClick(() => {
              HMRouterMgr.popAsync({
                navigationId: this.queryNavigationInfo()?.navigationId
              });
            });
        }
        .width('100%')
        .margin(10)
        .justifyContent(FlexAlign.End);

        Flex({direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center}) {
          Image($r('app.media.icon_login'))
            .width(50)
            .margin(10);
          Text(LoginConstants.LOGIN_TEXT)
            .fontSize(30)
            .fontWeight(FontWeight.Bold);
        }
        .margin({bottom: 20})
        .height(120);

        Flex({direction: FlexDirection.Column, justifyContent: FlexAlign.Start}) {
          TextInput({placeholder: LoginConstants.LOGIN_PLACEHOLDER1, text: LoginConstants.LOGIN_INPUT_TEXT})
            .width('95%')
            .height(60)
            .backgroundColor($r('app.color.login_text_input_background_color'))
            .margin(10);
          TextInput({placeholder: LoginConstants.LOGIN_PLACEHOLDER2, text: '156****5163'})
            .width('95%')
            .height(60)
            .backgroundColor($r('app.color.login_text_input_background_color'))
            .margin(10)
            .type(InputType.Password);
        }
        .height('30%');
      };

      Button(LoginConstants.LOGIN_BUTTON)
        .width('90%')
        .height($r('app.float.pay_button_height'))
        .fontColor($r('app.color.login_button_font_color'))
        .backgroundColor($r('app.color.login_button_background_color'))
        .margin({left: 15, right: 10, bottom: 15})
        .onClick(() => {
          if(!!AppStorage.get('isPrivacy')) {
            this.handleLogin();
          } else {
            HMRouterMgr.to('PrivacyDialogDetail')
              .withNavigation(this.queryNavigationInfo()?.navigationId)
              .onResult((info)=>{
                if(info.result) { // 同意隐私协议
                  console.log('is agree');
                }
              })
              .pushAsync()
          }
        });
    }
    .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? '100%' : '72%')
    .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? '95%' : '72%')
    .backgroundColor($r('app.color.login_flex_background_color'))
    .border({
      radius: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? {topLeft: 20, topRight: 20} : 20
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}

