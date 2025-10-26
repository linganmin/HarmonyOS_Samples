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
import { promptAction } from '@kit.ArkUI';
import { socket } from '@kit.NetworkKit';
import { TransmitInfo } from '../model/TransmitInfo';
import { CommonConstants } from '../constants/CommonConstants';
import Logger from '../utils/Logger';
import { buffer } from '@kit.ArkTS';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';

@Entry
@Component
struct ServerSocketPage {
  @State transmitInfo: TransmitInfo = new TransmitInfo('', '', '', 0, 0);
  @State inputMessage: string = '';
  @State isSend: boolean = false;
  @State isListen: boolean = false;
  // Create a TCP Socket Server connection and return a TCP Socket Server object.
  private tcpServer: socket.TCPSocketServer = socket.constructTCPSocketServerInstance();
  private ipAddress: socket.NetAddress = {
    address: CommonConstants.IP_ADDRESS,
    port: CommonConstants.IP_PORT
  } as socket.NetAddress;
  private socketClient?: socket.TCPSocketConnection;

  aboutToDisappear(): void {
    // Close the connection with the client.
    try {
      this.socketClient?.close();
    } catch (err) {
      Logger.error('NetworkReconnection', `socketClient close, code = ${err.code}, message = ${err.message}`);
    }

    // Unsubscribe from events related to TCP Socket Connection.
    setTimeout(() => {
      this.socketClient?.off('message');
      this.socketClient?.off('close');
    }, CommonConstants.EVENT_UNSUBSCRIPTION_TIME_MIN);

    // Unsubscribe from events related to TCP Socket Server.
    setTimeout(() => {
      this.tcpServer.off('connect');
      this.stopContinuousTask();
    }, CommonConstants.EVENT_UNSUBSCRIPTION_TIME);
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
            this.startContinuousTask();
          })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width(CommonConstants.PERCENTAGE_MAX)
    .height(CommonConstants.PERCENTAGE_MAX)
    .expandSafeArea([SafeAreaType.SYSTEM])
    .backgroundColor($r('app.color.comm_background1'))
    .padding({
      top: $r('app.integer.comm_margin_padding5'),
      left: $r('app.integer.comm_margin_padding3'),
      right: $r('app.integer.comm_margin_padding3')
    })
  }

  startContinuousTask() {
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "com.example.serversocket",
          abilityName: "MainAbility"
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.CANCEL_PRESENT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      backgroundTaskManager.startBackgroundRunning(this.getUIContext().getHostContext(),
        backgroundTaskManager.BackgroundMode.DATA_TRANSFER, wantAgentObj).then(() => {
        this.connectInit();
        Logger.info(`Succeeded in operationing startBackgroundRunning.`);
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to operation startBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
      });
    }).catch((err: BusinessError) => {
      Logger.error('NetworkReconnection', `getWantAgent fail, code = ${err.code}, message = ${err.message}`);
    });
  }

  stopContinuousTask() {
    backgroundTaskManager.stopBackgroundRunning(this.getUIContext().getHostContext()).then(() => {
      Logger.info(`Succeeded in operationing stopBackgroundRunning.`);
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to operation stopBackgroundRunning. Code is ${err.code}, message is ${err.message}`);
    });
  }

  connectInit() {
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
        Logger.info('on connect success');
        this.isSend = true;
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.tcp_server_connect_tips') });
        this.socketClient = client;
        this.socketClient.on('close', () => {
          Logger.info('on close success');
        });
        this.socketClient.on('message', (value: socket.SocketMessageInfo) => {
          this.transmitInfo =
            new TransmitInfo(buffer.from(value.message).toString(), value.remoteInfo.address,
              value.remoteInfo.family,
              value.remoteInfo.port, value.remoteInfo.size);
          this.sendFile();
        });
      });
    });
  }

  async sendFile() {
    try {
      const mediaBuffer: Uint8Array =
        await this.getUIContext().getHostContext()!.resourceManager.getMediaContent($r('app.media.Video'));
      let tcpSendOptions: socket.TCPSendOptions = {} as socket.TCPSendOptions;
      // slice size: 1024 * 1024
      const sendNum = Math.floor(mediaBuffer.byteLength / (1024 * 1024));
      const lastSendSize = mediaBuffer.byteLength % (1024 * 1024);

      for (let i = 0; i <= sendNum; i++) {
        // header size is 8;
        let preBuffer = buffer.alloc(8);
        const byteLength = preBuffer.writeUInt32BE(mediaBuffer.byteLength);
        const currentOffset = preBuffer.writeUInt32BE(i * (1024 * 1024), 4);
        Logger.info('byteLength:' + byteLength + ';currentOffset:' + currentOffset);
        const sliceBuffer =
          (i == sendNum && lastSendSize != 0) ? mediaBuffer.slice(i * (1024 * 1024), mediaBuffer.byteLength) :
          mediaBuffer.slice(i * 1024 * 1024, i * 1024 * 1024 + 1024 * 1024);
        const sendBuffer = buffer.concat([preBuffer, buffer.from(sliceBuffer)]);
        Logger.info('preBuffer:' + preBuffer.length + ';sliceBuffer:' + sliceBuffer.length + ',sendBuffer:' +
        sendBuffer.length);
        tcpSendOptions.data = sendBuffer.buffer;
        const fileLength = sendBuffer.readUInt32BE();
        const offset = sendBuffer.readUInt32BE(4);
        Logger.info('fileLength:' + fileLength + ';offset:' + offset);
        this.socketClient?.send(tcpSendOptions, (err: BusinessError) => {
          if (err) {
            Logger.error('send fail' + JSON.stringify(err));
            return;
          }
          this.getUIContext().getPromptAction().showToast({ message: $r('app.string.message_send_tips') });
        });
      }
    } catch (err) {
      Logger.error('socket client send fail:' + err);
    }
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