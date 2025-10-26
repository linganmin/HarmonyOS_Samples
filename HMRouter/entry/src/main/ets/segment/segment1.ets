/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { HMRouterMgr } from '@hadss/hmrouter';

@Component
export struct ProductUtilView {
  @Link product: ProductMsg;
  @State param: string = ''

  build() {
    Row() {
      Image($r('app.media.tab_home'))
        .width(24)
        .margin({
          left: 16,
          right: 16
        })
        .onClick(() => {
          // [Start router_pop_param]
          HMRouterMgr.pop({ navigationId: 'mainNavigationId', param: this.param })
          // [End router_pop_param]
        });
    }
    .margin({ top: 4 });
  }
}

export class ProductMsg {
  color: string;
  memory: string;
  price: string;

  constructor(color: string, memory: string, price: string) {
    this.color = color;
    this.memory = memory;
    this.price = price;
  }
}