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
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { PayConstants } from '../common/constants/PayConstants'

@Builder
export function payDialogContentBuilder(totalPrice: number) {
  Column() {
    Text(PayConstants.PAY_CARD_TEXT1)
      .fontSize(15)
      .fontColor($r('app.color.pay_dialog_text_font_color_1'))
      .margin({ top: 40 });

    Text() {
      Span('￥')
        .fontWeight(FontWeight.Bold);
      Span(`${totalPrice}`)
        .fontSize(30)
        .fontWeight(FontWeight.Bold);
    }
    .margin({ top: 5 });

    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Image($r('app.media.ic_appicon_wallet3x'))
            .height(30)
            .width(30)
            .objectFit(ImageFit.Contain);
          Text(PayConstants.PAY_CARD_TEXT2)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 10 });
        };

        Image($r('app.media.Radio_Unselected_Enabled3x'))
          .height(20)
          .width(20);
      };

      Text(PayConstants.PAY_CARD_TEXT3)
        .fontSize(15)
        .fontColor($r('app.color.pay_dialog_text_font_color_1'))
        .margin({ top: 20, bottom: 20 });
    }
    .borderRadius(20)
    .backgroundColor($r('app.color.pay_dialog_item_background_color'))
    .padding({ top: 20, left: 10, right: 10 })
    .margin({ top: 40 })
    .width('90%');
  };
}

export interface PriceParamType {
  totalPrice: number;
  pageUrl: string;
}

// [Start HMRouter_lifecycle]
@HMRouter({
  pageUrl: 'PayDialogContent',
  dialog: true,
  lifecycle: 'ExitPayDialog',
  interceptors: ['LoginCheckInterceptor']
})
@Component
export struct PayDialogContent {
  // [StartExclude HMRouter_lifecycle]
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @State totalPrice: number = 0;
  pageUrl: string = '';

  aboutToAppear(): void {
    let param = HMRouterMgr.getCurrentParam() as PriceParamType;
    this.totalPrice = param.totalPrice;
    this.pageUrl = param.pageUrl;
    let model = (HMRouterMgr.getCurrentLifecycleOwner()?.getLifecycle() as ExitPayDialog).model;
    model.pageUrl = this.pageUrl;
  }

  build() {
    Column() {
      // header
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.End }) {
        Image($r('app.media.ic_bottomsheet_close3x'))
          .width(30)
          .height(30)
          .objectFit(ImageFit.Contain)
          .margin({ top: 20, right: 20 })
          .onClick(() => {
            // HMRouterMgr.push({
            //   navigationId: this.queryNavigationInfo()?.navigationId,
            //   pageUrl: 'PayCancel',
            //   param: this.pageUrl
            // });
            HMRouterMgr.to('PayCancel')
              .withNavigation(this.queryNavigationInfo()?.navigationId)
              .withParam(this.pageUrl)
              .pushAsync()
          });
      };

      // center/content
      Column() {
        payDialogContentBuilder(this.totalPrice);
      }
      .height('75%');

      // footer
      Button(PayConstants.PAY_CARD_BUTTON, { type: ButtonType.Capsule })
        .onClick(() => {
          HMRouterMgr.to('PaySuccessPageComponent')
            .withNavigation(this.queryNavigationInfo()?.navigationId)
            .withParam({totalPrice: this.totalPrice, pageUrl: this.pageUrl})
            .pushAsync()
        })
        .width('90%')
        .backgroundColor($r('app.color.pay_dialog_button_background_color'))
        .height(40)
        .margin(12);
    }
    .backgroundColor($r('app.color.pay_background_color'))
    .borderRadius(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? { topLeft: 20, topRight: 20 } : 20)
    .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? '100%' : '72%')
    .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? '80%' : '72%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .position({
      bottom:0
    })
  }

  // [EndExclude HMRouter_lifecycle]
}

// [End HMRouter_lifecycle]


@HMLifecycle({ lifecycleName: 'ExitPayDialog' })
export class ExitPayDialog implements IHMLifecycle {
  model: ObservedModel = new ObservedModel();

  onBackPressed(): boolean {
    HMRouterMgr.to('PayCancel')
      .withParam(this.model.pageUrl)
      .pushAsync()
    return true;
  }
}

// [Start exit_pay_lifecycle]
@HMLifecycle({ lifecycleName: 'ExitPayLifecycle' })
export class ExitPayLifecycle implements IHMLifecycle {
  model: ObservedModel = new ObservedModel();

  onBackPressed(): boolean {
    HMRouterMgr.to('PayCancel')
      .withParam(this.model.pageUrl)
      .pushAsync()
    return true;
  }
}

// [End exit_pay_lifecycle]

export class ObservedModel {
  pageUrl: string = '';
}