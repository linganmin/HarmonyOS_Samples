/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { BreakpointType, CommonConstants } from '../common/CommonConstants';

@Builder
export function ShareDirectBuilder() {
  ShareDirect();
}

@Component
export struct ShareDirect {
  @StorageProp('currentBreakpoint') curBp: string = CommonConstants.BREAK_POINT_SM;
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Button('Page B')
          .fontSize(16)
          .width(this.curBp === 'sm' ? CommonConstants.FULL_PERCENT : 448)
          .height(40)
          .margin({ bottom: $r('sys.float.padding_level6') })
          .backgroundColor($r('sys.color.brand'))
          .onClick(() => {
            this.pathStack.pushPathByName('PageBBuilder', null, false);
          })

        Button('Page A')
          .fontSize(16)
          .width(this.curBp === 'sm' ? CommonConstants.FULL_PERCENT : 448)
          .height(40)
          .backgroundColor($r('sys.color.brand'))
          .onClick(() => {
            this.pathStack.pushPathByName('PageABuilder', null, false);
          })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.End)
      .padding({
        right: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level0'),
          $r('sys.float.padding_level0')).GetValue(this.curBp),
        left: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level0'),
          $r('sys.float.padding_level0')).GetValue(this.curBp)
      })
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .title($r('app.string.button_jump'))
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      bottom: $r('app.float.column_side_padding')
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}