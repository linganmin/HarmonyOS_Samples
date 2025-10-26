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

import { BusinessError } from '@kit.BasicServicesKit';
import { wifiManager } from '@kit.ConnectivityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../common/constants/Constants';
import { InfoItemView } from './InfoItemView';

@Component
export struct DetailInfoView {
  @Consume linkedInfo: wifiManager.WifiLinkedInfo | undefined;
  pageInfos: NavPathStack = new NavPathStack();
  wlanSsid: string = '';
  ipInfo: wifiManager.IpInfo | undefined = undefined;

  aboutToAppear(): void {
    try {
      this.ipInfo = wifiManager.getIpInfo();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'DetailInfoView', `getIpInfo failed, error code=${err.code}, message=${err.message}`);
    }
  }

  @Builder
  customDivider() {
    Divider()
      .strokeWidth(Constants.DIVIDER_STROKE_WIDTH)
      .color($r('sys.color.ohos_id_color_list_separator'))
      .margin({
        left: $r('app.float.divider_stroke_margin_left'),
        right: $r('app.float.divider_stroke_margin_left')
      })
  }

  ipToDottedDecimal(ip: number): string {
    const dottedDecimal: string = [
      (ip >>> 24) & 0xFF,
      (ip >>> 16) & 0xFF,
      (ip >>> 8) & 0xFF,
      ip & 0xFF
    ].join('.');
    return dottedDecimal;
  }

  build() {
    NavDestination() {
      Row() {
        Column() {
          InfoItemView({ title: $r('app.string.mac_address'), msg: this?.linkedInfo?.macAddress })
          this.customDivider()

          InfoItemView({
            title: $r('app.string.ip_address'),
            msg: this.ipToDottedDecimal(this?.linkedInfo?.ipAddress as number)
          })
          this.customDivider()

          InfoItemView({ title: $r('app.string.net_mask'), msg: this.ipToDottedDecimal(this.ipInfo!.netmask) })
          this.customDivider()

          InfoItemView({ title: $r('app.string.gate_way'), msg: this.ipToDottedDecimal(this.ipInfo!.gateway) })
          this.customDivider()

          InfoItemView({ title: $r('app.string.dns'), msg: this.ipToDottedDecimal(this.ipInfo!.primaryDns) })
        }
        .width(Constants.FULL_PERCENT)
        .borderRadius($r('app.float.detail_border_radius'))
        .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
        .margin({ top: $r('app.float.detail_margin_top') })
      }
      .padding({
        top: $r('app.float.detail_padding_top'),
        bottom: $r('app.float.detail_padding_top'),
        left: $r('app.float.detail_padding_left'),
        right: $r('app.float.detail_padding_left')
      })
    }
    .title(this.wlanSsid)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack
    })
    .backgroundColor($r('app.color.page_background_color'))
  }
}

@Builder
export function DetailInfoBuilder(name: string, param: string) {
  DetailInfoView({ wlanSsid: param })
}