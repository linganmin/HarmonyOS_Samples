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

import { CommonConstants } from '../common/CommonConstants';
import { GlobalBuilderContext } from '../common/GlobalBuilderContext';
import { CommonHomeView } from '../view/CommonHomeView';

@Entry
@Component
struct Index {
  private pageStack: NavPathStack = new NavPathStack();

  @Builder
  PagesMap(id: string) {
    if (GlobalBuilderContext.getContext().getObject(id)) {
      (GlobalBuilderContext.getContext().getObject(id) as WrappedBuilder<[string]>).builder(id);
    }
  }

  @Builder
  navTitle() {
    Text($r('app.string.home_page_title'))
      .fontSize(19)
      .lineHeight(25)
      .fontWeight(700)
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .margin({ top: 17 })
      .width(CommonConstants.FULL_PERCENT)
  }

  build() {
    Navigation(this.pageStack) {
      CommonHomeView({
        type: 0,
        goNearbyBus: () => {
          this.goNearbyBus();
        },
        goWhere: () => {
          this.goWhere();
        }
      })
        .margin({ top: 12 })
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
    }
    .title({
      builder: this.navTitle(),
      height: 42
    })
    .navDestination(this.PagesMap)
    .borderRadius('50%')
    .backgroundColor('#141414')
  }

  goNearbyBus(): void {
    this.pageStack.pushPathByName(CommonConstants.NAV_NEARBY_BUS, null);
  }

  goWhere(): void {
    this.pageStack.pushPathByName(CommonConstants.NAV_GO_WHERE_PATH, null);
  }
}