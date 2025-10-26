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
* FAQ:当父组件绑定了onTouch，其子组件Button绑定了onClick，如何做到点击Button只响应Button的onClick，而不用响应父组件的onTouch
*/

// [Start not_respond_to_parent_component_on_touch]
@Entry
@Component
struct Index {

  build() {
    Row() {
      Button('Click on me')
        .width(100)
        .backgroundColor('#f00')
        .onClick(() => {
          console.log('Button onClick');
        })
        .onTouch((event) => {
          console.log('Button onTouch');
          event.stopPropagation();
        })
    }
    .onTouch(() => {
      console.log('Row onTouch');
    })
  }
}
// [End not_respond_to_parent_component_on_touch]