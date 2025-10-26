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
import { socket } from '@kit.NetworkKit';
import { SocketInfo, TransmitInfo } from '../model/TransmitInfo';
import { CommonConstants } from '../constants/CommonConstants';
import Logger from '../utils/Logger';

@Entry
@Component
struct ServerSocketPage {
  @State transmitInfo: TransmitInfo = new TransmitInfo('', '', '', 0, 0);
  @State inputMessage: string = '';
  @State isSend: boolean = false;
  @State isListen: boolean = false;
  private controller: TextInputController = new TextInputController();
  // Create a TCP Socket Server connection and return a TCP Socket Server object.
  private tcpServer: socket.TCPSocketServer = socket.constructTCPSocketServerInstance();
  private ipAddress: socket.NetAddress = {
    address: CommonConstants.IP_ADDRESS,
    port: CommonConstants.IP_PORT
  } as socket.NetAddress;
  private socketClient?: socket.TCPSocketConnection;

  aboutToDisappear(): void {
    try {
      // Close the connection with the client.
      this.socketClient?.close();

      // Unsubscribe from events related to TCP Socket Connection.
      setTimeout(() => {
        this.socketClient?.off('message');
        this.socketClient?.off('close');
      }, CommonConstants.EVENT_UNSUBSCRIPTION_TIME_MIN);

      // Unsubscribe from events related to TCP Socket Server.
      setTimeout(() => {
        this.tcpServer.off('connect');
      }, CommonConstants.EVENT_UNSUBSCRIPTION_TIME);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error('ServerSocketPage', `aboutToDisappear failed, error code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
      Column() {
        Text($r('app.string.app_title'))
          .fontSize($r('app.integer.comm_font_size2'))
          .fontWeight(FontWeight.Bold)
        Column() {
          TransmitMessages({ name: $r('app.string.show_message'), value: this.transmitInfo.message })
          TransmitMessages({ name: $r('app.string.show_address'), value: this.transmitInfo.address })
          TransmitMessages({ name: $r('app.string.show_family'), value: this.transmitInfo.family })
          TransmitMessages({ name: $r('app.string.show_port'), value: JSON.stringify(this.transmitInfo.port) })
          TransmitMessages({ name: $r('app.string.show_size'), value: JSON.stringify(this.transmitInfo.size) })
        }
        .borderRadius($r('app.integer.comm_border_radius1'))
        .backgroundColor($r('app.color.white_background'))
        .margin({
          top: $r('app.integer.comm_margin_padding4'),
          bottom: $r('app.integer.comm_margin_padding3')
        })
        .padding({
          top: $r('app.integer.comm_margin_padding3'),
          right: $r('app.integer.comm_margin_padding2'),
          bottom: $r('app.integer.comm_margin_padding3'),
          left: $r('app.integer.comm_margin_padding2')
        })

        Button($r('app.string.connection_button'))
          .width(CommonConstants.PERCENTAGE_MAX)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            if (this.isSend) {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.connected_tips') });
            } else {
              this.tcpServer.listen(this.ipAddress, (err: BusinessError) => {
                if (err) {
                  Logger.error('listen fail' + JSON.stringify(err));
                  this.isListen = false;
                  this.isSend = false;
                  return;
                }
                this.isListen = true;
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.tcp_server_listen_tips') });
                this.tcpServer.on('connect', (client: socket.TCPSocketConnection) => {
                  this.isSend = true;
                  this.getUIContext().getPromptAction().showToast({ message: $r('app.string.tcp_server_connect_tips') });
                  this.socketClient = client;
                  this.socketClient.on('close', () => {
                    Logger.info('on close success');
                  });
                  this.socketClient.on('message', (value: SocketInfo) => {
                    let buffer = value.message;
                    let dataView = new DataView(buffer);
                    let str = CommonConstants.EMPTY_STRING;
                    for (let i = 0; i < dataView.byteLength; ++i) {
                      str += String.fromCharCode(dataView.getUint8(i));
                    }
                    this.transmitInfo =
                      new TransmitInfo(str, value.remoteInfo.address, value.remoteInfo.family,
                        value.remoteInfo.port, value.remoteInfo.size);
                  });
                });
              });
            }
          })
      }
      .alignItems(HorizontalAlign.Start)

      Row() {
        Text(CommonConstants.EMPTY_STRING)
          .focusOnTouch(true)
          .focusable(true)
          .id(CommonConstants.TEXT_ID)
        TextInput({
          text: this.inputMessage,
          controller: this.controller,
          placeholder: $r('app.string.text_input_placeholder')
        })
          .width(CommonConstants.TEXT_INPUT_WIDTH)
          .height($r('app.integer.text_input_height'))
          .maxLength(CommonConstants.TEXT_INPUT_MAX_LENGTH)
          .type(InputType.Number)
          .caretColor(Color.Blue)
          .fontSize($r('app.integer.comm_font_size1'))
          .fontColor($r('app.color.comm_font_color2'))
          .backgroundColor($r('app.color.white_background'))
          .placeholderColor($r('app.color.comm_placeholder_color1'))
          .placeholderFont({
            size: $r('app.integer.comm_margin_padding3')
          })
          .margin({
            right: $r('app.integer.comm_margin_padding1')
          })
          .onChange((value: string) => {
            this.inputMessage = value;
          })
        Row() {
          Image($r('app.media.icon_send'))
            .id('bg_img')
            .width($r('app.integer.comm_image_size1'))
            .height($r('app.integer.comm_image_size1'))
        }
        .width($r('app.integer.comm_image_size2'))
        .height($r('app.integer.comm_image_size2'))
        .backgroundColor($r('app.color.send_background'))
        .borderRadius($r('app.integer.comm_border_radius2'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          if (this.isListen) {
            if (this.isSend) {
              focusControl.requestFocus(CommonConstants.TEXT_ID);
              let tcpSendOptions: socket.TCPSendOptions = {} as socket.TCPSendOptions;
              tcpSendOptions.data = this.inputMessage;
              if (this.inputMessage.length > 0) {
                try {
                  this.socketClient?.send(tcpSendOptions, (err: BusinessError) => {
                    if (err) {
                      Logger.error('send fail' + JSON.stringify(err));
                      return;
                    }
                    this.inputMessage = CommonConstants.EMPTY_STRING;
                    this.getUIContext().getPromptAction().showToast({ message: $r('app.string.message_send_tips') });
                  });
                } catch (err) {
                  Logger.error('socket client send fail');
                }
              } else {
                this.getUIContext().getPromptAction().showToast({ message: $r('app.string.message_not_send_tips') });
                return;
              }
            } else {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.server_client_tips') });
            }
          } else {
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.server_init_tips') });
          }
        })
      }
      .width(CommonConstants.PERCENTAGE_MAX)
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('app.color.comm_background1'))
      .padding({
        top: $r('app.integer.comm_margin_padding2'),
        bottom: $r('app.integer.comm_margin_padding2')
      })
    }
    .width(CommonConstants.PERCENTAGE_MAX)
    .height(CommonConstants.PERCENTAGE_MAX)
    .backgroundColor($r('app.color.comm_background1'))
    .padding({
      top: $r('app.integer.comm_margin_padding5'),
      left: $r('app.integer.comm_margin_padding3'),
      right: $r('app.integer.comm_margin_padding3')
    })
  }
}

@Component
struct TransmitMessages {
  @Prop name: ResourceStr;
  @Prop value: string;

  build() {
    Row() {
      Text(this.name)
        .fontColor($r('app.color.comm_font_color1'))
      Text(this.value === CommonConstants.EMPTY_STRING || this.value === CommonConstants.STRING_ZERO ?
        CommonConstants.EMPTY_STRING : this.value)
        .fontColor($r('app.color.comm_font_color2'))

    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.PERCENTAGE_MAX)
    .height($r('app.integer.transmit_messages_height'))
  }
}