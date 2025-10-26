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

import { rcp } from '@kit.RemoteCommunicationKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { JSON, url } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

const OLD_INTERCEPTOR_URL =
  'https://www.huawei.com/-/media/hcomponent-header/1.0.1.20250709175216/component/img/huawei_logo.png';

const NEW_INTERCEPTOR_URL = 'https://www.harmonyos.com/resource/image/release2/home/harmonyOS_logo.png';

export interface NetworkQualityProvider {
  isOldNetwork: () => boolean;
}

export class NetworkStateSimulator implements NetworkQualityProvider {
  private isOldNetwork_: boolean = true;

  isOldNetwork(): boolean {
    return this.isOldNetwork_;
  }

  simulateOldNetwork(): void {
    this.isOldNetwork_ = true;
  }

  simulateNewNetwork(): void {
    this.isOldNetwork_ = false;
  }
}

export interface Logger {
  log: (text: string) => void;
}

export class RequestUrlChangeInterceptor implements rcp.Interceptor {
  private readonly networkQualityProvider: NetworkQualityProvider;
  private readonly logger: Logger;

  constructor(networkQualityProvider: NetworkQualityProvider, logger: Logger) {
    this.networkQualityProvider = networkQualityProvider;
    this.logger = logger;
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    // Task 2: Add your source code below this comment.
    // If this.networkQualityProvider.isOldNetwork() return false, we should change the Panda URL in the interceptor.
    // AS-IS: OLD_INTERCEPTOR_URL;TO-BE: NEW_INTERCEPTOR_URL.
    if (context.request.method === 'GET' && !this.networkQualityProvider.isOldNetwork()) {
      this.logger.log('[RequestUrlChangeInterceptor]: New network is detected');
      try {
        const changed = url.URL.parseURL(NEW_INTERCEPTOR_URL);
        this.logger.log(`[RequestUrlChangeInterceptor]: Replace URL from "${context.request.url.href}" to "${changed}"`);
        context.request.url = changed;
        if (context.request.headers) {
          context.request.headers.accept = 'image/jpeg';
        } else {
          context.request.headers = {
            accept: 'image/jpeg',
          }
        }
      } catch (err) {
        this.logger.log(`[RequestUrlChangeInterceptor]: parseURL error, ${JSON.stringify(err)}`);
      }
    } else {
      this.logger.log('[RequestUrlChangeInterceptor]: Network is old');
    }
    // Task 2 end.
    return next.handle(context);
  }
}

export class ResponseHeaderRemoveInterceptor implements rcp.Interceptor {
  private readonly logger: Logger;

  constructor(logger: Logger) {
    this.logger = logger;
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const response = await next.handle(context);

    const toReturn: rcp.Response = {
      request: response.request,
      statusCode: response.statusCode,
      httpVersion: response.httpVersion,
      headers: {
        'content-length': response.headers['content-length'],
      },
      effectiveUrl: response.effectiveUrl,
      timeInfo: response.timeInfo,
      toJSON: () => null,
    };
    this.logger.log('[ResponseHeaderRemoveInterceptor]: Response was modified');

    return toReturn;
  }
}

@Entry
@Component
struct InterceptorDemo {
  @State logStorage: string[] = [];
  @State responseText: string = '';
  @State isImageDownloaded: boolean = false;
  private readonly pathToImage: string = this.getUIContext().getHostContext()?.filesDir + '/panda.jpg';
  private readonly errorPrefix: string = 'ERROR!!!';
  private isSimulateNewNetwork: boolean = false;

  private async getImage() {
    this.deleteImage();
    this.isImageDownloaded = false;
    const networkStateSimulator = new NetworkStateSimulator();

    try {
      const session = rcp.createSession({
        requestConfiguration: {
          transfer: {
            timeout: {
              connectMs: 5 * 1000,
            },
          },
          security: {
            remoteValidation: 'skip',
          },
          tracing: {
            collectTimeInfo: true,
          },
        },
        interceptors: [
          new RequestUrlChangeInterceptor(networkStateSimulator, this),
          new ResponseHeaderRemoveInterceptor(this),
        ],
      });

      try {
        if (this.isSimulateNewNetwork) {
          networkStateSimulator.simulateNewNetwork();
        } else {
          networkStateSimulator.simulateOldNetwork();
        }

        // Task 1: Add your source code below this comment.
        // NOTE: network URL is OLD_INTERCEPTOR_URL.
        const request = new rcp.Request(OLD_INTERCEPTOR_URL, 'GET');
        request.destination = {
          kind: 'file', file: this.pathToImage
        };
        request.headers = {
          accept: 'image/png',
        }
        const response = await session.fetch(request);
        this.logResponse(response);
        const isFileCreated = await fileIo.access(this.pathToImage);
        if (response.statusCode === 200 && isFileCreated) {
          this.isImageDownloaded = true;
        }
        // Task 1 end.
      } catch (e) {
        this.logError(e)
      } finally {
        session.close();
      }
    } catch (error) {
      this.logError(error);
    }
  }

  private deleteImage() {
    try {
      if (fileIo.accessSync(this.pathToImage)) {
        fileIo.unlinkSync(this.pathToImage);
      }
    } catch (error) {
      this.logError(error);
    }
  }

  private logError(e: BusinessError) {
    this.log(`${this.errorPrefix} ${JSON.stringify(e)}`);
  }

  private logResponse(response: rcp.Response) {
    let requestTotalTime = '';
    if (response.timeInfo) {
      requestTotalTime = `, request_time: ${response.timeInfo.totalTimeMs}`;
    }

    this.log(`Response: status_code: ${response.statusCode}, ` +
      `effective_url: ${response.effectiveUrl}, ` +
      `http_version: ${response.httpVersion}, ` +
      `headers: ${JSON.stringify(response.headers)}` +
      requestTotalTime);
  }

  log(text: string) {
    this.logStorage.push(text);
  }

  aboutToDisappear(): void {
    this.deleteImage();
  }

  build() {
    Column() {
      Column() {
        Text('Interceptor')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff100f0f')
          .margin({ top: 32, left: 16 })
          .alignSelf(ItemAlign.Start)

        Divider().color('gray').strokeWidth(1)
      }

      Column({ space: 10 }) {
        Column() {
          Image(this.isImageDownloaded ? fileUri.getUriFromPath(this.pathToImage) : '')
            .height(140)
            .width(200)
            .objectFit(ImageFit.Contain)
            .align(Alignment.End)

          Row({ space: 10 }) {
            Column({ space: 5 }) {
              Toggle({ type: ToggleType.Switch, isOn: this.isSimulateNewNetwork })
                .margin(0)
                .borderRadius(10)
                .borderWidth(1)
                .onChange((isOn) => {
                  this.isSimulateNewNetwork = isOn;
                })
              Text('Use interceptor')
                .fontSize(12)
            }

            Button('Get image')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .onClick(() => {
                this.getImage();
              })
          }
          .margin({ top: 10 })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .borderWidth(1)
        .borderColor('#d3d3d3')
        .borderRadius(20)
        .padding(5)

        Text('Result:')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ff100f0f')

        Scroll() {
          Column() {
            ForEach(this.logStorage, (entry: string) => {
              if (entry.startsWith(this.errorPrefix)) {
                Text(entry)
                  .fontSize(14)
                  .fontColor(Color.Red)
              } else {
                Text(entry)
                  .fontSize(14)
              }
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(5)
          .margin({ top: 5, bottom: 5 })

        }
        .width('100%')
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor('#F3F3F3')
        .borderRadius(10)
        .layoutWeight(1)

        Row() {
          Button('Clear')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.logStorage = [];
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(5)
      }
      .height('100%')
      .layoutWeight(1)
      .padding(15)
      .alignItems(HorizontalAlign.Start)
    }
  }
}