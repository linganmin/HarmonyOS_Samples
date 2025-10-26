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

import { customTitle } from '@ohos/common';
import { ColumnOperation } from '../components/ColumnOperation';
import { changeValue, deleteNode, getFirstNode, insertNode } from '../util/UrlUtil';

const URL_NET: string = 'https://gitee.com/harmonyos/';

@Builder
export function UrlBuilder() {
  Url()
}

@Preview
@Component
export struct Url {
  @State output: string = URL_NET;
  @StorageLink('selectedLabel') selectedLabel: string = '';
  public pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Text(this.output)
            .id('output')
            .width('95%')
            .height('30%')
            .fontSize(15)
            .padding(10)
            .margin({ left: 10, right: 10, top: 10 })
            .border({ width: 2, radius: 5, color: Color.Gray })
          Text(URL_NET)
            .fontSize(15)
            .margin({ top: 15 })
            .fontWeight(FontWeight.Bold)
          ColumnOperation({ operationRes: $r('app.strarray.url_operations'), doOperation: this.doOperation })
        }
        .width('100%')
        .padding(16)
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
        this.output = insertNode();
        break;
      case 1:
        this.output = deleteNode();
        break;
      case 2:
        this.output = getFirstNode();
        break;
      case 3:
        this.output = changeValue();
        break;
      default:
        break;
    }
  }
}