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


// [Start navigation_page]
// Import a custom component of the Login module
import { LoginPage } from '@ohos/login';

@Entry
@Component
struct NavigationPage {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack();

  @Builder
  pageMap(name: string) {
    if (name === 'loginPage') {
      LoginPage()
    }
  }

  build() {
    Navigation(this.pathStack) {
      Button('jump to login page')
        .onClick(() => {
          // The second parameter of NavPathInfo is a custom parameter that can be used for message transfer
          let pathInfo: NavPathInfo = new NavPathInfo('loginPage', new Object());
          this.pathStack.pushDestination(pathInfo, true);
        })
    }
    .navDestination(this.pageMap)
  }
}
// [End navigation_page]