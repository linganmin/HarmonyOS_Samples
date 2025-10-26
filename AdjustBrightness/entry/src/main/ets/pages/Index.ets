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

import { AppStorageV2 } from '@kit.ArkUI';
import Constants from '../commom/Constants';
import GlobalBuilderContext from '../commom/GlobalBuilderContext';
import SystemAreaModel from '../model/SystemAreaModel';

@Entry
@ComponentV2
struct Index {
  @Local systemAreaModel: SystemAreaModel =
    AppStorageV2.connect(SystemAreaModel, 'systemAreaModel', () => new SystemAreaModel(0, 0)) as SystemAreaModel;
  private pageStack: NavPathStack = new NavPathStack();
  private readonly COLUMN_SPACE: number = 12;

  build() {
    Navigation(this.pageStack) {
      Column({ space: this.COLUMN_SPACE }) {
        Button($r('app.string.page_video'))
          .width(Constants.FULL_PERCENT)
          .onClick(() => {
            this.pageStack.pushPathByName(Constants.NAV_DESTINATION_ITEM_VIDEO, '');
          })
        Button($r('app.string.page_pay_code'))
          .width(Constants.FULL_PERCENT)
          .onClick(() => {
            this.pageStack.pushPathByName(Constants.NAV_DESTINATION_ITEM_PAY_CODE, '');
          })
      }
      .padding({
        left: 16,
        right: 16,
        bottom: (16 + this.getUIContext().px2vp(this.systemAreaModel.bottomRectHeight))
      })
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Center)
      .width(Constants.FULL_PERCENT)
      .height(Constants.FULL_PERCENT)
    }
    .title({
      builder: this.navTitle(),
      height: 112 + this.getUIContext().px2vp(this.systemAreaModel.topRectHeight)
    })
    .navDestination(this.pagesMap)
  }

  @Builder
  navTitle() {
    Column() {
      Text($r('app.string.EntryAbility_label'))
        .fontSize(30)
        .fontWeight(700)
        .lineHeight(40)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Start)
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .padding({
      left: 16,
      right: 16,
      bottom: 8
    })
  }

  @Builder
  pagesMap(id: string) {
    if (GlobalBuilderContext.getContext().getObject(id)) {
      (GlobalBuilderContext.getContext().getObject(id) as WrappedBuilder<[string]>).builder(id);
    }
  }
}