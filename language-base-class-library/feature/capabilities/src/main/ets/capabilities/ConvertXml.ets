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

import { customTitle } from '@ohos/common'
import { ColumnOperation } from '../components/ColumnOperation';
import { serializerNode, parserNode, convertNode } from '../util/ConvertXmlUtil';

const FULL_PERCENT: string = '100%';

@Builder
export function ConvertXmlBuilder() {
  ConvertXml()
}

@Component
export struct ConvertXml {
  @State output: string = `eTSXmlTextConvert`;
  @State input: string =
    `<?xml version="1.0" encoding="utf-8"?>
     <note importance="high" logged="true">
       <title lang="en" id='titleId'>Happy</title>
       <book category="COOKING">
         <title lang="en">Everyday</title>
         <author>Giada</author>
       </book>
       <todo>Work</todo>
       <todo>Play</todo>
     </note>`;
  @StorageLink('selectedLabel') selectedLabel: string = '';
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Text(this.output)
              .width(FULL_PERCENT)
              .fontSize($r('app.float.title_font_size'))
              .padding($r('app.float.text_padding'))
          }
        }
        .border({
          width: $r('app.float.border_width'),
          radius: $r('app.float.border_radius'),
          color: Color.Gray
        })
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Start)

        ColumnOperation({ operationRes: $r('app.strarray.convert_xml_operations'), doOperation: this.doOperation })
      }
      .width(FULL_PERCENT)
      .height(FULL_PERCENT)
      .padding($r('app.float.large_padding'))
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
        this.output = serializerNode();
        break;
      case 1:
        this.output = parserNode(this.input);
        break;
      case 2:
        this.output = convertNode(this.input);
        break;
      default:
        break;
    }
  }
}