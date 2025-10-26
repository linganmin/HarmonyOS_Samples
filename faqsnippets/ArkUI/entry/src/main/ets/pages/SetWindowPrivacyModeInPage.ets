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
* FAQ:如何实现防截屏功能
*/

// [Start window_privacy_mode_page]
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

class WindowUtils {
  static setWindowPrivacyModeInPage(context: common.UIAbilityContext, isFlag: boolean) {
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setWindowPrivacyMode(isFlag, (err: BusinessError) => {
        const errCode: number = err.code;
        if (errCode) {
          console.error('Failed to set the window to privacy mode. Cause:' + JSON.stringify(err));
          return;
        }
        console.info('Succeeded in setting the window to privacy mode.');
      });
    })
  }
}

@Entry
@Component
struct Index {
  @State message: string = 'hello world';
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();
  context = this.getUIContext();

  @Builder
  PagesMap(name: string) {
    if (name === 'Index') {
      Index();
    } else if (name === 'PageOne') {
      PageOne();
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Button('pushPath', { stateEffect: true, type: ButtonType.Capsule })
          .width('80%')
          .height(40)
          .margin(20)
          .onClick(() => {
            this.pageStack.pushPath({ name: 'PageOne' }) // Push the page info of specified NavDestination into the stack
          })
      }
    }
    .navDestination(this.PagesMap)
    .onNavBarStateChange((isVisible: boolean) => {
      // Callback triggered when navigation bar display state changes
      console.info('------>isVisible：' + isVisible)
      WindowUtils.setWindowPrivacyModeInPage(this.context.getHostContext() as common.UIAbilityContext, isVisible);
    })
  }
}

@Component
struct PageOne {
  @Consume('NavPathStack') pageStack: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        Text('PageOne')
      }
    }
    .title('pageOne')
    .onBackPressed(() => {
      const popDestinationInfo = this.pageStack.pop(); // Pop the top element from the navigation stack
      return true;
    })
  }
}
// [End window_privacy_mode_page]
