/*
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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

import { BusinessError } from '@kit.BasicServicesKit';
import { data, radio, observer } from '@kit.TelephonyKit';
import Logger from '../modle/Logger';
import DetailData from '../modle/DetailData';

const TAG: string = 'Index';
let detailData: DetailData = new DetailData();

class Value {
  state: data.DataConnectState = data.DataConnectState.DATA_STATE_UNKNOWN;
  network: radio.RadioTechnology = radio.RadioTechnology.RADIO_TECHNOLOGY_UNKNOWN;
}

@Entry
@Component
struct Index {
  @State subscribes: Array<Resource> = [
    $r('app.string.network_state_change'),
    $r('app.string.signal_info_change'),
    $r('app.string.cellular_data_connection_state_change'),
    $r('app.string.cellular_data_flow_change'),
    $r('app.string.sim_state_change')
  ];
  networkStateChangeCallback = (data: observer.NetworkState) => {
    Logger.info(TAG, `on networkStateChange, data: ${JSON.stringify(data)}`);
    detailData.networkState = data as observer.NetworkState;
  };
  signalInfoChangeCallback = (data: Array<radio.SignalInformation>) => {
    Logger.info(TAG, `on signalInfoChange, data: ${JSON.stringify(data)}`);
    detailData.signalInformation = data;
  };
  cellularDataConnectionStateChangeCallback = (data: Value) => {
    Logger.info(TAG, `on cellularDataConnectionStateChange, data: ${JSON.stringify(data)}`);
    detailData.dataConnectState = data.state;
    detailData.ratType = data.network;
  };
  cellularDataFlowChangeCallback = (data: data.DataFlowType) => {
    Logger.info(TAG, `on cellularDataFlowChange, data: ${JSON.stringify(data)}`);
    detailData.dataFlowType = data;
  };
  simStateChangeCallback = (data: observer.SimStateData) => {
    Logger.info(TAG, `on simStateChange, data: ${JSON.stringify(data)}`);
    detailData.simStateData = data;
  };

  onChangeCallback(index: number, isOn: boolean) {
    try {
      switch (index) {
        case 0:
          isOn ? observer.on('networkStateChange', this.networkStateChangeCallback) :
          observer.off('networkStateChange', this.networkStateChangeCallback);
          break;
        case 1:
          isOn ? observer.on('signalInfoChange', this.signalInfoChangeCallback) :
          observer.off('signalInfoChange', this.signalInfoChangeCallback);
          break;
        case 2:
          isOn ? observer.on('cellularDataConnectionStateChange', this.cellularDataConnectionStateChangeCallback) :
          observer.off('cellularDataConnectionStateChange', this.cellularDataConnectionStateChangeCallback);
          break;
        case 3:
          isOn ? observer.on('cellularDataFlowChange', this.cellularDataFlowChangeCallback) :
          observer.off('cellularDataFlowChange', this.cellularDataFlowChangeCallback);
          break;
        case 4:
          isOn ? observer.on('simStateChange', this.simStateChangeCallback) :
          observer.off('simStateChange', this.simStateChangeCallback);
          break;
        default:
          break;
      }
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `onChangeCallback failed, error code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    Column() {
      Row() {
        Text('observer')
          .fontSize(30)
          .fontColor(Color.White)
      }
      .width('100%')
      .height('8%')
      .padding({ left: 16 })
      .backgroundColor('#0D9FFB')

      List({ space: 20, initialIndex: 0 }) {
        ForEach(this.subscribes, (item: Resource, index) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize(20)
                .width('90%')
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: false })
                .size({ width: 28, height: 16 })
                .selectedColor('#0D9FFB')
                .onChange((isOn: boolean) => {
                  this.onChangeCallback(index, isOn);
                })
                .id('switch' + (index + 1))
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%')
            .margin({ bottom: 12 })
          }
          .width('100%')
        })
      }
      .width('100%')
      .height('70%')
      .padding({
        left: 10,
        right: 10
      })

      Button($r('app.string.details'))
        .id('seeDetails')
        .width('40%')
        .onClick(() => {
          Logger.info(TAG, `detailData is = ${JSON.stringify(detailData)}`);
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/Detail',
            params: {
              detailData: detailData
            }
          });
        })
    }
    .width('100%')
    .height('100%')
  }
}