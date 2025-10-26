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
import { ReturnHeader } from '../common/ReturnHeader';
import { PageConstant } from '../../constant/PageConstant';
import { LoginConstants } from '../common/constants/LoginConstants'

/**
 * privacy content
 */
@HMRouter({ pageUrl: PageConstant.PRIVACY_PAGE })
@Component
export struct PrivacyPageContent {

  build() {
    Column() {
      ReturnHeader({
        title: LoginConstants.PRIVACY_DETAIL_TITLE, returnFunc: () => {
          HMRouterMgr.popAsync({
            navigationId: this.queryNavigationInfo()?.navigationId
          });
        }
      });

      Column() {
        Image($r('app.media.public_ic_Privacy3x'))
          .width(35)
          .height(35)
          .margin(20);
        Text(LoginConstants.PRIVACY_DETAIL_TEXT1)
          .fontSize(20)
          .fontWeight(FontWeight.Bold);
        Text(LoginConstants.PRIVACY_DETAIL_TEXT2)
          .fontSize(14)
          .fontColor($r('app.color.privacy_dialog_font_color_1'))
          .margin({ top: 10 });
      };

      Text(LoginConstants.PRIVACY_DETAIL_TEXT3)
        .fontWeight(FontWeight.Bold)
        .maxLines(4)
        .textOverflow({overflow:TextOverflow.Ellipsis})
        .margin({ top: 25 })
        .width('90%');

      Column() {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start }) {
          Text(LoginConstants.PRIVACY_DETAIL_TEXT4).fontSize(15).fontColor($r('app.color.privacy_dialog_font_color_1'));
        }
        .margin({ left: 30 });

        List({ space: 15 }) {
          ForEach(LoginConstants.PRIVACY_DETAIL_INFO, (item: string) => {
            ListItem() {
              PrivacyItem({ description: item });
            };
          }, (item: string, index: number) => item + index);
        }
        .width('90%')
        .height('auto')
        .backgroundColor($r('app.color.privacy_dialog_background_color'))
        .padding(10)
        .margin({ top: 5 })
        .borderRadius(20)
        .divider({
          strokeWidth: 1,
          startMargin: 1,
          endMargin: 5,
          color: $r('app.color.common_background_1')
        });
      }.margin({ top: 20 });
    }
    .backgroundColor($r('app.color.common_background_1'))
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}

@Component
struct PrivacyItem {
  description: string = '';

  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Text(this.description)
        .maxLines(1)
        .textOverflow({overflow:TextOverflow.Ellipsis})
        .fontWeight(FontWeight.Bold);
      Image($r('app.media.arrow_right3x'))
        .height(30)
        .width(30)
        .objectFit(ImageFit.Contain);
    };
  }
}