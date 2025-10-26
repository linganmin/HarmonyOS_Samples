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
import { PageConstant } from '../../constant/PageConstant';
import { ReturnHeader } from '../common/ReturnHeader';
import { MineConstants } from '../common/constants/MineConstants'

@HMRouter({pageUrl: PageConstant.MAIN_SETTING, singleton: true})
@Component
export struct MineSetting {
  @State accountLoginTel: string = '156****5163';

  build() {
    Flex({direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween}) {
      Column() {
        ReturnHeader({
          title: MineConstants.MINE_LOG_OUT_TITLE, returnFunc: () => {
            HMRouterMgr.popAsync({
              navigationId: this.queryNavigationInfo()?.navigationId
            });
          }
        })
          .margin({bottom: 20});
        Row() {
          Image($r('app.media.login_person'))
            .width(50)
            .height(50)
            .borderRadius('50%')
            .margin({left: 10, right: 10});

          Flex({direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceEvenly}) {
            Text(MineConstants.MINE_NAME)
              .fontWeight(FontWeight.Bold);
            Text(this.accountLoginTel)
              .fontColor($r('app.color.mine_setting_font_color'));
          }
          .height('50%');
        }
        .width('100%')
        .height(80)
        .margin({bottom: 10})
        .justifyContent(FlexAlign.Start);

        Flex({direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center}) {
          Row() {
            Image($r('app.media.icon_person'))
              .width(30)
              .margin({left: 10});
            Text(MineConstants.MINE_LOG_OUT_TEXT)
              .margin({left: 10, right: 15})
              .fontWeight(FontWeight.Bold);
          };

          Image($r('app.media.arrow_right3x'))
            .width(10)
            .margin({right: 10});
        }
        .width('95%')
        .height(60)
        .margin({left: 10, right: 10})
        .backgroundColor($r('app.color.mine_setting_flex_background_color'))
        .borderRadius(15);
      }

      Button(MineConstants.MINE_LOG_OUT_BUTTON)
        .width('95%')
        .margin(10)
        .fontColor($r('app.color.mine_setting_button_font_color'))
        .backgroundColor($r('app.color.mine_setting_button_background_color'))
        .onClick(() => {
          HMRouterMgr.to('ExitLogin')
            .withNavigation(this.queryNavigationInfo()?.navigationId)
            .onArrival(() => {
              console.log('===跳转成功');
            })
            .pushAsync()
        });
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.tab_background_color'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}