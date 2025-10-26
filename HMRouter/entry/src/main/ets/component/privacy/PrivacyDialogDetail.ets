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

import { HMLifecycle, HMLifecycleContext, HMRouter, HMRouterMgr, IHMLifecycle } from '@hadss/hmrouter';
import { PageConstant } from '../../constant/PageConstant';
import { LoginConstants } from '../common/constants/LoginConstants'

@HMLifecycle({ lifecycleName: 'privacyLifecycle', priority: 4 })
export class PrivacyLifecycle implements IHMLifecycle {
  onBackPressed(ctx: HMLifecycleContext): boolean {
    const targetName = HMRouterMgr.getCurrentParam() as string;

    HMRouterMgr.popAsync({
      param: targetName
    });
    return true;
  }
}

@HMRouter({
  pageUrl: PageConstant.PRIVACY_DIALOG_DETAIL,
  dialog: true,
  lifecycle: 'privacyLifecycle',
  animator:'PayCancelDialog'
})
@Component
export struct PrivacyDialogDetail {
  scroller: Scroller = new Scroller();

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0)')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

      Column() {
        Text(LoginConstants.PRIVACY_DIALOG_TITLE).fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 });
        Text(LoginConstants.PRIVACY_DIALOG_TEXT1)
          .fontSize(16)
          .margin({ top: 20 })
          .width('90%')
          .textAlign(TextAlign.Center);

        Scroll(this.scroller) {
          Text() {
            Span(LoginConstants.PRIVACY_DIALOG_TEXT2)
              .fontColor($r('app.color.privacy_dialog_font_color_1'));
            Span(LoginConstants.PRIVACY_DIALOG_TEXT3)
              .fontColor($r('app.color.privacy_dialog_font_color_2'))
              .onClick(() => {
                HMRouterMgr.to('privacyPage')
                  .withNavigation(this.queryNavigationInfo()?.navigationId)
                  .pushAsync()
              });
            Span('。')
              .fontColor($r('app.color.privacy_dialog_font_color_1'));
            Span('\n');
            Span(LoginConstants.PRIVACY_DIALOG_TEXT4)
              .fontColor($r('app.color.privacy_dialog_font_color_1'));
          }
          .fontSize(14)
          // .maxLines(6)
          // .textOverflow({overflow:TextOverflow.Ellipsis})
          .width('90%');
        }
        .scrollable(ScrollDirection.Vertical)
        .margin({ top: 20 });

        Row() {
          Button(LoginConstants.PRIVACY_DIALOG_LEFT_BUTTON, { buttonStyle: ButtonStyleMode.TEXTUAL })
            .onClick(() => {
              let targetName = HMRouterMgr.getCurrentParam() as string;
              HMRouterMgr.popAsync({
                navigationId: this.queryNavigationInfo()?.navigationId,
                param: targetName
              });
            })
            .margin({ top: 20, bottom: 20 })
            .width('45%')
            .fontColor($r('app.color.privacy_dialog_font_color_2'))
            .fontWeight(FontWeight.Bold);

          Divider()
            .vertical(true)
            .height(22)
            .color($r('app.color.app_page_background'))
            .opacity(0.3);

          Button(LoginConstants.PRIVACY_DIALOG_RIGHT_BUTTON, { buttonStyle: ButtonStyleMode.TEXTUAL })
            .onClick(() => {
              // 保存隐私同意标识
              AppStorage.setOrCreate('isPrivacy', true);
              HMRouterMgr.popAsync({ param: true });
            })
            .margin({ top: 20, bottom: 20 })
            .width('45%')
            .fontColor($r('app.color.privacy_dialog_font_color_2'))
            .fontWeight(FontWeight.Bold);
        };
      }
      .backgroundColor($r('app.color.privacy_dialog_background_color'))
      .borderRadius(40)
      .width('90%');
    };
  }
}