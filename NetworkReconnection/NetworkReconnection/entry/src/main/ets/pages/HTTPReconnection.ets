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

import { http } from "@kit.NetworkKit";
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from "@kit.AbilityKit";
import { promptAction } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { CommonConstants } from "../constants/CommonConstants";
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";

@Component
export struct HTTPReconnection {
  @State contentLength: number = 0;
  @State downloadSize: number = 0;
  @State process: number = 0;
  @State isDownload: boolean = false;
  private httpRequest: http.HttpRequest = http.createHttp();
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToDisappear(): void {
    this.httpRequest.destroy();
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
                this.httpDownloadFile();
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
    .title(CommonConstants.HTTP_DOWNLOAD)
  }

  async httpDownloadFile() {
    const helper = photoAccessHelper.getPhotoAccessHelper(this.context);
    try {
      let uri = await helper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4', { title: 'HTTPVideo' });
      fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE).then((file) => {
        try {
          this.httpRequest.on('headersReceive', (header: Object) => {
            this.downloadSize = 0;
            this.contentLength = new Map(Object.entries(header)).get('content-length') as number;
          });
          this.httpRequest.on('dataReceive', (data: ArrayBuffer) => {
            fs.writeSync(file.fd, data);
            this.downloadSize += data.byteLength;
            this.process = Math.floor(this.downloadSize / this.contentLength * 100);
          });

          this.httpRequest.on('dataEnd', () => {
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.download_success') });
            this.downloadSize = 0;
            this.contentLength = 0;
            fs.closeSync(file);
            this.isDownload = false;
          });

          this.getHttpRequest(CommonConstants.VIDEO_SRC, 3);
        } catch (err) {
          fs.close(file).catch((err: BusinessError) => {
            hilog.error(0xFF00, 'NetworkReconnection', `httpDownloadFile fail, code = ${err.code}, message = ${err.message}`);
          });
          this.isDownload = false;
        }
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0xFF00, 'NetworkReconnection', `httpDownloadFile fail, code = ${err.code}, message = ${err.message}`);
    }
  }

  // [Start get_http_request]
  async getHttpRequest(url: string, retry: number): Promise<number | undefined> {
    try {
      return await this.httpRequest?.requestInStream(url,
        { method: http.RequestMethod.GET, connectTimeout: 6000, readTimeout: 60000 })
        .then((data: number) => {
          if (data === 408 || data === 500 && retry > 0) {
            return new Promise((resolve: Function) => {
              setTimeout(() => {
                resolve(this.getHttpRequest(url, retry - 1));
              }, 2000);
            });
          } else {
            return data;
          }
        });
    } catch (err) {
      this.isDownload = false;
      try {
        this.getUIContext().getPromptAction().showToast({ message: $r('app.string.download_error') });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0xFF00, 'NetworkReconnection', `showToast fail, code = ${err.code}, message = ${err.message}`);
      }
      return;
    }
  }
  // [End get_http_request]
}
