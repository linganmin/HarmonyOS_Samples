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

import { CommonConstants } from '../common/CommonConstants';
import { LocationUtil } from '../util/LocationUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct CommonHomeView {
  @State locationMessage: string =
    this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.home_page_get_location').id);
  @State locationIcon?: Resource = $r('sys.symbol.arrow_2_circlepath');
  @Prop type: number;
  public goNearbyBus: () => void = () => {
  };
  public goWhere: () => void = () => {
  };
  public goHomeOrCompany: () => void = () => {

  };

  async aboutToAppear(): Promise<void> {
    this.updateLocation();
  }

  @Builder
  homeIcon(index: number) {
    Column() {
      Column() {
        SymbolGlyph(index === 0 ? $r('sys.symbol.circle_below_local_filled') : $r('sys.symbol.bus_fill'))
          .fontColor([Color.White])
          .fontSize(24)
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#1F71FF')
      .width(52)
      .height(52)
      .borderRadius(26)

      Text(index === 0 ? $r('app.string.btn_nearby_bus') : $r('app.string.btn_go_where'))
        .fontWeight(500)
        .lineHeight(26)
        .fontSize(15)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .width(CommonConstants.FULL_PERCENT)
        .height(26)
    }
    .width(60)
    .onClick(() => {
      if (index === 0) {
        this.goNearbyBus();
      } else {
        this.goWhere();
      }
    })
  }

  @Builder
  goWhereIcon(index: number) {
    Row() {
      Column() {
        SymbolGlyph(index === 0 ? $r('sys.symbol.house_fill') : $r('sys.symbol.briefcase_fill'))
          .fontSize(20)
          .fontColor([Color.White])
      }
      .justifyContent(FlexAlign.Center)
      .width(30)
      .height(30)
      .borderRadius(15)
      .backgroundColor(index === 0 ? '#ED6F21' : '#1F71FF')
      .margin({ left: 8 })

      Column() {
        Text(index === 0 ? $r('app.string.btn_go_home') : $r('app.string.btn_go_work'))
          .fontSize(16)
          .fontWeight(400)
          .lineHeight(21)
          .textAlign(TextAlign.Start)
          .fontColor(Color.White)
        Text($r('app.string.station'))
          .fontSize(12)
          .fontWeight(400)
          .lineHeight(16)
          .textAlign(TextAlign.Start)
          .fontColor('#A8FFFFFF')
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .margin({ left: 8 })
      .layoutWeight(1)
    }
    .width(178)
    .height(52)
    .borderRadius(50)
    .backgroundColor('#26FFFFFF')
    .margin({ top: index === 0 ? 0 : 8 })
    .onClick(() => {
      this.goHomeOrCompany();
    })
  }

  @Builder
  itemHead() {
    Column() {
      Text($r('app.string.btn_go_where'))
        .fontSize(19)
        .lineHeight(25)
        .fontWeight(700)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .margin({ top: 17 })
        .width(CommonConstants.FULL_PERCENT)
    }
  }

  build() {
    Column() {
      if (this.type === 1) {
        this.itemHead();
      }
      Row() {
        SymbolGlyph(this.locationIcon)
          .fontColor([Color.White])
          .fontSize(16)
          .visibility(this.locationIcon === undefined ? Visibility.Hidden : Visibility.Visible)
        Text(this.locationMessage)
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(400)
          .lineHeight(25)
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ left: 5 })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(25)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .padding({
        left: 16,
        right: 16
      })
      .margin({ top: this.type === 1 ? 12 : 0 })
      .onClick(() => {
        this.locationMessage = '';
        this.locationIcon = undefined;
        this.updateLocation();
      })

      if (this.type === 0) {
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceEvenly }) {
          this.homeIcon(0);
          this.homeIcon(1);
        }
        .width(CommonConstants.FULL_PERCENT)
        .margin({ top: 24 })
      } else {
        Column() {
          this.goWhereIcon(0);
          this.goWhereIcon(1);
        }
        .width(CommonConstants.FULL_PERCENT)
        .margin({ top: 12 })
      }
    }
    .layoutWeight(1)
  }

  async updateLocation(): Promise<void> {
    let location: string = await LocationUtil.updateLocation(this.getUIContext().getHostContext()!);
    if (location) {
      this.locationMessage = location;
      this.locationIcon = $r('sys.symbol.local');
      return;
    }
    try {
      this.locationMessage =
        this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.home_page_get_location').id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'CommonHomeView', `getResourceString failed. code=${err.code}, message=${err.message}`);
    }
    this.locationIcon = $r('sys.symbol.arrow_2_circlepath');
  }
}