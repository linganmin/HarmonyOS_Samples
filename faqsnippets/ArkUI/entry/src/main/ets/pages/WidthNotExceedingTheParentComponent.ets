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
* FAQ:如何设置子组件宽度使其不超过父组件的大小
*/

// [Start width_not_exceeding_the_parent_component]
@Entry
@Component
struct SizeExample {
  @State flag:boolean = true;

  build() {
    Row() {
      Text(this.flag ? 'Followed by' : 'Not following')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(0xFFFAF0)
        .textAlign(TextAlign.Center)
        .margin(10)
        .size({ width: this.flag ? 60 : 80 })
        .onClick(()=>{
          this.flag = !this.flag
        })
      Text('HarmonyOS Developer Community')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(0xFFFAF0)
        .size({width: this.flag ? 'calc(100% - 60vp)' : 'calc(100% - 80vp)'})
    }
    .width(500)
    .margin({ top: 5 })
  }
}
// [End width_not_exceeding_the_parent_component]