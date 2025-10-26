/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { rcp } from '@kit.RemoteCommunicationKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { common } from "@kit.AbilityKit";
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import Logger from '../utils/Logger';
import { CommonConstants } from '../constants/CommonConstants';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct RCPReconnection {
  @State contentLength: number = -1;
  @State downloadSize: number = 0;
  @State process: number = 0;
  @State isDownload: boolean = false;
  private session = this.createRCPSession();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToDisappear(): void {
    if (this.session !== null) {
      this.session.close();
    }
  }

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
                Text('Downloading')
                  .fontColor(Color.White)
                  .fontSize(16)
                  .margin({ left: 12 })
              }
            }
            .padding(12)
            .width('100%')
          } else {
            SaveButton({ text: SaveDescription.SAVE_TO_GALLERY })
              .padding(12)
              .width('100%')
              .onClick(() => {
                this.rcpDownloadFile();
                this.isDownload = true;
              })
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
    .title(CommonConstants.RCP_DOWNLOAD)
  }

  // [Start create_rcp_session]
  createRCPSession(): rcp.Session | null {
    try {
      const customHttpEventsHandler: rcp.HttpEventsHandler = {
        onDownloadProgress: (totalSize: number, transferredSize: number) => {
          this.contentLength = totalSize;
          this.downloadSize = transferredSize;
          this.process = this.contentLength === 0 ? 0 : Math.floor(this.downloadSize / this.contentLength * 100);
        },
        onDataEnd: () => {
          this.contentLength = -1;
          this.downloadSize = 0;
        },
      };
      const sessionConfig: rcp.SessionConfiguration = {
        requestConfiguration: {
          transfer: {
            timeout: {
              connectMs: 6000,
              transferMs: 60000
            }
          },
          tracing: { httpEventsHandler: customHttpEventsHandler }
        }
      }
      return rcp.createSession(sessionConfig);
    } catch (error) {
      return null;
    }
  }

  // [StartExclude create_rcp_session]
  rcpDownloadFile() {
    try {
      this.process = Math.floor(this.downloadSize / this.contentLength * 100);
      const helper = photoAccessHelper.getPhotoAccessHelper(this.context);
      helper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4', { title: 'RCPVideo' })
        .then((uri) => {
          this.getRcpRequest(CommonConstants.VIDEO_SRC, 3)
            .then((response) => {
              if (response) {
                try {
                  const file = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
                  fs.writeSync(file.fd, response.body);
                  fs.closeSync(file);
                  this.isDownload = false;
                  this.getUIContext().getPromptAction().showToast({ message: $r('app.string.download_success') });
                } catch (err) {
                  Logger.info(JSON.stringify(err));
                } finally {
                  this.isDownload = false;
                }
              }
            });
        });
    } catch (error) {
      let err = error as BusinessError;
      Logger.info(JSON.stringify(err));
    }
  }
  // [EndExclude create_rcp_session]

  async getRcpRequest(url: string, retry: number): Promise<rcp.Response | undefined> {
    try {
      if (this.session !== null) {
        return await this.session.get(url)
          .then((response) => {
            if ((response.statusCode === 408 || response.statusCode === 500) && retry > 0) {
              return new Promise((resolve: Function) => {
                setTimeout(() => {
                  resolve(this.getRcpRequest(url, retry - 1));
                }, 2000)
              })
            } else {
              return response;
            }
          })
      } else {
        return;
      }
    } catch (err) {
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.download_error') });
        this.isDownload = false;
      } catch (error) {
        let err = error as BusinessError;
        Logger.error('NetworkReconnection', `showToast fail, code = ${err.code}, message = ${err.message}`);
      }
      return;
    }
  }
  // [End create_rcp_session]
}
