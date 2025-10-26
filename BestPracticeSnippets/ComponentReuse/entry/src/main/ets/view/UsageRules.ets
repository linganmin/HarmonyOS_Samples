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

// [End usage_rules]
// xxx.ets
export class Message {
  value: string | undefined;


  constructor(value: string) {
    this.value = value
  }
}


@Entry
@Component
struct Index {
  @State switch: boolean = true
  build() {
    Column() {
      Button('Hello World')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          this.switch = !this.switch
        })
      if (this.switch) {
        Child({ message: new Message('Child') })
          // If there is only one reused component, there is no need to set reuseId
          .reuseId('Child')
      }
    }
    .height("100%")
    .width('100%')
  }
}


@Reusable
@Component
struct Child {
  @State message: Message = new Message('AboutToReuse');


  aboutToReuse(params: Record<string, ESObject>) {
    console.info("Recycle Child")
    this.message = params.message as Message
  }


  build() {
    Column() {
      Text(this.message.value)
        .fontSize(20)
    }
    .borderWidth(2)
    .height(100)
  }
}
// [End usage_rules]