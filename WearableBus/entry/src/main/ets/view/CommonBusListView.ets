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

import { CommonConstants } from '../common/CommonConstants'
import { BusStationModel } from '../model/BusStationModel';
import { BusStationViewModel } from '../viewmodel/BusStationViewModel';
import { display } from '@kit.ArkUI';
import { updateScale } from '../util/ScaleUtil';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct CommonBusListView {
  @Prop type: number;
  @Prop busName: Resource;
  @State nearbyBusStation: Array<BusStationModel> = [];
  @State nowBusStationDes: Array<BusStationModel> = [];
  @State scrollY: number = 0;
  @State scaleNum: number = 1;
  @State screenHeight: number = 0;
  public goBusDes: (name: Resource) => void = () => {
  };
  private busStationViewModel: BusStationViewModel = new BusStationViewModel();

  aboutToAppear(): void {
    try {
      this.screenHeight = display.getDefaultDisplaySync().height;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'CommonBusListView', `getDefaultDisplaySync failed. code=${err.code}, message=${err.message}`);
    }
    if (this.type === 0) {
      this.nearbyBusStation = this.busStationViewModel.getNearbyBusStation();
      return;
    }
    this.nowBusStationDes = this.busStationViewModel.getNowBusDes();
  }

  @Builder
  itemHead() {
    Column() {
      Text(this.type === 0 ? $r('app.string.btn_nearby_bus') : $r('app.string.now_bus_station'))
        .fontSize(19)
        .lineHeight(25)
        .fontWeight(700)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .margin({ top: 17 })
        .width(CommonConstants.FULL_PERCENT)
      Text(this.type === 0 ? $r('app.string.three_bus_station') : this.busName)
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(400)
        .lineHeight(25)
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 12 })
    }
  }

  build() {
    Scroll() {
      Column() {
        this.itemHead();
        List() {
          ForEach(this.type === 0 ? this.nearbyBusStation : this.nowBusStationDes,
            (bus: BusStationModel, index: number) => {
              ListItem() {
                if (this.type === 0) {
                  nearbyBusListItem({
                    nearbyBus: bus,
                    screenHeight: this.screenHeight,
                    goBusDes: (name: Resource) => {
                      this.goBusDes(name);
                    }
                  })
                } else {
                  nowBusStation({
                    nowBusNum: bus,
                    index: index,
                    screenHeight: this.screenHeight
                  });
                }
              }
            }, (nearbyBus: BusStationModel) => nearbyBus.id)
        }
        .margin({ top: 12 })
        .scrollBar(BarState.Off)
        .width(CommonConstants.FULL_PERCENT)
      }
    }
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}

@Component
export struct nearbyBusListItem {
  @Prop nearbyBus: BusStationModel;
  @Prop screenHeight: number;
  @State scaleMid: number = 1;
  private maxScale = 1;
  private minScale = 0.8;
  public goBusDes: (name: Resource) => void = () => {
  };

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.nearbyBus.busStationName)
            .fontSize(20)
            .fontWeight(500)
            .lineHeight(27)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor(Color.White)
            .textAlign(TextAlign.Start)
            .margin({ left: 13 })
            .width(160)
          Row({ space: 8 }) {
            station({ name: this.nearbyBus.busNumber[0] });
            station({ name: this.nearbyBus.busNumber[1] });
          }
          .margin({ top: 5 })
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 8 })

        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(24)
          .fontColor(['#A8FFFFFF'])
          .margin({ left: 8 })
      }
      .width(224)
      .height(81)
      .borderRadius(28)
      .backgroundColor('#26FFFFFF')
      .onClick(() => {
        this.goBusDes(this.nearbyBus.busStationName);
      })
      .scale({ x: this.scaleMid, y: this.scaleMid })
      .onAreaChange((_: Area, newValue: Area) => {
        this.scaleMid = Math.max(this.minScale, Math.min(this.maxScale,
          updateScale(this.getUIContext(), this.screenHeight, newValue)));
      })
    }
    .width
    (CommonConstants.FULL_PERCENT)
  }
}

@Component
export struct nowBusStation {
  @Prop nowBusNum: BusStationModel;
  @Prop index: number;
  @Prop screenHeight: number;
  @State scaleMid: number = 1;
  private maxScale = 1;
  private minScale = 0.8;

  build() {
    Column() {
      Column() {
        Row() {
          station({ name: this.nowBusNum.busNumber[this.index] })
          Text($r('app.string.station_time'))
            .fontSize(18)
            .lineHeight(24)
            .fontWeight(500)
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor('#DB6B42')
            .margin({ left: 30, right: 12 })
        }
        .width(CommonConstants.FULL_PERCENT)

        Row() {
          Text($r('app.string.direction'))
            .fontSize(16)
            .lineHeight(21)
            .fontWeight(400)
            .fontColor($r('sys.color.font_on_secondary'))
          Text($r('app.string.Road'))
            .fontSize(16)
            .lineHeight(21)
            .fontWeight(400)
            .fontColor(Color.White)
            .margin({ left: 12 })
          Text($r('app.string.distance'))
            .fontSize(16)
            .lineHeight(21)
            .fontWeight(400)
            .fontColor(Color.White)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ left: 18 })
            .layoutWeight(1)
        }
        .margin({ top: 8 })
        .width(CommonConstants.FULL_PERCENT)
        .padding({ right: 12 })
      }
      .width(224)
      .height(81)
      .borderRadius(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#26FFFFFF')
      .padding({
        left: 12,
        right: 12
      })
      .scale({ x: this.scaleMid, y: this.scaleMid })
      .onAreaChange((_: Area, newValue: Area) => {
        this.scaleMid = Math.max(this.minScale, Math.min(this.maxScale,
          updateScale(this.getUIContext(), this.screenHeight, newValue)));
      })
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}

@Component
export struct station {
  @Prop name: Resource;

  build() {
    Column() {
      Text(this.name)
        .fontSize(16)
        .fontWeight(400)
        .lineHeight(21)
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .justifyContent(FlexAlign.Center)
    .width(63)
    .height(32)
    .borderRadius(8)
    .backgroundColor('#317AF7')
  }
}