/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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

// [Start navigation_page]
import { hilog } from '@kit.PerformanceAnalysisKit';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct NavigationPage {
  // [StartExclude navigation_page]
  pageInfos: NavPathStack = new NavPathStack();
  isUseInterception: boolean = false;
  startTime: number = 0;
  endTime: number = 0;
  // [EndExclude navigation_page]

  aboutToAppear(): void {
    const uiContext = this.getUIContext();
    // Registering a Listening Event
    uiContext.getUIObserver().on('willDraw', () => {
      this.startTime = Date.now();
    })
    uiContext.getUIObserver().on('didLayout', () => {
      this.endTime = Date.now();
    })
  }

  // [StartExclude navigation_page]
  aboutToDisappear(): void {
    const uiContext = this.getUIContext();
    uiContext.getUIObserver().off('willDraw');
    uiContext.getUIObserver().off('didLayout');
  }

  // DocsDot
  getResourceString(resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (error) {
      hilog.error(0x0000, '[getResourceString]', `getResourceString err: ${JSON.stringify(error)}`);
    }
    return resourceString;
  }
  // DocsDot

  // interception - willShow, didShow, and modeChange are triggered when the navigation is changed.
  registerInterception() {
    this.pageInfos.setInterception({
      willShow: (from: NavDestinationContext | 'navBar', to: NavDestinationContext | 'navBar') => {
        if (!this.isUseInterception) {
          return;
        }
        if (typeof to === 'string') {
          hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'target page is navigation home');
          return;
        }
        // redirect target page.Change pageTwo to pageOne.
        let target: NavDestinationContext = to as NavDestinationContext;
        if (target.pathInfo.name === 'pageTwo') {
          target.pathStack.pop();
          target.pathStack.pushPathByName('pageOne', null);
        }
      },
      didShow: (from: NavDestinationContext | 'navBar', to: NavDestinationContext | 'navBar') => {
        if (!this.isUseInterception) {
          return;
        }
        if (typeof from === 'string') {
          hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'current transition is from navigation home');
        } else {
          hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
            `current transition is from  ${(from as NavDestinationContext).pathInfo.name}`);
        }
        if (typeof to === 'string') {
          hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'current transition to is navBar');
        } else {
          hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
            `current transition is to ${(to as NavDestinationContext).pathInfo.name}`);
        }
      },
      modeChange: (mode: NavigationMode) => {
        if (!this.isUseInterception) {
          return;
        }
        hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `current navigation mode is ${mode}`);
      }
    })
  }

  // [StartExclude navigation_page]
  build() {
    Navigation(this.pageInfos) {
      Column() {
        Button('pushPath', { stateEffect: true, type: ButtonType.Capsule })
          .width('100%')
          .onClick(() => {
            // Put the NavDestination page information specified by name into the stack.
            this.pageInfos.pushPath({ name: 'pageOne' });
          })
        Button('Use interception', { stateEffect: true, type: ButtonType.Capsule })
          // [StartExclude navigation_page]
          .width('100%')
          .margin({ top: 12 })
            // [EndExclude navigation_page]
          .onClick(() => {
            this.isUseInterception = !this.isUseInterception;
            if (this.isUseInterception) {
              // Register Interceptor.
              this.registerInterception();
            } else {
              // Do not use interceptors.
              this.pageInfos.setInterception(undefined);
            }
          })
        Button($r('app.string.back'), { stateEffect: true, type: ButtonType.Capsule })
          // [StartExclude navigation_page]
          .width('100%')
          .margin({ top: 12 })
            // [EndExclude navigation_page]
          .onClick(() => {
            this.getUIContext().getRouter().back();
          })
      }
      // [StartExclude navigation_page]
      .padding({
        right: 16,
        bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16,
        left: 16
      })
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.End)
      // [EndExclude navigation_page]
    }
    // [StartExclude navigation_page]
    .titleMode(NavigationTitleMode.Full)
    .padding({
      top: AppStorage.get<number>('statusBarHeight') ?? 0
    })
    .backgroundColor('#F1F3F5')
    .height('100%')
    .width('100%')
    .title({
      main: this.getResourceString($r('app.string.page_tracing_point')),
      sub: this.getResourceString($r('app.string.navigation_route'))
    })
    .titleMode(NavigationTitleMode.Full)
    // [EndExclude navigation_page]
  }
}
// [End navigation_page]