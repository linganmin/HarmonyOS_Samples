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

import { CommonConstants } from '../common/CommonConstants';
import { GlobalBuilderContext } from '../common/GlobalBuilderContext';

@Entry
@Component
struct Index {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomHeight: number = 0;
  private pageStack: NavPathStack = new NavPathStack();
  private readonly COLUMN_SPACE: number = 12;

  build() {
    Navigation(this.pageStack) {
      Column({ space: this.COLUMN_SPACE }) {
        Button($r('app.string.transition'))
          .width(CommonConstants.FULL_PERCENT)
          .onClick(() => {
            this.pageStack.pushPathByName(CommonConstants.NAV_DESTINATION_ITEM_0, '');
          })
        Button($r('app.string.sliding'))
          .width(CommonConstants.FULL_PERCENT)
          .onClick(() => {
            this.pageStack.pushPathByName(CommonConstants.NAV_DESTINATION_ITEM_1, '');
          })
      }
      .padding({ left: 16, right: 16, bottom: (16 + this.getUIContext().px2vp(this.bottomHeight)) })
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Center)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title({
      builder: this.navTitle(),
      height: 112
    })
    .navDestination(this.PagesMap)
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
    .backgroundColor('#F1F3F5')
  }

  @Builder
  navTitle(): void {
    Column() {
      Text($r('app.string.EntryAbility_label'))
        .fontSize(30)
        .fontWeight(700)
        .lineHeight(40)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      left: 16,
      right: 16,
      bottom: 8
    })
  }

  @Builder
  PagesMap(id: string): void {
    if (GlobalBuilderContext.getContext().getObject(id)) {
      (GlobalBuilderContext.getContext().getObject(id) as WrappedBuilder<[string]>).builder(id);
    }
  }
}