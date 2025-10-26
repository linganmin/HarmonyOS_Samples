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

import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
import Constants from '../common/Constants';
import Logger from '../common/Logger';
import { CardItem } from '../component/CardItem';
import { LocalResource } from '../views/LocalResource';
import { RemoteRequest } from '../views/RemoteRequest';
import { CookiesSettings } from '../views/CookiesSettings';
import { CustomProtocol } from '../views/CustomProtocol';
import { connection } from '@kit.NetworkKit';

@Entry
@Component
struct Index {
  @StorageProp('currentBreakpoint') curBp: string = Constants.BREAKPOINTS[1];
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  private routes: string[] = ['LocalResource', 'RemoteRequest', 'CookiesSettings', 'CustomProtocol'];
  scheme: webview.WebCustomScheme = { schemeName: 'app', isSupportCORS: true, isSupportFetch: true };

  aboutToAppear(): void {
    try {
      webview.WebviewController.customizeSchemes([this.scheme]);
      connection.addCustomDnsRule('www.a.harmonyos', ['127.0.0.1']).catch((error: BusinessError) => {
        Logger.error('addCustomDnsRule', `ErrorCode: ${error.code}, Message: ${error.message}`)
      })
      connection.addCustomDnsRule('www.b.harmonyos', ['127.0.0.1']).catch((error: BusinessError) => {
        Logger.error('addCustomDnsRule', `ErrorCode: ${error.code}, Message: ${error.message}`)
      })
      connection.addCustomDnsRule('www.c.harmonyos', ['127.0.0.1']).catch((error: BusinessError) => {
        Logger.error('addCustomDnsRule', `ErrorCode: ${error.code}, Message: ${error.message}`)
      })
    } catch (error) {
      Logger.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
    }
  }

  @Builder
  PageMap(name: string) {
    NavDestination() {
      if (name === 'LocalResource') {
        LocalResource()
      } else if (name === 'RemoteRequest') {
        RemoteRequest()
      } else if (name === 'CookiesSettings') {
        CookiesSettings()
      } else if (name === 'CustomProtocol') {
        CustomProtocol()
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    Navigation(this.pathInfos) {
      Column() {
        Text($r('app.string.project_name'))
          .fontSize($r('app.float.title_font_size'))
          .fontWeight(FontWeight.Bold)
          .margin({ left: $r('sys.float.padding_level8') })
        List() {
          ListItemGroup() {
            ForEach(this.routes, (item: string, index: number) => {
              ListItem({ style: ListItemStyle.CARD }) {
                CardItem({
                  textContent: $r('app.string.scene_name' + (index + 1)),
                  onCardItemClick: () => {
                    this.pathInfos.pushPath({ name: item });
                  },
                })
              }
              .height(undefined)
              .width('100%')
            }, (item: string) => JSON.stringify(item))
          }
          .margin({ top: $r('sys.float.padding_level8'), bottom: $r('sys.float.padding_level8') })
          .padding($r('sys.float.padding_level2'))
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius($r('sys.float.corner_radius_level8'))
          .divider({
            strokeWidth: 1,
            color: $r('sys.color.ohos_id_color_text_field_sub_bg'),
            startMargin: 20,
            endMargin: 10
          })
        }
        .width('100%')
        .height('100%')
        .padding(16)

      }
      .width(Constants.FULL_WIDTH)
      .height(Constants.FULL_HEIGHT)
      .padding({ top: Constants.PADDING_TOP_150 })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.PageMap)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}