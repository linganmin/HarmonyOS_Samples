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

/**
 * 最佳实践：基于HMRouter路由框架的页面跳转开发实践
 */

import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { animatorTransitionBuilder } from './AnimatorTransition';
import { MineConstants } from '../common/constants/MineConstants';

@Component
export struct MineContent {
  static readonly jumpPageUrl: string = 'animatorTransition';
  @StorageLink('isLogin') isLogin: boolean = false;
  @State accountLoginTel: string = '156****5163';
  @LocalStorageLink('system') system: string = MineConstants.MINE_ANIMATION_TYPE1;

  aboutToAppear(): void {
    HMRouterMgr.registerPageBuilder({
      builder: wrapBuilder(animatorTransitionBuilder),
      pageUrl: MineContent.jumpPageUrl
    });
  }

  build() {
    Flex({direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween}) {
      Column() {
        Text(MineConstants.MINE_TITLE)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .margin({top: 60, left: 10, bottom: 20});
        Row() {
          // left: Login status display avatar, username, and user phone number, no login display 'Login Account'
          Row() {
            Image(this.isLogin ? $r('app.media.login_person') : $r('app.media.account_Login'))
              .width(this.isLogin ? 50 : 70)
              .height(this.isLogin ? 50 : 70)
              .borderRadius('50%')
              .margin({left: 10, right: 10});
            if(this.isLogin) {
              Flex({direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceEvenly}) {
                Text(MineConstants.MINE_NAME)
                  .fontWeight(FontWeight.Bold);
                Text(this.accountLoginTel)
                  .fontColor($r('app.color.mine_content_text_font_color'));
              };
            } else {
              Text(MineConstants.MINE_TEXT1)
                .fontSize(20)
                .fontWeight(FontWeight.Bold);
            }
          }
          .height('50%');

          // right: Login status display arrow, no login status display button
          Column() {
            if(this.isLogin) {
              Image($r('app.media.arrow_right3x'))
                .width(10)
                .margin({right: 10});
            } else {
              Button(MineConstants.MINE_BUTTON_TEXT)
                .width(150)
                .backgroundColor($r('app.color.mine_content_button_background_color'))
                .fontSize(14)
                .fontColor($r('app.color.mine_content_button_font_color'))
                .margin({right: 10})
                .onClick(() => {
                  HMRouterMgr.to('loginPage')
                    .withNavigation(this.queryNavigationInfo()?.navigationId)
                    .withParam(4)
                    .pushAsync()
                });
            }
          };
        }
        .width('95%')
        .height(100)
        .margin({left: 10, bottom: 10})
        .backgroundColor($r('app.color.mine_content_row_background_color'))
        .borderRadius(15)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          if(this.isLogin) {
            HMRouterMgr.to('MineSetting')
              .withNavigation(this.queryNavigationInfo()?.navigationId)
              .pushAsync()
          }
        });

        Flex({direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center}) {
          Text(MineConstants.MINE_TEXT2)
            .margin({left: 10})
            .fontWeight(FontWeight.Bold);
          Row() {
            Text(this.system)
              .fontColor($r('app.color.mine_content_text_font_color'));
            Image($r('app.media.arrow_right3x'))
              .width(10);
          }
          .margin({right: 10});
        }
        .width('95%')
        .height(60)
        .margin({left: 10})
        .backgroundColor($r('app.color.mine_content_flex_background_color'))
        .borderRadius(15)
        .onClick(() => {
          HMRouterMgr.to(MineContent.jumpPageUrl)
            .withNavigation(this.queryNavigationInfo()?.navigationId)
            .pushAsync()
        });
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start);

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.tab_background_color'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}