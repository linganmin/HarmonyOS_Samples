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

import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * First page of navigation redirection.
 */
class TmpClass {
  count: number = 10;
}

@Builder
export function PageOneBuilder() {
  PageOne()
}

@Component
export struct PageOne {
  pageInfos: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Button('pushPathByName', { stateEffect: true, type: ButtonType.Capsule })
          .width('100%')
          .onClick(() => {
            let tmp = new TmpClass();
            // Add the NavDestination page information specified by name to the stack. The transferred data is param.
            this.pageInfos.pushPathByName('pageTwo', tmp);
          })
        Button('popToName', { stateEffect: true, type: ButtonType.Capsule })
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            // Roll back the routing stack to the first NavDestination page named name.
            this.pageInfos.popToName('pageTwo');
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `popToName: ${JSON.stringify(this.pageInfos)}`);
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
              `Return value: ${JSON.stringify(this.pageInfos.moveToTop('pageTwo'))}`);
          })
        Button('popToIndex', { stateEffect: true, type: ButtonType.Capsule })
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            // Roll back the routing stack to the NavDestination page specified by index.
            this.pageInfos.popToIndex(1);
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `popToIndex: ${JSON.stringify(this.pageInfos)}`);
          })
        Button('moveToTop', { stateEffect: true, type: ButtonType.Capsule })
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            // Move the first NavDestination page named name to the top of the stack.
            this.pageInfos.moveToTop('pageTwo');
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `MoveToTop: ${JSON.stringify(this.pageInfos)}`);
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
              `Return value: ${JSON.stringify(this.pageInfos.moveToTop('pageTwo'))}`);
          })
        Button('moveIndexToTop', { stateEffect: true, type: ButtonType.Capsule })
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            // Move the NavDestination page specified by index to the top of the stack.
            this.pageInfos.moveIndexToTop(1);
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `moveIndexToTop: ${JSON.stringify(this.pageInfos)}`);
          })
        Button('clear', { stateEffect: true, type: ButtonType.Capsule })
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            // Clear all pages in the stack.
            this.pageInfos.clear();
          })
        Button('get', { stateEffect: true, type: ButtonType.Capsule })
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
              `Gets the names of all NavDestination pages in the stack:
              ${JSON.stringify(this.pageInfos.getAllPathName())}`);
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
              `Obtains parameter information on the NavDestination page specified by index:
              ${JSON.stringify(this.pageInfos.getParamByIndex(1))}`);
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
              `Obtains the parameter information of all NavDestination pages named name:
              ${JSON.stringify(this.pageInfos.getParamByName('pageTwo'))}`);
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
              `Gets the location index of all NavDestination pages named name:
              ${JSON.stringify(this.pageInfos.getIndexByName('pageOne'))}`);
            hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
              `Obtains the stack size: ${JSON.stringify(this.pageInfos.size())}`);
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .padding({
        right: 16,
        left: 16
      })
    }
    .backgroundColor('#F1F3F5')
    .title('pageOne')
    .padding({
      bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16
    })
    .onBackPressed(() => {
      // Pop-out from stack top element.
      const popDestinationInfo = this.pageInfos.pop();
      hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `Pop return value: ${JSON.stringify(popDestinationInfo)}`);
      return true;
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}