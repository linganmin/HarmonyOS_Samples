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

import { ColumnOperation } from '../ColumnOperation';
import {
  deleteAttribute,
  searchAttribute,
  addAndUpdateAttribute,
  funJsonToString,
  funJsonToMap,
  funMapToJson,
  deserializationLargeNum
} from '../../util/JsonUtil';
import { customTitle } from '@ohos/common';

@Builder
export function JsonFunctionBuilder() {
  JsonFunction()
}

@Component
export struct JsonFunction {
  @State resulText: string = '';
  @State numberText: string = '{"largeNumber":112233445566778899}';
  @State jsonText: string = '{"name":"John","age":30,"city":"Chongqing"}';
  @State actionSheets: Array<string> = [];
  @State flag: boolean = true;
  @StorageLink('selectedSecondLabel') selectedSecondLabel: string = '';
  public pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Row() {
              Text(this.resulText)
            }
            .width('91%')
            .height(124)
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .alignItems(VerticalAlign.Top)

            Row() {
              Text(this.flag ? this.jsonText : this.numberText)
                .margin({ top: 12 })
            }
            .width('91%')
            .alignItems(VerticalAlign.Top)
          }

          ColumnOperation({ operationRes: $r('app.strarray.json_operations'), doOperation: this.doOperation })
        }
        .height($r('app.string.text_width_full'))
        .width($r('app.string.text_width_full'))
        .padding(16)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r('app.color.page_bg'))
      }
      .scrollBar(BarState.Off)
      .align(Alignment.Start)
    }
    .title(customTitle(this.selectedSecondLabel))
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }

  doOperation = (index: number) => {
    switch (index) {
      case 0:
        this.resulText = deleteAttribute();
        this.flag = true;
        break;
      case 1:
        this.resulText = searchAttribute();
        this.flag = true;
        break;
      case 2:
        this.resulText = addAndUpdateAttribute();
        this.flag = true;
        break;
      case 3:
        this.resulText = funJsonToString();
        this.flag = true;
        break;
      case 4:
        this.resulText = funJsonToMap();
        this.flag = true;
        break;
      case 5:
        this.resulText = funMapToJson();
        this.flag = true;
        break;
      case 6:
        this.resulText = deserializationLargeNum();
        this.flag = false;
        break;
      default:
        break;
    }
  }
}