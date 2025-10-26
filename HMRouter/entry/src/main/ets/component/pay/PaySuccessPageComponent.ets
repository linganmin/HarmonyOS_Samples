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

import { HMLifecycle, HMRouter, HMRouterMgr, IHMLifecycle } from '@hadss/hmrouter';
import { PageConstant } from '../../constant/PageConstant';
import { DetailConstants } from '../common/constants/DetailConstants';
import { ReturnHeader } from '../common/ReturnHeader';
import { PriceParamType } from './PayDialogContent';
import { PayConstants } from '../common/constants/PayConstants'

@Observed
export class ObservedModel {
  pageUrl: string = '';
}

@HMLifecycle({ lifecycleName: 'PaySuccessLifecycle' })
export class PaySuccessLifecycle implements IHMLifecycle {
  model: ObservedModel = new ObservedModel();

  onBackPressed(): boolean {
    HMRouterMgr.to('MainPage')
      .withNavigation('mainNavigationId')
      .withParam(0)
      .popAsync()
    return true;
  }
}

@HMRouter({ pageUrl: PageConstant.PAY_SUCCESS_PAGE_COMPONENT, lifecycle: 'PaySuccessLifecycle' })
@Component
export struct PaySuccessPageComponent {
  @StorageLink('currentIndex') currentIndex: number = 0;
  @State totalPrice: number = 0;
  pageUrl: string = '';
  @State model: ObservedModel | null =
    (HMRouterMgr.getCurrentLifecycleOwner()?.getLifecycle() as PaySuccessLifecycle).model;

  aboutToAppear(): void {
    let param = HMRouterMgr.getCurrentParam() as PriceParamType;
    this.totalPrice = param.totalPrice;
    this.pageUrl = param.pageUrl;
    this.model!.pageUrl = this.pageUrl;
  }

  build() {
    Stack() {
      ReturnHeader({
        title: PayConstants.PAY_SUCCESS_TITLE, returnFunc: () => {
          HMRouterMgr.to('MainPage')
            .withNavigation('mainNavigationId')
            .withParam(0)
            .popAsync()
        }
      });

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Column() {
          Image($r('app.media.checkmark3x'))
            .width(70)
            .height(60)
            .objectFit(ImageFit.Contain);
          Text(PayConstants.PAY_SUCCESS_TITLE)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 15 });
          Text(`${PayConstants.PAY_SUCCESS_TEXT} ￥ ${this.totalPrice}`)
            .fontSize(13)
            .fontColor($r('app.color.pay_success_font_color'))
            .margin({ top: 5 });
          Button(PayConstants.PAY_SUCCESS_BUTTON, { type: ButtonType.Capsule, buttonStyle: ButtonStyleMode.TEXTUAL })
            .margin({ top: 20 })
            .width('35%')
            .border({ width: 1, color: $r('app.color.pay_success_font_color') })
            .fontColor($r('app.color.pay_success_font_color'))
            .onClick(() => {
              this.currentIndex = 0;
              // [Start HMRouterMgr_pop]
              HMRouterMgr.to('MainPage')
                .withNavigation('mainNavigationId')
                .withParam(0)
                .pushAsync()
              // [End HMRouterMgr_pop]
            });
        };
      };
    }
    .backgroundColor($r('app.color.pay_background_color'))
    .height('100%')
    .width('100%')
    .alignContent(Alignment.Top)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}