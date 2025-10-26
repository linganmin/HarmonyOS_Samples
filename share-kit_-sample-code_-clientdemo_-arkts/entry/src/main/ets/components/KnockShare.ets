/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { DeviceTypeChecker } from '../utils/DeviceTypeChecker';
import Logger from '../utils/Logger';

let logger = Logger.getLogger('[KnockShare]');

@Component
export default struct KnockShare {
  @Consume('pageStack') pageStack: NavPathStack;
  @State message: ResourceStr = $r('app.string.knock_title');

  @Builder
  KnockExplain() {
    Column() {
      Text($r('app.string.precautions'))
        .width('100%')
        .fontSize(18)
        .lineHeight(20)

      Text($r('app.string.knock_precautions_1'))
        .width('100%')
        .fontSize(16)
        .lineHeight(20)

      Text($r('app.string.knock_precautions_2'))
        .width('100%')
        .fontSize(16)
        .lineHeight(20)

      Text($r('app.string.knock_precautions_3'))
        .width('100%')
        .fontSize(16)
        .lineHeight(20)
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder
  KnockNavigationItem(title: ResourceStr, pageName: string) {
    Row() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Button('体验')
        .onClick(() => {
          if (pageName === 'KnockShareSandbox' && !DeviceTypeChecker.isPC()) {
            try {
              const uiContext: UIContext = this.getUIContext();
              uiContext.getPromptAction().showToast({ message: $r('app.string.only_pc_supported') });
            } catch (error) {
              logger.error(`showToast error. Code: ${error?.code}, message: ${error?.message}`);
            }
            return;
          }
          this.pageStack.pushPath({ name: pageName });
        })
    }
    .width('100%')
    .margin({ top: 12 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Text(this.message)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .margin({ bottom: 12 })

        this.KnockExplain();

        this.KnockNavigationItem('可碰分享提示', 'KnockShareTips');

        this.KnockNavigationItem('接口示例', 'KnockShareApi');

        this.KnockNavigationItem('属性示例', 'KnockShareAttr');

        this.KnockNavigationItem('卡片模板示例', 'KnockShareCard');

        this.KnockNavigationItem('直达应用沙箱', 'KnockShareSandbox');
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
  }
}