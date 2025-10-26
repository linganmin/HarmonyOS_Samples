/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { ApiUtil } from '../common/GameApi';

@Entry
@Component
struct Index {
  @State buttonSize: number = 18;
  @State buttonWidth: string = '50%';
  @State textWidth: string = '100%';
  @State buttonHeight: number = 35;
  @State fontColor: string = '#FFFFFF';
  @State buttonRadius: number = 10;
  @State message: string = 'Game Service Demo';
  scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        Text(this.message)
          .fontSize(20)
          .margin({ top: 40, bottom: 10 })
        List({ space: 0 }) {
          // Switch to another account.
          ListItem() {
            Row() {
              Button({ type: ButtonType.Normal }) {
                Text($r('app.string.Switch_account'))
                  .width(this.textWidth)
                  .fontColor(this.fontColor)
                  .fontSize(this.buttonSize)
                  .height(this.buttonHeight)
                  .textAlign(TextAlign.Center)
              }
              .width(this.buttonWidth)
              .borderRadius(this.buttonRadius)
              .margin({ right: 5, left: -2.5, top: 20 })
              .onClick(() => {
                hilog.info(0x0000, 'testTag', 'Test account change.');
                // This click event is primarily used to simulate game sign-in account switching, and it needs to trigger the pop-up for multi-provider sign-in.
                let context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
                new ApiUtil().unionLogin(context);
              });
            }.width(this.textWidth)
            .padding({ left: 30, right: 30 })
            .justifyContent(FlexAlign.Center)
          }.width(this.textWidth)
          .margin({ bottom: 5 })
        }
      }
    }.scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.On)
    .edgeEffect(EdgeEffect.None)
  }
}
