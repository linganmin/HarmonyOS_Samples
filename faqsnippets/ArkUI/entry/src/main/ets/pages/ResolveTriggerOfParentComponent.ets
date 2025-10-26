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
* FAQ:当子组件触发触摸事件的时候，父组件如果设置触摸事件的话，如何解决父组件也会被触发的问题
*/

// [Start resolve_trigger_of_parent_component]
@Entry
@Component
struct TouchExample {
  @State text: string = 'Parent component'
  @State parentComponentResponse: string = 'Response times of parent component'
  @State parentComponentResponseNum: number = 0
  @State childComponentResponse: string = 'Number of sub component responses'
  @State childComponentResponseNum: number = 0

  build() {
    Column() {
      Column(){
        Text(this.text).margin({bottom: 20})
        Text(this.parentComponentResponse + ':' + `${this.parentComponentResponseNum}`)
        Text(this.childComponentResponse + ':' + `${this.childComponentResponseNum}`)

        Button('child').height(40).width(100).margin({top: 20})
          .onTouch((e) => {
            this.childComponentResponseNum ++
            e.stopPropagation()
          })
      }
      .onTouch(() => {
        this.parentComponentResponseNum ++
      })
    }.width('100%').padding(30)
  }
}
// [End resolve_trigger_of_parent_component]