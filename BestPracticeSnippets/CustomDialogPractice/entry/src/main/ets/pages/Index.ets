/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { GlobalDialogDecoupledFromThePage } from '../pages/GlobalDialogDecoupledFromThePage';
import { InterceptReturn01 } from '../pages/InterceptReturn01';
import { InterceptReturn02, DialogPage1 } from '../pages/InterceptReturn02';
import { CustomDialogNotDisappear, PageOne, DialogPage } from '../pages/CustomDialogNotDisappear';
import { CustomDialogDisplayAndExitAnimations } from '../pages/CustomDialogDisplayAndExitAnimations';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  PagesMap(name: string) {
    if (name === 'GlobalDialogDecoupledFromThePage') {
      GlobalDialogDecoupledFromThePage()
    }
    else if (name === 'InterceptReturn01') {
      InterceptReturn01()
    }
    else if (name === 'InterceptReturn02') {
      InterceptReturn02()
    }
    else if (name === 'CustomDialogNotDisappear') {
      CustomDialogNotDisappear()
    }
    else if (name === 'CustomDialogDisplayAndExitAnimations') {
      CustomDialogDisplayAndExitAnimations()
    }
    else if (name === 'DialogPage') {
      DialogPage()
    }
    else if (name === 'DialogPage1') {
      DialogPage1()
    }
    else if (name === 'PageOne') {
      PageOne()
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Column({ space: 12 }) {
          Button('Dialog Decoupled From The Page')
            .width('100%')
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageStack.pushPathByName('GlobalDialogDecoupledFromThePage', '');
            })

          Button('Intercept Return')
            .width('100%')
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageStack.pushPathByName('InterceptReturn01', '');
            })

          Button('Intercept Return')
            .width('100%')
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageStack.pushPathByName('InterceptReturn02', '');
            })

          Button('Dialog Not Disappear')
            .width('100%')
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageStack.pushPathByName('CustomDialogNotDisappear', '');
            })

          Button('Dialog Display And ExitAnimations')
            .width('100%')
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageStack.pushPathByName('CustomDialogDisplayAndExitAnimations', '');
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16
      })
      .justifyContent(FlexAlign.End)
    }
    .title('Use of CustomDialog')
    .height('100%')
    .width('100%')
    .navDestination(this.PagesMap)
  }
}