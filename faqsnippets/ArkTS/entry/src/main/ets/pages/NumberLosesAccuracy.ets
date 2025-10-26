/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ:对象反序列化时number类型丢失精度如何解决
*/

// [Start NumberLosesAccuracy]
import { JSON } from '@kit.ArkTS';

let options: JSON.ParseOptions = {
  bigIntMode: JSON.BigIntMode.PARSE_AS_BIGINT,
}
let numberText = '{"largeNumber":1122333444455556666677777888889}';
let numberObj = JSON.parse(numberText, (key: string, value: Object | undefined | null): Object | undefined | null => {
  if (key === "largeNumber") {
    return value;
  }
  return value;
}, options) as Object;

@Entry
@Component
struct BigIntDemo {
  @State str: string = 'bigint num';

  build() {
    Row() {
      Column() {
        Button(this.str)
          .onClick(() => {
            console.info((numberObj as object)?.["largeNumber"]); // 1122333444455556666677777888889
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End NumberLosesAccuracy]
