/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UserInfo } from '../common/UserInfo';

const logTag: string = 'ShoppingPage';
const domainId: number = 0x0000;

@Component
export struct ShoppingPage {
  cards: number[] = [152, 152, 152, 152, 152, 152, 152, 152];
  @StorageLink('minorsProtectionMode') minorsProtectionMode: boolean = false;
  @StorageLink('availableTimeMode') availableTimeMode: boolean = true;
  @StorageLink('silentLoginMap') silentLoginMap: Map<string, UserInfo> = new Map<string, UserInfo>([]);
  @Prop mainBoxPadding: number;

  aboutToAppear() {
    hilog.info(domainId, logTag, 'aboutToAppear');
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          ForEach(this.cards, (item: number) => {
            Card(item)
          }, (item: number, index: number) => `${item}_${index}`)
        }
      }.padding({ left: this.mainBoxPadding, right: this.mainBoxPadding })
    }
  }
}

@Builder
function Card(cardHeight: number) {
  Row() {
  }
  .margin({ top: 12 })
  .padding({ left: 16, right: 16 })
  .height(cardHeight)
  .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
  .borderRadius(20)
  .width('100%')
}