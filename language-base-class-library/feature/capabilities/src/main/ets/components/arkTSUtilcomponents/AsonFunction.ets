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

import { ArkTSUtils, lang } from '@kit.ArkTS';
import { customTitle } from '@ohos/common';
import { ColumnOperation } from '../ColumnOperation';

// Construct a custom Sendable data structure.
@Sendable
class CustomData implements lang.ISendable {
  name: string;
  age: number;
  city: string;

  constructor(name: string, age: number, city: string) {
    this.name = name;
    this.age = age;
    this.city = city;
  }
}

@Builder
export function AsonFunctionBuilder() {
  AsonFunction()
}

@Component
export struct AsonFunction {
  @State jsonText: string = '{"name": "John", "age": 30, "city": "Chongqing"}';
  @State resulText: string = '';
  @State actionSheets: Array<string> = [];
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
          }

          ColumnOperation({ operationRes: $r('app.strarray.ason_operations'), doOperation: this.doOperation })
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
        this.resulText = this.Serialization();
        break;
      case 1:
        this.resulText = this.Deserialize();
        break;
      default:
        break;
    }
  }

  Serialization() {
    let normalObject: CustomData = new CustomData('John', 30, 'Chongqing');
    let str: string = ArkTSUtils.ASON.stringify(normalObject);
    return str;
  }

  Deserialize() {
    let obj = ArkTSUtils.ASON.parse(this.jsonText) as lang.ISendable;
    if (ArkTSUtils.isSendable(obj)) {
      return 'result is Sendable';
    } else {
      return 'result is not Sendable';
    }
  }
}