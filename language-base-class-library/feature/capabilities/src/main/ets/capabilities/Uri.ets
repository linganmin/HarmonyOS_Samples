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

import { uri } from '@kit.ArkTS';
import { customTitle } from '@ohos/common';
import { ColumnOperation } from '../components/ColumnOperation';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function UriBuilder() {
  Uri()
}

@Component
export struct Uri {
  UIContext: UIContext = this.getUIContext()

  @State output: string = 'https://username:password@host:8080/directory/file?foo=1&bar=2#fragment';
  @State URI: uri.URI = new uri.URI(this.output);
  @State host: string = '';
  @State fragment: string = '';
  @State path: string = '';
  @State scheme: string = '';
  @State userInfo: string = '';
  @State query: string = '';
  @StorageLink('selectedLabel') selectedLabel: string = '';
  public pathStack: NavPathStack = new NavPathStack();

  UriResolution() {
    if (this.output.indexOf('://') === -1) {
      try {
        this.UIContext.getPromptAction().showToast({
          message: 'Please enter a correct URI.',
          duration: 3000
        });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'Uri', `showToast failed, error code=${err.code}, message=${err.message}`);
      }
    } else {
      this.host = this.URI.host;
      this.fragment = this.URI.fragment;
      this.path = this.URI.path;
      this.scheme = this.URI.scheme;
      this.userInfo = this.URI.userInfo;
      this.query = this.URI.query;
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            TextArea({ text: this.output })
              .onChange(value => {
                if (value !== '') {
                  this.output = value;
                  this.URI = new uri.URI(value);
                }
              })
              .height(124)
              .fontColor($r('app.color.textarea_color'))
              .backgroundColor(Color.White)

            Row() {
              Text($r('app.string.parsed_data'))
            }
            .width('100%')
            .margin({ top: 16 })
            .justifyContent(FlexAlign.Start)

            Column() {
              Row() {
                Text('host:')
                Text(this.host)
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)

              Row() {
                Text('fragment:')
                Text(this.fragment)
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .margin({ top: 8 })

              Row() {
                Text('path:')
                Text(this.path)
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .margin({ top: 8 })

              Row() {
                Text('scheme:')
                Text(this.scheme)
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .margin({ top: 8 })

              Row() {
                Text('userInfo:')
                Text(this.userInfo)
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .margin({ top: 8 })

              Row() {
                Text('query:')
                Text(this.query)
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .margin({ top: 8 })
            }
            .borderRadius(16)
            .backgroundColor(Color.White)
            .margin({ top: 16 })
            .padding(16)
          }

          Column() {
            ColumnOperation({ operationRes: $r('app.strarray.uri_operations'), doOperation: this.doOperation })
          }
        }
        .width('100%')
        .height('100%')
        .padding(16)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .scrollBar(BarState.Off)
      .align(Alignment.Start)
    }
    .title(customTitle(this.selectedLabel))
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }

  doOperation = (index: number) => {
    switch (index) {
      case 0:
        this.UriResolution();
        break;

      default:
        break;
    }
  }
}