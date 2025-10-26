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
* FAQ:在子容器的onTouch中调用stopPropagation，为什么无法阻止外层容器的onClick事件
*/

// [Start stopPropagation]
// xxx.ets
@Entry
@Component
struct TouchExample {
  @State text: string = '';

  build() {
    Column() {
      Button('Touch')
        .height(40)
        .width(100)
        .onTouch((event?: TouchEvent) => {
          console.info("child onTouch");
          event?.stopPropagation();
        })
      // Used to display the event trigger status
      Text(this.text)
    }
    .onTouch((event?: TouchEvent) => {
      // Since the child component called the stopPropagation interface, the onTouch event of the parent component cannot be triggered
      console.info("father onTouch");
    })
    .onClick(() => {
      // The child component called the stopPropagation interface but was unable to prevent the onClick event from being triggered. The parent component's onClick event was triggered as expected
      console.info("father onClick");
    })
    .width('100%')
    .padding(30)
  }
}

// [End stopPropagation]