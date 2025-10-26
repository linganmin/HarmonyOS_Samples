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
* FAQ:设置了动态的visibility属性，切换组件的显示隐藏，使用requestFocus让组件获取焦点报错150003：the component is not on tree or does not exist.
*/

// [Start GetFocusByOnVisibleAreaChange]
@Entry
@Component
struct GetFocusByOnVisibleAreaChange {
  @State isEdit: boolean = true;

  build() {
    Column() {
      TextInput().id('input')
        .visibility(this.isEdit ? Visibility.Visible : Visibility.None)
        .onVisibleAreaChange([1.0], () => {
          if (this.isEdit) {
            try {
              this.getUIContext().getFocusController().requestFocus('input');
            } catch (e) {
              console.error('requestFocus error:' + e);
            }
          }
        })
      Button('change visibility')
        .onClick(() => {
          this.isEdit = !this.isEdit;
        })
    }
  }
}

// [End GetFocusByOnVisibleAreaChange]