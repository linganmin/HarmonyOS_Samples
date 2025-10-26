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

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { wifiManager } from '@kit.ConnectivityKit';
import { Constants } from '../common/constants/Constants';
import Logger from '../common/utils/Logger';
import { WlanItemView } from '../view/WlanItemView';

const TAG: string = '[WlanQuery]';

@Entry
@Component
struct Index {
  @State scanInfoList: Array<wifiManager.WifiScanInfo> = [];
  @Provide linkedInfo: wifiManager.WifiLinkedInfo | undefined = undefined;
  @Provide pageInfos: NavPathStack = new NavPathStack();
  @State wifiState: number = 0;
  @State wifiConnectionState: number = 0;
  @State ssid: string = '';
  private timer: number = 0;

  @Builder
  CustomDivider() {
    Divider()
      .strokeWidth(Constants.DIVIDER_STROKE_WIDTH)
      .color($r('sys.color.ohos_id_color_list_separator'))
      .margin({
        left: $r('app.float.divider_stroke_margin_left'),
        right: $r('app.float.divider_stroke_margin_left')
      })
  }

  aboutToAppear(): void {
    try {
      window.getLastWindow(this.getUIContext().getHostContext(), (error: BusinessError, data: window.Window) => {
        if (error) {
          Logger.error(TAG, `getLastWindow failed, error code=${error.code}, message=${error.message}`);
          return;
        }
        data.setWindowBackgroundColor(Constants.PAGE_BACKGROUND_COLOR);
      });
    } catch (exception) {
      let err = exception as BusinessError;
      Logger.error(TAG, `getLastWindow failed, catch error code=${err.code}, message=${err.message}`);
    }

    this.watchState();

    try {
      this.wifiState = wifiManager.isWifiActive() ? Constants.WIFI_ACTIVE : 0;
      this.wifiConnectionState = wifiManager.isConnected() ? Constants.WLAN_CONNECTED : 0;
    } catch (exception) {
      let err = exception as BusinessError;
      Logger.error(TAG, `wifiManager function failed, catch error code=${err.code}, message=${err.message}`);
    }

    if (this.wifiState === Constants.WIFI_ACTIVE) {
      this.getScanInfo();
      this.getLinkedInfo();
    }

    this.timer = setInterval(() => {
      if (this.wifiState === Constants.WIFI_ACTIVE) {
        this.getScanInfo();
      }
    }, Constants.SCAN_WLAN_DURATION);
  }

  watchState(): void {
    try {
      wifiManager.on('wifiStateChange', (result: number) => {
        this.wifiState = result;
        if (this.wifiState === 0) {
          this.linkedInfo = undefined;
          this.scanInfoList = [];
        }
        if (this.wifiState === Constants.WIFI_ACTIVE) {
          this.getScanInfo();
        }
      });

      wifiManager.on('wifiConnectionChange', (result: number) => {
        this.wifiConnectionState = result;
        if (this.wifiConnectionState === Constants.WLAN_CONNECTED) {
          this.getLinkedInfo();
        } else {
          this.linkedInfo = undefined;
          this.ssid = '';
        }
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `wifiManager on failed, error code=${err.code}, message=${err.message}`);
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.timer);
    try {
      wifiManager.off('wifiStateChange');
      wifiManager.off('wifiConnectionChange');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `wifiManager off failed, error code=${err.code}, message=${err.message}`);
    }
  }

  getScanInfo(): void {
    try {
      let temp = wifiManager.getScanInfoList();
      if (temp.length > 0) {
        this.scanInfoList = this.uniqueBySsid(temp);
      }
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getScanInfoList failed, error code=${err.code}, message=${err.message}`);
    }
  }

  getLinkedInfo(): void {
    wifiManager.getLinkedInfo((err, data) => {
      if (err) {
        Logger.error(TAG, `get linked info error code=${err.code}, message=${err.message}`);
        return;
      }
      this.linkedInfo = data;
      this.ssid = this.linkedInfo.ssid;
      Logger.info(TAG, 'get wifi linked info: ' + JSON.stringify(data));
    });
  }

  uniqueBySsid(arr: Array<wifiManager.WifiScanInfo>): Array<wifiManager.WifiScanInfo> {
    const set = new Set<string>();
    return arr.filter((item) => {
      const key = item.ssid;
      if (!set.has(key)) {
        set.add(key);
        return true;
      }
      return false;
    });
  }

  build() {
    Navigation(this.pageInfos) {
      Scroll() {
        List({ space: Constants.LIST_SPACE }) {
          ListItem() {
            Column() {
              Text($r('app.string.wlanConnected'))
                .fontSize($r('app.float.title_font_size'))
                .fontColor($r('app.color.title_font_color'))
                .width(Constants.FULL_PERCENT)
                .padding({ left: $r('app.float.title_padding_left') })

              if (!!this.linkedInfo && this.wifiConnectionState === Constants.WLAN_CONNECTED) {
                WlanItemView({
                  itemDesc: this.ssid,
                  content: $r('app.string.connected'),
                  src: $r('app.media.wlan'),
                  isLinkAddress: true,
                  targetPage: this.linkedInfo !== undefined ? this.linkedInfo.ssid : ''
                })
                  .margin({ top: $r('app.float.connect_margin_top') })
                  .width(Constants.FULL_PERCENT)
                  .borderRadius($r('app.float.connect_border_radius'))
                  .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
                  .padding({
                    top: $r('app.float.connect_padding_top'),
                    bottom: $r('app.float.connect_padding_top')
                  })
              }
            }
          }

          ListItem() {
            Column() {
              Row() {
                Text($r('app.string.wlanUseful'))
                  .fontSize($r('app.float.title_font_size'))
                  .fontColor($r('app.color.title_font_color'))
                  .padding({ left: $r('app.float.title_padding_left') })
              }
              .width(Constants.FULL_PERCENT)

              if (this.scanInfoList.length > 0) {
                Column() {
                  List() {
                    ForEach(this.scanInfoList, (item: wifiManager.WifiScanInfo, index: number) => {
                      if (item.ssid && item.ssid !== this.linkedInfo?.ssid) {
                        ListItem() {
                          Column() {
                            WlanItemView({
                              itemDesc: item.ssid,
                              content: $r('app.string.useless'),
                              src: $r('app.media.wlan')
                            })
                            if (index !== this.scanInfoList.length - 1) {
                              this.CustomDivider()
                            }
                          }
                        }
                      }
                    }, (item: wifiManager.WifiScanInfo, index: number) => index + JSON.stringify(item.ssid))
                  }
                }
                .width(Constants.FULL_PERCENT)
                .borderRadius($r('app.float.useful_border_radius'))
                .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
                .padding({
                  top: $r('app.float.useful_padding_top'),
                  bottom: $r('app.float.useful_padding_top')
                })
                .margin({ top: $r('app.float.useful_margin_top') })
              }
            }
          }
        }
        .padding({
          left: $r('app.float.page_padding_left'),
          right: $r('app.float.page_padding_left')
        })
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
      }
      .margin({ top: $r('app.float.page_margin_top') })
    }
    .title($r('app.string.wlan'))
    .backgroundColor($r('app.color.page_background_color'))
  }
}