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

// [Start enter_prohibited_prompt_plan_one]
@Entry
@Component
struct TextAreaExample {
  @State text: string = 'TextArea editMenuOptions';

  onCreateMenu(menuItems: Array<TextMenuItem>) {
    menuItems = menuItems.filter((item) => item.content !== 'Photo Input'); // Can also choose to disable other menu options such as "Aelect All".
    return menuItems;
  }

  build() {
    Column() {
      TextArea({ text: this.text })
        .width('95%')
        .height(56)
        .editMenuOptions({
          onCreateMenu: this.onCreateMenu,
          onMenuItemClick: (menuItem: TextMenuItem, textRange: TextRange) => {
            return false; // Return false, execute custom logic first, then execute system logic
          }
        })
        .margin({ top: 100 })
    }
    .width('90%')
    .margin('5%')
  }
}
// [End enter_prohibited_prompt_plan_one]