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
* FAQ:如何解决点击子组件模块区域会触发父组件的点击事件问题
*/

// [Start resolve_trigger_parent_component_click_event]
@Entry
@Component
struct TouchExample {
  @State text: string = 'Parent component'
  @State parentComponentResponse: string = 'Response times of parent component'
  @State parentComponentResponseNum: number = 0

  build() {
    Column() {
      Column(){
        Text(this.text).margin({bottom: 20})
        Text(this.parentComponentResponse + ':' + `${this.parentComponentResponseNum}`)
        Row(){
          //Wrap a container component around the Button component and set the hitTestBehavior property to HitTestMode.Block, which can prevent event bubbling.
          Button('Disable sub components').height(40).width(100).margin({top: 20})
        }
        .hitTestBehavior(HitTestMode.Block)
      }.onClick((e) => {
        this.parentComponentResponseNum ++;
      })
      .width('80%')
      .height('30%')
      .backgroundColor(Color.Gray)
    }
    .width('100%')
    .padding(30)
  }
}
// [End resolve_trigger_parent_component_click_event]