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

import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';


@Entry
@Component
struct Index {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('pageShow') pageShow: string = 'button';
  @StorageLink('windowTop') windowTop: number = 0;
  @StorageLink('windowBottom') windowBottom: number = 0;

  aboutToAppear(): void {
    window.getLastWindow(this.getUIContext().getHostContext()).then((windowStage: window.Window) => {
      try {
        let area = windowStage.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        this.windowTop = this.getUIContext().px2vp(area.topRect.height);
        let bottomArea = windowStage.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.windowBottom = this.getUIContext().px2vp(bottomArea.bottomRect.height);
      } catch (e) {
        hilog.error(0x0000, 'multi-convenient-life', `getWindowAvoidArea error. Cause: ${JSON.stringify(e)}`);
      }
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, 'multi-convenient-life', `getLastWindow error. Cause: ${error.code}`);
    });
  }

  build() {
    Column() {
      if (this.pageShow === CommonConstants.PAGE_ROUTER_INDEX) {
        Column({ space: CommonConstants.DEFAULT_SPACE }) {
          Button($r('app.string.food_list'))
            .width('100%')
            .constraintSize({
              maxWidth: '448'
            })
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({ url: "pages/FoodList" })
            })
          Button($r('app.string.graphic_text'))
            .width('100%')
            .constraintSize({
              maxWidth: '448'
            })
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({ url: "pages/GraphicText" })
            })
          Button($r('app.string.living_page'))
            .width('100%')
            .constraintSize({
              maxWidth: '448'
            })
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({ url: "pages/Living" })
            })
        }
        .height('100%')
        .justifyContent(FlexAlign.End)
        .padding('16')
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}