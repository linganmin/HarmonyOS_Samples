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
* FAQ：Navigation通过pushPathByName跳转页面为什么显示空白
*/

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
struct NavigationDemo {
  pageStack: NavPathStack = new NavPathStack();

  build() {
    // [Start hideNavBar]
    Navigation() {
      // page content
      // [StartExclude hideNavBar]
      Button('pushPathByName')
        .onClick(() => {
          // [Start pushPathByName]
          // Correct example: The name must match the routing table
          this.pageStack.pushPathByName('PageDetail', 'param');
          // [End pushPathByName]
        })
      Button('pushDestinationByName')
        .onClick(() => {
          // [Start pushDestinationByName]
          // Asynchronous jump using pushDestructionByName
          this.pageStack.pushDestinationByName('TargetPage', 'param')
            .then(() => {
              hilog.info(0x000, 'testTag', 'pushDestinationByName success');
            })
            .catch((error: BusinessError) => {
              // Jump failed, redirected to custom page (such as Stay tuned page)
              this.pageStack.pushPathByName('ErrorPage', 'param');
              hilog.error(0x000, 'testTag', `pushDestinationByName failed, code=${error.code}, message=${error.message}`);
            })
          // [Start pushDestinationByName]
        })
      // [EndExclude hideNavBar]
    }
    .hideNavBar(false) // Ensure not hidden
    // [End hideNavBar]
  }
}

// [Start ChildPage]
// Subpage code, avoid creating it yourself
@Component
struct ChildPage {
  // Error: Should not use new NavPathStack()
  // pageStack: NavPathStack = new NavPathStack();
  // Correct: Inject the parent stack through @Consume or parameters
  @Consume('pageStack') pageStack: NavPathStack;
  build() {
    // ...
  }
}
// [End ChildPage]