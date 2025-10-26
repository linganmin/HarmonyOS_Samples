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
import { fileIo as fs } from '@kit.CoreFileKit';
import { socket } from '@kit.NetworkKit';
import Logger from '../utils/Logger';
import { common } from "@kit.AbilityKit";
import { CommonConstants } from '../constants/CommonConstants';
import { buffer } from '@kit.ArkTS';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

@Component
export struct SocketReconnection {
  @State process: number = 0;
  @State isDownload: boolean = false;
  // [Start storage_net_available]
  @StorageProp('netAvailable') @Watch('onSocketUpdated') netAvailable: boolean = true;
  // [End storage_net_available]
  // [Start storage_on_foreground]
  @StorageProp('onForeground') @Watch('onForegroundChange') onForeground: boolean = true;
  // [StartExclude storage_on_foreground]
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private tcp?: socket.TCPSocket;
  private receivedDataBuf: buffer.Buffer = buffer.alloc(15 * 1024 * 1024);
  private receivedDataLen: number = 0;
  private fileLength: number = 0;
  private totalSize = -1;

  aboutToDisappear(): void {
    this.tcpSocketDisconnect();
  }

  aboutToAppear(): void {
    this.tcpSocketConnect();
  }
  // [EndExclude storage_on_foreground]

  onForegroundChange(): void {
    this.onForeground ? this.tcpSocketConnect() : this.tcpSocketDisconnect();
  }
  // [End storage_on_foreground]

  // [Start on_socket_updated]
  onSocketUpdated() {
    this.netAvailable ? this.tcpSocketConnect() : this.tcpSocketDisconnect();
    Logger.info('netAvailable:' + this.netAvailable);
  }

  // [StartExclude on_socket_updated]
  build() {
    NavDestination() {
      Column() {
        Video({ src: CommonConstants.VIDEO_SRC })
          .autoPlay(true)
          .loop(false)
          .objectFit(ImageFit.Auto)
          .width('100%')
          .height('30%')
          .margin({
            top: 24
          })

        Blank()

        Column() {
          if (this.isDownload) {
            Button() {
              Row() {
                Text(`${this.process}%`)
                  .fontColor(Color.White)
                  .fontSize(16)
                Text($r('app.string.download_process'))
                  .fontColor(Color.White)
                  .fontSize(16)
                  .margin({ left: 12 })
              }
            }
            .padding(12)
            .width('100%')
          } else {
            Column() {
              SaveButton({ text: SaveDescription.SAVE_TO_GALLERY })
                .padding(12)
                .width('100%')
                .onClick(() => {
                  this.socketDownloadFile();
                })
            }
          }
        }
        .padding({
          left: 16,
          right: 16,
          bottom: 16
        })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .title(CommonConstants.Socket_DOWNLOAD)
  }
  // [EndExclude on_socket_updated]

  tcpSocketConnect() {
    if (!this.netAvailable) {
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.connect_error') });
      } catch (error) {
        let err = error as BusinessError;
        Logger.error('NetworkReconnection', `showToast fail, code = ${err.code}, message = ${err.message}`);
      }
      return;
    }

    this.tcp = socket.constructTCPSocketInstance();
    this.tcp.on('connect', () => {
      Logger.info('on connect');
    });
    this.tcp.on('close', () => {
      Logger.info('on close');
    });
    this.tcp.on('error', (error: BusinessError) => {
      Logger.error('error:' + error.code + error.message
      );
    });
    const clientIpAddress: socket.NetAddress = {
      address: CommonConstants.IP_ADDRESS,
      port: CommonConstants.CLIENT_IP_PORT
    } as socket.NetAddress;

    this.tcp.bind(clientIpAddress, (err: BusinessError) => {
      if (err) {
        Logger.error('bind fail' + JSON.stringify(err));
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.connect_error') });
        return;
      }

      let tcpConnect: socket.TCPConnectOptions = {} as socket.TCPConnectOptions;
      const serverIpAddress: socket.NetAddress = {
        address: CommonConstants.IP_ADDRESS,
        port: CommonConstants.IP_PORT
      } as socket.NetAddress;
      tcpConnect.address = serverIpAddress;
      tcpConnect.timeout = 3000;
      this.tcp?.connect(tcpConnect, (err: BusinessError) => {
        if (err) {
          Logger.error('connect fail');
          this.getUIContext().getPromptAction().showToast({ message: $r('app.string.connect_error') });
          return;
        }
      });
    });
  }
  // [End on_socket_updated]

  tcpSocketDisconnect() {
    this.tcp?.close().catch((err : BusinessError) => {
      Logger.error('bind fail' + JSON.stringify(err));
    });
  }

  socketDownloadFile() {
    if (!this.netAvailable) {
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.net_lost') });
      } catch (error) {
        Logger.error('bind fail' + JSON.stringify(error));
      }
      return;
    }
    this.isDownload = true;
    try {
      const helper = photoAccessHelper.getPhotoAccessHelper(this.context);
      helper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4', { title: 'SocketVideo' })
        .then((uri) => {
          try {
            const file = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
            this.tcp?.on('message', (value: socket.SocketMessageInfo) => {
              this.receiveMsgFromServer(value, file);
            })

            let tcpSendOptions: socket.TCPSendOptions = {} as socket.TCPSendOptions;
            tcpSendOptions.data = CommonConstants.DOWNLOAD_VIDEO;
            this.tcp?.send(tcpSendOptions, (err: BusinessError) => {
              if (err) {
                Logger.error('send fail' + JSON.stringify(err));
                this.stateInit();
                return;
              }
            });
          } catch (err) {
            this.stateInit();
            Logger.error('send fail:' + JSON.stringify(err));
          }
        });
    } catch (err) {
      this.stateInit();
      Logger.error('send fail:' + JSON.stringify(err));
    }
  }

  receiveMsgFromServer(value: socket.SocketMessageInfo, file: fs.File) {
    try {
      let response = buffer.from(value.message);
      response.copy(this.receivedDataBuf, this.receivedDataLen);
      this.receivedDataLen += value.message.byteLength;

      if (this.fileLength === 0) {
        this.fileLength = this.receivedDataBuf.readUInt32BE();
        this.totalSize = this.fileLength + 8 * (this.fileLength / (1024 * 1024) + 1);
      }
      Logger.info('valueSize:' + response.length + ',receivedDataLen:' + this.receivedDataLen);

      this.process = Math.floor(this.receivedDataLen / this.totalSize * 100);
      const sendNum = Math.floor(this.fileLength / (1024 * 1024));
      if (this.receivedDataLen === this.fileLength + 8 * (sendNum + 1)) {
        this.saveFile(file, sendNum);
      }
    } catch (err) {
      Logger.error('receiveMsgFromServer fail:' + JSON.stringify(err));
    }
  }

  saveFile(file: fs.File, sendNum: number) {
    try {
      for (let i = 0; i <= sendNum; i++) {
        const offset = this.receivedDataBuf.readUInt32BE(4 + i * (1024 * 1024 + 8));
        Logger.info('fileLength:' + this.fileLength + ';offset:' + offset);
        if (i != sendNum) {
          fs.writeSync(file.fd,
            this.receivedDataBuf.subarray(8 + i * (1024 * 1024 + 8), (i + 1) * (1024 * 1024 + 8)).buffer,
            { offset: offset });
        } else {
          fs.writeSync(file.fd, this.receivedDataBuf.subarray(8 + i * (1024 * 1024 + 8), this.receivedDataLen).buffer,
            { offset: offset });
          fs.close(file);
          this.getUIContext().getPromptAction().showToast({ message: $r('app.string.download_success') });
          this.stateInit();
        }
      }
    } catch (err) {
      Logger.error('saveFile fail:' + JSON.stringify(err));
    }
  }

  stateInit() {
    this.isDownload = false;
    this.fileLength = 0;
    this.process = 0;
    this.receivedDataLen = 0;
    this.totalSize = -1;
  }
}