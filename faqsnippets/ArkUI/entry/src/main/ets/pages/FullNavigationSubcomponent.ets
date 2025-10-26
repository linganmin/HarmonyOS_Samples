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
* FAQ:Navigation容器中，如何设置子组件的高度为100%，撑满父容器
*/

// [Start full_navigation_subcomponent]
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'FullNavigationSubComponent';

@Entry
@Component
struct FullNavigationSubComponent {
  context = this.getUIContext();

  onPageShow(): void {
    window.getLastWindow(this.context.getHostContext(), (err, win) => {
      if (err != null) {
        hilog.error(DOMAIN, TAG, `getLastWindow failed  code:${err.code};message:${err.message}`);
      } else {
        win.setWindowLayoutFullScreen(true);
      }
    })
  }

  build() {
    Navigation() {
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }
    .width('100%')
    .height('100%')
    .title('Personalization Settings')
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor(Color.Grey)
  }
}
// [End full_navigation_subcomponent]