/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

// [Start import_radio]
import { radio } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
// [End import_radio]
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function CellularNetworkQueryBuilder() {
  CellularNetworkQuery()
}

@Component
export struct CellularNetworkQuery {
  @State text: ResourceStr = '';
  @State textArea: string = '';

  // [Start get_network_status]
  getNetworkStatus() {
    radio.getNetworkState((err: BusinessError, data: radio.NetworkState) => {
      if (err) {
        hilog.error(0x0000, 'Sample', 'getNetworkState failed, callback: err->: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(0x0000, 'Sample', 'getNetworkState success, callback: data->: %{public}s', JSON.stringify(data));
      // [StartExclude get_network_status]
      this.textArea = `getNetworkState success, callback: data->${JSON.stringify(data)}`;
      // [EndExclude get_network_status]
    });
  }
  // [End get_network_status]

  // [Start get_signal_type]
  getSignalType() {
    let slotId: number = 0;
    radio.getSignalInformation(slotId, (err: BusinessError, data: Array<radio.SignalInformation>) => {
      if (err) {
        hilog.error(0x0000, 'Sample', 'getSignalInformation failed, callback: err->: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(0x0000, 'Sample', 'getSignalInformation success, callback: data->: %{public}s', JSON.stringify(data));
      let signalType = data[0]?.signalType;
      // [StartExclude get_signal_type]
      this.textArea = `signalType is: ${signalType}`;
      // [EndExclude get_signal_type]
    });
  }
  // [End get_signal_type]

  // [Start get_radio_status]
  getRadioStatus() {
    radio.isRadioOn((err: BusinessError, data: boolean) => {
      if (err) {
        hilog.error(0x0000, 'Sample', 'isRadioOn failed, callback: err->: %{public}s', JSON.stringify(err));
        // [StartExclude get_radio_status]
        this.textArea = `isRadioOn failed, callback: err->${JSON.stringify(err)}`;
        // [EndExclude get_radio_status]
        return;
      }
      hilog.info(0x0000, 'Sample', 'isRadioOn success, callback: data->: %{public}s', JSON.stringify(data));
      // [StartExclude get_radio_status]
      this.textArea = `isRadioOn success, callback: data->${JSON.stringify(data)}`;
      // [EndExclude get_radio_status]
    });
  }
  // [End get_radio_status]

  @Builder
  NavDestinationTitle() {
    Column() {
      Text($r('app.string.cellular_network_query'))
        .fontSize(20)
        .lineHeight(40)
        .fontWeight(700)
        .width('100%')
        .padding({ left: 12 })
    }
    .width('100%')
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text(this.text)
            .margin({ bottom: 12 })
            .textAlign(TextAlign.Start)
            .width('100%')
            .height(20)
          TextArea({ text: this.textArea })
            .width('100%')
            .height('45%')
            .focusable(false)
        }

        Column({ space: 12 }) {
          Button($r('app.string.get_network_status'))
            .onClick(() => {
              this.text = $r('app.string.current_network_status');
              this.getNetworkStatus();
            })
            .width('100%')
            .backgroundColor('#0A59F7')
          Button($r('app.string.check_current_network'))
            .onClick(() => {
              this.text = $r('app.string.current_network');
              this.getSignalType();
            })
            .width('100%')
            .backgroundColor('#0A59F7')
          Button($r('app.string.check_radio_status'))
            .onClick(() => {
              this.text = $r('app.string.radio_status');
              this.getRadioStatus();
            })
            .width('100%')
            .backgroundColor('#0A59F7')
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(16)
    }
    .title(this.NavDestinationTitle())
  }
}