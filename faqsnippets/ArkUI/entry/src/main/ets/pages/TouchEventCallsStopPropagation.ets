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
* FAQ:触摸事件的TouchEvent调用stopPropagation时无法阻止事件分发
*/

@Component
struct TouchEventDome {

  build() {
    // [Start touchEvent_calls_stopPropagation]
    Button() {
      Button()
        .onTouch(xx)
    }
    .onTouch((event: TouchEvent) => {
      // 没有阻止内部的button触发onTouch事件
      event.stopPropagation();
    })
    // [End touchEvent_calls_stopPropagation]
  }
}

function xx(event: TouchEvent): void {
  throw new Error('Function not implemented.');
}