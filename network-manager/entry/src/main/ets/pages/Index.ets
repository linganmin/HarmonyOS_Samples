/*
 *
 *  * Copyright (c) 2023 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the 'License');
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an 'AS IS' BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';
import { CommonConstant as Const } from '../common/Constant';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State networkId: ResourceStr = $r('app.string.network_id');
  @State netMessage: ResourceStr = $r('app.string.init_net_message');
  @State connectionMessage: ResourceStr = $r('app.string.init_connection_message');
  @State netStateMessage: ResourceStr = '';
  @State hostName: string = '';
  @State ip: ResourceStr = '';
  private controller: TabsController = new TabsController();
  private netHandle: connection.NetHandle | undefined = undefined;
  private netCon: connection.NetConnection | undefined = undefined;
  private myResourceManager: resourceManager.ResourceManager = this.getUIContext().getHostContext()!.resourceManager;
  scroller: Scroller = new Scroller();

  aboutToDisappear(): void {
    this.unUseNetworkRegister;
  }

  build() {
    Column() {
      Text($r('app.string.network_title'))
        .fontSize($r('app.float.title_font_size'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .margin({ left: Const.WebConstant_TEN_PERCENT })
        .width(Const.WebConstant_FULL_WIDTH)

      Tabs({ controller: this.controller }) {
        TabContent() {
          Column() {
            Scroll() {
              Column() {
                Row() {
                  Column() {
                    Text($r('app.string.check_network'))
                      .fontSize($r('app.float.font_size'))
                      .padding({ top: $r('app.float.md_padding_margin'), left: $r('app.float.md_padding_margin') })
                      .fontWeight(FontWeight.Bold)
                      .align(Alignment.Start)
                      .width(Const.WebConstant_FULL_WIDTH)
                    Text(this.networkId)
                      .fontSize($r('app.float.font_size'))
                      .padding($r('app.float.md_padding_margin'))
                      .align(Alignment.Start)
                      .opacity($r('app.float.opacity'))
                      .width(Const.WebConstant_FULL_WIDTH)
                  }
                  .width(Const.WebConstant_SEVENTY_PERCENT)

                  Column() {
                    Button($r('app.string.check'))
                      .fontSize($r('app.float.sm_font_size'))
                      .height(Const.WebConstant_BUTTON_HEIGHT)
                      .margin({ top: $r('app.float.md_padding_margin') })
                      .width(Const.WebConstant_BUTTON_SMALL_WIDTH)
                      .buttonStyle(ButtonStyleMode.NORMAL)
                      .onClick(() => {
                        this.isNetworkAccess();
                      })
                  }
                  .align(Alignment.TopStart)
                  .height(Const.WebConstant_FULL_HEIGHT)
                  .width(Const.WebConstant_THIRTY_PERCENT)
                }
                .borderRadius($r('app.float.md_border_radius'))
                .margin({ left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })
                .width(Const.WebConstant_NINETY_PERCENT)
                .height(Const.WebConstant_TWELVE_PERCENT)
                .backgroundColor($r('app.color.text_background'))

                Row() {
                  Column() {
                    Text($r('app.string.network_detail'))
                      .fontSize($r('app.float.font_size'))
                      .padding({
                        top: $r('app.float.md_padding_margin'),
                        left: $r('app.float.md_padding_margin')
                      })
                      .fontWeight(FontWeight.Bold)
                      .height(Const.WebConstant_FORTY_PERCENT)
                      .width(Const.WebConstant_FULL_WIDTH)
                    Text(this.netMessage)
                      .fontSize($r('app.float.font_size'))
                      .padding($r('app.float.md_padding_margin'))
                      .opacity($r('app.float.opacity'))
                      .height(Const.WebConstant_SIXTY_PERCENT)
                      .width(Const.WebConstant_FULL_WIDTH)
                  }
                  .width(Const.WebConstant_SEVENTY_PERCENT)
                  .align(Alignment.TopStart)

                  Column() {
                    Button($r('app.string.detail'))
                      .fontSize($r('app.float.sm_font_size'))
                      .height(Const.WebConstant_BUTTON_HEIGHT)
                      .margin({ top: $r('app.float.md_padding_margin') })
                      .width(Const.WebConstant_BUTTON_SMALL_WIDTH)
                      .buttonStyle(ButtonStyleMode.NORMAL)
                      .onClick(() => {
                        this.getNetworkMessage();
                      })
                  }
                  .align(Alignment.TopStart)
                  .height(Const.WebConstant_FULL_HEIGHT)
                  .width(Const.WebConstant_THIRTY_PERCENT)
                }
                .borderRadius($r('app.float.md_border_radius'))
                .margin($r('app.float.md_padding_margin'))
                .width(Const.WebConstant_NINETY_PERCENT)
                .height(Const.WebConstant_FIFTEEN_PERCENT)
                .backgroundColor($r('app.color.text_background'))

                Row() {
                  Column() {
                    Text($r('app.string.network_connection_detail'))
                      .fontSize($r('app.float.font_size'))
                      .padding($r('app.float.md_padding_margin'))
                      .fontWeight(FontWeight.Bold)
                      .width(Const.WebConstant_FULL_WIDTH)
                      .align(Alignment.Start)
                    Text(this.connectionMessage)
                      .fontSize($r('app.float.font_size'))
                      .opacity($r('app.float.opacity'))
                      .width(Const.WebConstant_NINETY_PERCENT)
                      .align(Alignment.Start)
                  }
                  .width(Const.WebConstant_SEVENTY_PERCENT)
                  .justifyContent(FlexAlign.Start)

                  Column() {
                    Button($r('app.string.detail'))
                      .fontSize($r('app.float.sm_font_size'))
                      .height(Const.WebConstant_BUTTON_HEIGHT)
                      .margin({ top: $r('app.float.md_padding_margin') })
                      .width(Const.WebConstant_BUTTON_SMALL_WIDTH)
                      .buttonStyle(ButtonStyleMode.NORMAL)
                      .onClick(() => {
                        this.getConnectionProperties();
                      })
                  }
                  .width(Const.WebConstant_THIRTY_PERCENT)
                }
                .alignItems(VerticalAlign.Top)
                .borderRadius($r('app.float.md_border_radius'))
                .margin({
                  left: $r('app.float.md_padding_margin'),
                  right: $r('app.float.md_padding_margin'),
                  bottom: $r('app.float.xl_padding_margin')
                })
                .width(Const.WebConstant_NINETY_PERCENT)
                .backgroundColor($r('app.color.text_background'))

              }
              .alignItems(HorizontalAlign.Start)
            }
          }
          .height(Const.WebConstant_FULL_HEIGHT)
          .alignItems(HorizontalAlign.Start)
        }.tabBar($r('app.string.first_tabs_bar'))

        TabContent() {
          Column() {
            Search({ placeholder: $r('app.string.search_placeholder') })
              .margin({
                left: $r('app.float.md_padding_margin'),
                right: $r('app.float.md_padding_margin')
              })
              .width(Const.WebConstant_NINETY_PERCENT)
              .searchButton($r('app.string.search_button'))
              .onSubmit((value: string) => {
                this.hostName = value;
                this.parseHostName(this.hostName);
              })

            TextArea({ text: this.ip })
              .fontSize($r('app.float.lg_font_size'))
              .width(Const.WebConstant_NINETY_PERCENT)
              .height(Const.WebConstant_FIFTY_PERCENT)
              .margin({ top: $r('app.float.md_padding_margin') })
              .borderRadius($r('app.float.md_border_radius'))
              .focusOnTouch(false)
          }
          .height(Const.WebConstant_FULL_HEIGHT)
          .justifyContent(FlexAlign.Start)
        }
        .tabBar($r('app.string.second_tabs_bar'))

        TabContent() {
          Column() {
            Row() {
              Text($r('app.string.monitor_title'))
                .fontSize($r('app.float.font_size'))
                .margin($r('app.float.md_padding_margin'))
                .fontWeight(FontWeight.Medium)
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: false })
                .selectedColor(Color.Blue)
                .margin({ right: $r('app.float.md_padding_margin') })
                .width($r('app.float.area_width'))
                .height(Const.WebConstant_BUTTON_HEIGHT)
                .onChange((isOn) => {
                  if (isOn) {
                    this.useNetworkRegister();
                  } else {
                    this.unUseNetworkRegister();
                  }
                })
            }
            .height($r('app.float.button_height'))
            .borderRadius($r('app.float.md_border_radius'))
            .margin({ left: $r('app.float.md_padding_margin'), right: $r('app.float.md_padding_margin') })
            .width(Const.WebConstant_NINETY_PERCENT)
            .backgroundColor($r('app.color.text_background'))

            TextArea({ text: this.netStateMessage })
              .fontSize($r('app.float.font_size'))
              .width(Const.WebConstant_NINETY_PERCENT)
              .height(Const.WebConstant_FIVE_HUNDRED)
              .margin($r('app.float.md_padding_margin'))
              .borderRadius($r('app.float.md_border_radius'))
              .textAlign(TextAlign.Start)
              .focusOnTouch(false)

            Button($r('app.string.clear'))
              .fontSize($r('app.float.font_size'))
              .width(Const.WebConstant_NINETY_PERCENT)
              .height($r('app.float.area_height'))
              .margin({
                left: $r('app.float.md_padding_margin'),
                right: $r('app.float.md_padding_margin'),
                bottom: $r('app.float.xxl_padding_margin')
              })
              .onClick(() => {
                this.netStateMessage = '';
              })
            Blank()
          }
          .height(Const.WebConstant_FULL_HEIGHT)
          .justifyContent(FlexAlign.Start)

        }.tabBar($r('app.string.third_tabs_bar_three'))
      }
      .barWidth(Const.WebConstant_EIGHTY_PERCENT)
    }
    .width(Const.WebConstant_FULL_WIDTH)
  }

  isNetworkAccess() {
    connection.hasDefaultNet((error: BusinessError) => {
      try {
        if (error) {
          this.networkId = $r('app.string.network_error');
          hilog.error(0x0000, 'Index', 'hasDefaultNet error:' + error.message);
          return;
        }
        this.netHandle = connection.getDefaultNetSync();
        this.networkId =
          this.myResourceManager.getStringSync($r('app.string.network_id').id) + JSON.stringify(this.netHandle);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'Index', `isNetworkAccess failed, error code=${err.code}, message=${err.message}`);
      }
    })
  }

  getNetworkMessage() {
    if (this.netHandle) {
      try {
        connection.getNetCapabilities(this.netHandle, (error, netCap) => {
          if (error) {
            this.netMessage = this.myResourceManager.getStringSync($r('app.string.network_type_error').id);
            hilog.error(0x0000, 'Index', 'getNetCapabilities error:' + error.message);
            return;
          }
          let netType = netCap.bearerTypes;
          for (let i = 0; i < netType.length; i++) {
            if (netType[i] === 0) {
              this.netMessage = this.myResourceManager.getStringSync($r('app.string.cellular_network').id);
            } else if (netType[i] === 1) {
              this.netMessage = this.myResourceManager.getStringSync($r('app.string.wifi_network').id);
            } else {
              this.netMessage = this.myResourceManager.getStringSync($r('app.string.other_network').id);
            }
          }
          this.netMessage += 'networkCap:' + JSON.stringify(netCap.networkCap) + '\n';
        })
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'Index', `getNetworkMessage failed, error code=${err.code}, message=${err.message}`);
      }
    }
  }

  getConnectionProperties() {
    try {
      connection.getDefaultNet().then((netHandle: connection.NetHandle) => {
        connection.getConnectionProperties(netHandle,
          (error: BusinessError, connectionProperties: connection.ConnectionProperties) => {
            if (error) {
              this.connectionMessage = $r('app.string.connection_properties_error');
              hilog.error(0x0000, 'Index', 'getConnectionProperties error:' + error.code + error.message);
              return;
            }
            this.connectionMessage =
              this.myResourceManager.getStringSync($r('app.string.connection_properties_interface_name').id) +
              connectionProperties.interfaceName
                + this.myResourceManager.getStringSync($r('app.string.connection_properties_domains').id) +
              connectionProperties.domains
                + this.myResourceManager.getStringSync($r('app.string.connection_properties_link_addresses').id) +
              JSON.stringify(connectionProperties.linkAddresses)
                + this.myResourceManager.getStringSync($r('app.string.connection_properties_routes').id) +
              JSON.stringify(connectionProperties.routes)
                + this.myResourceManager.getStringSync($r('app.string.connection_properties_link_addresses').id) +
              JSON.stringify(connectionProperties.dnses)
                + this.myResourceManager.getStringSync($r('app.string.connection_properties_mtu').id) +
              connectionProperties.mtu + '\n';
          })
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'Index', `getDefaultNet failed, error code=${err.code}, message=${err.message}`);
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index', `getConnectionProperties failed, error code=${err.code}, message=${err.message}`);
    }
  }

  parseHostName(hostName: string) {
    this.ip = '';
    connection.getAddressesByName(hostName).then((data) => {
      for (let i = 0; i < data.length; i++) {
        this.ip += data[i].address + '\n';
      }
    })
      .catch((error: BusinessError) => {
        this.ip = $r('app.string.get_addresses_error');
        hilog.error(0x0000, 'Index', 'getAddressesByName error:' + error.message);
      })
  }

  useNetworkRegister() {
    try {
      this.netCon = connection.createNetConnection();
      this.netStateMessage += this.myResourceManager.getStringSync($r('app.string.register_network_listener').id);
      this.netCon.register((error) => {
        if (error) {
          hilog.error(0x0000, 'Index', 'register error:' + error.message);
          return;
        }
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.register_network_listener_message'),
          duration: 1000
        });
      })
      this.netCon.on('netAvailable', (netHandle) => {
        this.netStateMessage += this.myResourceManager.getStringSync($r('app.string.net_available').id) +
        netHandle.netId + '\n';
      })
      this.netCon.on('netBlockStatusChange', (data) => {
        this.netStateMessage += this.myResourceManager.getStringSync($r('app.string.net_block_status_change').id) +
        data.netHandle.netId + '\n';
      })
      this.netCon.on('netCapabilitiesChange', (data) => {
        this.netStateMessage += this.myResourceManager.getStringSync($r('app.string.net_capabilities_change_id').id) +
        data.netHandle.netId
          + this.myResourceManager.getStringSync($r('app.string.net_capabilities_change_cap').id) +
        JSON.stringify(data.netCap) + '\n';
      })
      this.netCon.on('netConnectionPropertiesChange', (data) => {
        this.netStateMessage += this.myResourceManager.getStringSync($r('app.string.net_connection_properties_change_id')
          .id) +
        data.netHandle.netId
          + this.myResourceManager.getStringSync($r('app.string.net_connection_change_connection_properties').id) +
        JSON.stringify(data.connectionProperties) +
          '\n';
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index', `useNetworkRegister failed, error code=${err.code}, message=${err.message}`);
    }
  }

  unUseNetworkRegister() {
    try {
      if (this.netCon) {
        this.netCon.unregister((error: BusinessError) => {
          if (error) {
            hilog.error(0x0000, 'Index', 'unregister error:' + error.message);
            return;
          }
          this.getUIContext().getPromptAction().showToast({
            message: this.myResourceManager.getStringSync($r('app.string.unregister_network_listener_message').id),
            duration: 1000
          });
          this.netStateMessage += this.myResourceManager.getStringSync($r('app.string.unregister_network_listener').id);
        })
      } else {
        this.netStateMessage += this.myResourceManager.getStringSync($r('app.string.unregister_network_listener_fail')
          .id);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index', `unUseNetworkRegister failed, error code=${err.code}, message=${err.message}`);
    }
  }
}
