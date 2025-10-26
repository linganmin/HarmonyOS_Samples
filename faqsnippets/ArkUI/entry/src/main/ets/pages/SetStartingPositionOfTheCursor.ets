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
* FAQ:RichEditor组件如何设置光标的起始位置位于左上角
*/

// [Start set_starting_position_of_the_cursor]
// xxx.ets
@Entry
@Component
struct RichEditorExample {
  controller: RichEditorController = new RichEditorController();

  build() {
    Column() {
      RichEditor({ controller: this.controller })
        .align(Alignment.TopStart) // Set the starting position of the cursor to the upper left corner
        .height(200)
        .borderWidth(1)
        .borderColor(Color.Red)
        .width('100%')
    }
  }
}
// [End set_starting_position_of_the_cursor]