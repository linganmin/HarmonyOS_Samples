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
* FAQ:ArkTS中globalThis无法使用该如何替换
*/


// [Start globalThis2]
import { GlobalThis } from '../utils/globalThis';

@Entry
@Component
struct Index {
  @State value: string = GlobalThis.getInstance().getValue();

  build() {
    Row() {
      Column() {
        Text(this.value)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Button("setValue")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            GlobalThis.getInstance().setValue("TEST");
          })
        Button("getValue")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.value = GlobalThis.getInstance().getValue();
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End globalThis2]