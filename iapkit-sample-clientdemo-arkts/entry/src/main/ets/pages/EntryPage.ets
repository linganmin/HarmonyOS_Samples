/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */
import { router } from '@kit.ArkUI'

@Entry
@Component
struct EntryPage {
  private vpValue = this.getUIContext().px2vp(136);
  pageStack: NavPathStack = new NavPathStack();
  aboutToAppear() {
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Column() {
        }
        .backgroundColor('#F1F3F5')
        .width("100%")
        .height(this.vpValue)

        Column() {
          CustomButton({ mText: 'Consumables', mName: 'ConsumablesPage', pageStack: this.pageStack });

          CustomButton({ mText: 'NonConsumables', mName: 'NonConsumablesPage', pageStack: this.pageStack });

          CustomButton({ mText: 'Subscriptions', mName: 'SubscriptionsPage', pageStack: this.pageStack });

          CustomButton({ mText: 'NonRenewables', mName: 'NonRenewablesPage', pageStack: this.pageStack });
        }
        .padding({ left: 24, right: 24 })
        .width('100%')
        .height('100%')
        .backgroundColor('#F1F3F5')
      }
    }.hideTitleBar(true)
  }
}

@Component
export struct CustomButton {
  private mText: string = '';
  private mName: string = '';
  private pageStack: NavPathStack = new NavPathStack();
  private mOnClick: ((event?: object) => void) | null = null

  build() {
    Button() {
      Text(this.mText)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
    }
    .id(this.mText)
    .type(ButtonType.Capsule)
    .margin({ top: 12 })
    .width('100%')
    .height(40)
    .backgroundColor('#0D9FFB')
    .onClick((event) => {
      if (this.mOnClick) {
        this.mOnClick(event);
        return;
      }
      this.pageStack.pushPath({ name: this.mName });
    })
  }
}