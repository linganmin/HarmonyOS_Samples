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

import { preferences } from '@kit.ArkData';
import SpTransferManager from '../restore/sp/SpTransferManager';

@Component
export struct XMLDataShow {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State map: Map<string, preferences.ValueType> = new Map<string, preferences.ValueType>();

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Row() {
          Text() {
            Span('intData: ')
            Span(this.map.get('intData')?.toString())
          }
          .fontSize(16)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        Row() {
          Text() {
            Span('floatData: ')
            Span(this.map.get('floatData')?.toString())
          }
          .fontSize(16)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        Row() {
          Text() {
            Span('setData: ')
            Span(this.map.get('setData')?.toString())
          }
          .fontSize(16)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        Row() {
          Text() {
            Span('boolData: ')
            Span(this.map.get('boolData')?.toString())
          }
          .fontSize(16)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        Row() {
          Text() {
            Span('stringData: ')
            Span(this.map.get('stringData')?.toString())
          }
          .fontSize(16)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        Row() {
          Text() {
            Span('longData: ')
            Span(this.map.get('longData')?.toString())
          }
          .fontSize(16)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 16
      })
    }
    .title($r('app.string.xml_data'))
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      new SpTransferManager().getDataFromTargetSp(this.getUIContext().getHostContext()!).then((map: Map<string, preferences.ValueType>) => {
        this.map = map;
      });
    })
  }
}