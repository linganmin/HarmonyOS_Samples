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
* FAQ:如何实现事件透传
*/

// [Start realize_transparent_transmission_of_events]
@Entry
@Component
struct StackExample {
  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Text('A')
        .width('90%')
        .height('100%')
        .backgroundColor(0xd2cab3)
        .align(Alignment.Top)
        .onClick(() => {
          console.log('TextA click')
        })
      Text('B')
        .width('70%')
        .height('60%')
        .backgroundColor(0xc1cbac)
        .align(Alignment.Top)
        .hitTestBehavior(HitTestMode.None)
        .onClick(() => {
          console.log('TextB click')
        })
    }
    .width('100%')
    .height(150)
    .margin({ top: 5 })
  }
}
// [End realize_transparent_transmission_of_events]