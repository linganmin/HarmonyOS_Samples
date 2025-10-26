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
* FAQ: TextInput、TextArea等组件如何禁止提示拍摄输入
*/

// [Start enter_prohibited_prompt_plan_two]
@Entry
@Component
struct Index {
  @State message: string = '';

  build() {
    Column() {
      Text(`The input content：${this.message}`)
        .margin({
          top: 100,
          bottom: 30
        })
      TextInput({ placeholder: 'Please enter the content' })
        .borderRadius(0)
        .onChange((value: string) => {
          this.message = value;
        })
        .selectionMenuHidden(true)
    }
    .width('100%')
    .height('100%')
  }
}

// [End enter_prohibited_prompt_plan_two]