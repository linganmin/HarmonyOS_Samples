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

import { furnitureData, natureData } from '@ohos/customreusablepool/src/main/ets/data/MockData';
import { ViewItem } from '@ohos/customreusablepool/src/main/ets/data/ViewItem';
import { NodePool } from '@ohos/customreusablepool/src/main/ets/utils/BuilderNodePool';
import { flowItemWrapper } from '@ohos/customreusablepool/src/main/ets/view/TabNode';

// [Start create_component]
@Entry
@Component
struct Index {
  // [StartExclude create_component]
  @State timer: number = 2;

  // [EndExclude create_component]
  aboutToAppear(): void {
    // [StartExclude create_component]
    let intervalId = setInterval(() => {
      if (this.timer === 1) {
        let uiContext = this.getUIContext();
        let router = uiContext.getRouter();
        router.pushUrl({ url: 'pages/OnIdlePage' });
        router.clear();
        clearInterval(intervalId)
      } else {
        this.timer--;
      }
    }, 1000)
    // [EndExclude create_component]
    // Obtain simulated data
    let viewItems: ViewItem[] = [];
    viewItems.push(...furnitureData());
    viewItems.push(...natureData());
    // Traverse simulated data and pre create the corresponding number of components
    viewItems.forEach((item) => {
      NodePool.getInstance()
        .preBuild('reuse_type_', item, flowItemWrapper, this.getUIContext());
    })
  }

  // [StartExclude create_component]
  build() {
    RelativeContainer() {
      Image($r('app.media.ad_image'))
        .height('100%')
        .width('100%')
        .id('image')
        .alignRules({
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End },
          top: { anchor: '__container__', align: VerticalAlign.Top },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
        })
      Text(this.timer + 's')
        .id('text')
        .textAlign(TextAlign.Center)
        .fontSize(14)
        .fontColor(Color.White)
        .padding(5)
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End },
          top: { anchor: '__container__', align: VerticalAlign.Top }
        })
        .margin({
          right: 20,
          top: 30
        })
        .width(50)
        .backgroundColor('#B3CFFF')
        .borderRadius(25)
    }
    .width('100%')
    .height('100%')
  }

  // [EndExclude create_component]
}

// [Start create_component]