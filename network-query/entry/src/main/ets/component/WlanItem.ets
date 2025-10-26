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

import { CustomContentDialog } from '@kit.ArkUI';
import { wifiManager } from '@kit.ConnectivityKit';
import { Logger } from '../common/Logger';

const TAG = 'WlanItemView';

@Component
export struct WlanItemView {
  @Prop currentLinkedSsid: string = '';
  ssid: string = '';
  securityType: number = 3;
  wifiPassword: string = '';

  // [Start connect_target_wifi_step]
  connectWifi() {
    // Add a candidate network
    let config: wifiManager.WifiDeviceConfig = {
      ssid: this.ssid,
      preSharedKey: this.wifiPassword,
      securityType: this.securityType
    }

    try {
      wifiManager.addCandidateConfig(config).then(result => {
        Logger.info(TAG, `addCandidateConfig success, networkId: ${result}`);
        // Connect to a certain wifi
        wifiManager.connectToCandidateConfig(result);
      });
    } catch (err) {
      Logger.error(TAG, `connectWifi error: ${JSON.stringify(err)}`);
    }
  }
  // [End connect_target_wifi_step]

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: this.ssid,
      contentBuilder: () => {
        this.buildContent();
      },
      buttons: [
        {
          value: $r('app.string.btn_cancel'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
        },
        {
          value: $r('app.string.btn_confirm'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.connectWifi();
          }
        }
      ],
    }),
    autoCancel: false
  });

  // Customize the content area of the pop-up box
  @Builder
  buildContent(): void {
    Column() {
      TextInput({ placeholder: $r('app.string.placeholder_input_password') })
        .type(InputType.Password)
        .showUnderline(true)
        .onChange((value: string) => {
          this.wifiPassword = value;
        })
    }
    .width('100%')
  }

  build() {
    Row() {
      Image($r('app.media.wlan'))
        .width(24)
        .aspectRatio(1)
        .fillColor($r('sys.color.ohos_id_color_primary'))

      Column() {
        Text(this.ssid)
          .fontSize(16)
          .lineHeight(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentLinkedSsid === this.ssid ? $r('sys.color.brand') : $r('sys.color.font_primary'))
          .align(Alignment.Start)
        Text(this.currentLinkedSsid === this.ssid ? $r('app.string.wifi_stated_connected') : $r('app.string.wifi_stated_encrypt'))
          .fontWeight(FontWeight.Regular)
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 16 })

      Blank()

      Image($r('app.media.info_circle'))
        .width(24)
        .aspectRatio(1)
    }
    .height(56)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .width('100%')
    .padding({
      left: 12,
      right: 12
    })
    .onClick(() => {
      this.dialogController.open();
    })
  }
}