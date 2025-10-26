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
* FAQ:如何实现跨模块的页面跳转功能
*/

// [Start login_page_with_module]
@Component
export struct LoginPage {
  @Consume('pathStack') pathStack: NavPathStack;
  @State message: string = 'Login Page';

  build() {
    NavDestination() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height('100%')
    }
    .onBackPressed(() => {
      this.pathStack.pop();
      return true;
    })
  }
}
// [End login_page_with_module]