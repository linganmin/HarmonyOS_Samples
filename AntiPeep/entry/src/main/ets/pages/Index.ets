/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { ItemInfo } from '../common/models/ItemInfo';
import { ConstValues } from '../common/CommonConstants';
import { dlpAntiPeep } from '@kit.DeviceSecurityKit';
import {
  AntiPeepCallback,
  canUseAntiPeep,
  getAntiPeepInfo,
  isAntiPeepOn,
  listenOffAntiPeepStatus,
  listenOnAntiPeepStatus
} from '../common/utils/AntiPeepUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CustomListItem } from '../view/CustomItemInfo';
import { ContentSubTitle, Title } from '../view/Titles';

@Entry
@Component
struct Index {
  @State summaryMoney: ResourceStr = ConstValues.MONEY;
  @State summaryEarnings: ResourceStr = ConstValues.BENEFIT;
  @State itemInfos: ItemInfo[] = [new ItemInfo(), new ItemInfo(), new ItemInfo()];
  private isListenOn: boolean = false;
  private antiPeepCB: AntiPeepCallback = {
    onStatusChanged: (status: dlpAntiPeep.DlpAntiPeepStatus): void => {
      this.handleAntiPeepStatus(status);
    }
  };

  /*
  * is the privacy information of the item hidden
  * */
  itemsEnableShow(enableShow: boolean) {
    if (enableShow) {
      this.itemInfos[0].nameString = ConstValues.FLEXIBLE_ACCESS;
      this.itemInfos[0].valueString = ConstValues.MONEY;
      this.itemInfos[0].resultString = ConstValues.BENEFIT;
      this.itemInfos[0].resultColor = $r('app.color.color_benefit');

      this.itemInfos[1].nameString = ConstValues.STABLE_FINANCIAL_MANAGEMENT;
      this.itemInfos[1].valueString = ConstValues.DEFAULT_MONEY;
      this.itemInfos[1].resultString = ConstValues.DEFAULT_BENEFIT;

      this.itemInfos[2].nameString = ConstValues.ADVANCED_FINANCIAL_MANAGEMENT;
      this.itemInfos[2].valueString = ConstValues.DEFAULT_MONEY;
      this.itemInfos[2].resultString = ConstValues.DEFAULT_BENEFIT;
    } else {
      this.itemInfos[0].nameString = ConstValues.FLEXIBLE_ACCESS;
      this.itemInfos[0].valueString = ConstValues.DEFAULT_HIDE_INFO;
      this.itemInfos[0].resultString = ConstValues.DEFAULT_HIDE_INFO;
      this.itemInfos[0].resultColor = $r('app.color.color_benefit');

      this.itemInfos[1].nameString = ConstValues.STABLE_FINANCIAL_MANAGEMENT;
      this.itemInfos[1].valueString = ConstValues.DEFAULT_HIDE_INFO;
      this.itemInfos[1].resultString = ConstValues.DEFAULT_HIDE_INFO;

      this.itemInfos[2].nameString = ConstValues.ADVANCED_FINANCIAL_MANAGEMENT;
      this.itemInfos[2].valueString = ConstValues.DEFAULT_HIDE_INFO;
      this.itemInfos[2].resultString = ConstValues.DEFAULT_HIDE_INFO;
    }
  }

  summaryShow(enableShow: boolean) {
    if (enableShow) {
      this.summaryMoney = ConstValues.MONEY;
      this.summaryEarnings = ConstValues.BENEFIT;
    } else {
      this.summaryMoney = ConstValues.DEFAULT_HIDE_INFO;
      this.summaryEarnings = ConstValues.DEFAULT_HIDE_INFO;
    }
  }

  /*
  * handle screen privacy status
  * */
  private handleAntiPeepStatus(status: dlpAntiPeep.DlpAntiPeepStatus) {
    hilog.info(0x0000, 'IndexPage', `[handleAntiPeepStatus] ${status}`);
    switch (status) {
      case dlpAntiPeep.DlpAntiPeepStatus.PASS:
        this.summaryShow(true);
        this.itemsEnableShow(true);
        break;
      case dlpAntiPeep.DlpAntiPeepStatus.HIDE:
        this.summaryShow(false);
        this.itemsEnableShow(false);
        break;
      default:
        this.summaryShow(true);
        this.itemsEnableShow(true);
        break;
    }
  }

  initAntiPeepStatus() {
    if (canUseAntiPeep()) {
      isAntiPeepOn().then((opened) => {
        if (opened) {
          let info = getAntiPeepInfo();
          this.handleAntiPeepStatus(info);
          this.isListenOn = listenOnAntiPeepStatus(this.antiPeepCB);
        } else {
          try {
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.anti_peep_not_enable')
            })
          } catch (error) {
            hilog.info(0x0000, 'IndexPage', `show toast error:${JSON.parse(error)}}`);
          }
        }
      })
    } else {
      try {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.device_not_supported')
        })
      } catch (error) {
        hilog.info(0x0000, 'IndexPage', `show toast error:${JSON.parse(error)}}`);
      }
    }
  }

  initData() {
    this.itemsEnableShow(true);
    this.summaryShow(true);
    this.initAntiPeepStatus();
  }

  onPageShow(): void {
    this.initData();
  }

  aboutToDisappear(): void {
    if (this.isListenOn) {
      listenOffAntiPeepStatus()
      this.isListenOn = false;
    }
  }

  build() {
    Scroll() {
      Column() {
        Title()
        Column() {
          ContentSubTitle()
          Row() {
            Text($r('app.string.my_assets'))
              .fontSize($r('app.float.size_14fp'))
              .height($r('app.float.size_19vp'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.font_on_secondary'))
            Blank()
            Text($r('app.string.yesterday_earnings'))
              .fontSize($r('app.float.size_14fp'))
              .height($r('app.float.size_19vp'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.font_on_secondary'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .padding({
            left: $r('app.float.size_12vp'),
            top: $r('app.float.size_16vp'),
            right: $r('app.float.size_12vp')
          })

          Row() {
            Text(this.summaryMoney)
              .fontSize($r('app.float.size_24fp'))
              .fontWeight(FontWeight.Regular)
              .fontColor(Color.White)
              .height($r('app.float.size_32vp'))
            Blank()
            Text(this.summaryEarnings)
              .fontSize($r('app.float.size_24fp'))
              .fontColor(Color.White)
              .fontWeight(FontWeight.Regular)
              .height($r('app.float.size_32vp'))
          }
          .justifyContent(FlexAlign.Start)
          .width('100%')
          .padding({
            left: $r('app.float.size_12vp'),
            bottom: $r('app.float.size_16vp'),
            right: $r('app.float.size_12vp')
          })

          Column() {
            ForEach(this.itemInfos, (__itemInfo: ItemInfo, index: number) => {
              CustomListItem({
                itemInfo: this.itemInfos[index]
              })
              if (index < this.itemInfos.length - 1) {
                Divider().height('1px')
              }
            }, (itemInfo: ItemInfo, index: number) => {
              return itemInfo.nameString + index.toString();
            })
          }
          .backgroundColor(Color.White)
          .padding({
            left: $r('app.float.size_12vp'),
            right: $r('app.float.size_12vp'),
            top: $r('app.float.size_4vp'),
            bottom: $r('app.float.size_4vp')
          })
          .borderRadius($r('app.float.size_16vp'))
          .margin({
            top: $r('app.float.size_8vp'),
          })
        }
        .backgroundColor($r('app.color.bg_money_main'))
        .borderRadius($r('app.float.content_margin'))
        .padding({
          left: $r('app.float.content_padding'),
          right: $r('app.float.content_padding'),
          bottom: $r('app.float.content_padding')
        })
        .margin({
          top: $r('app.float.size_8vp')
        })
      }
      .backgroundColor($r('app.color.bg_main'))
      .margin({
        left: $r('sys.float.corner_radius_level8'),
        right: $r('sys.float.corner_radius_level8'),
      })
      .constraintSize({
        minHeight: '100%'
      })
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.bg_main'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}