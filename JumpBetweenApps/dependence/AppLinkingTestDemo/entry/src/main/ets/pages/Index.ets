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

import { Goods } from './Goods';
import { PaymentSuccess } from './PaymentSuccess';

// [Start Index_part]
@Entry
@Component
struct Index {
  @StorageProp('targetPage') targetPage: string = '';
  @Provide navPathStack: NavPathStack = new NavPathStack();

  onPageShow(): void {
    const currentPage = this.navPathStack.getAllPathName()[this.navPathStack.size() -1];
    if (!currentPage) {
      this.navPathStack.pushPathByName('Goods', null);
    }
    if (this.targetPage && this.targetPage.length !== 0 && currentPage !== 'Goods') {
      this.navPathStack.pushPathByName(this.targetPage, null);
    }
  }

  // [StartExclude Index_part]
  @Builder
  PageMap(name: string) {
    if (name === 'Goods') {
      Goods()
    } else if (name === 'PaymentSuccess') {
      PaymentSuccess()
    }
  }
  build() {
    Navigation(this.navPathStack) {
      Column() {
        Text($r('app.string.home_page'))
        Button($r('app.string.go_to_page')).onClick(() => {
          this.navPathStack.pushPathByName('Goods', null)
        })
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .navDestination(this.PageMap)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
  // [EndExclude Index_part]
}
// [End Index_part]