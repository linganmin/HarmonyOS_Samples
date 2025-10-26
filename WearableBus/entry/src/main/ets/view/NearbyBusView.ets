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
import { CommonBusListView } from './CommonBusListView';

@Component
export struct NearbyBusView {
  build() {
    Column() {
      CommonBusListView({
        type: 0,
        goBusDes: (name: Resource)=> {
          pageStack.pushPathByName(CommonConstants.NAV_NEARBY_BUS_DES, name);
        }
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor('#141414')
    .borderRadius('50%')
  }
}

let pageStack: NavPathStack = new NavPathStack();

@Builder
function nearbyBusBuilder(name: string): void {
  if (name === CommonConstants.NAV_NEARBY_BUS) {
    NavDestination() {
      NearbyBusView();
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      pageStack = context.pathStack;
    })
  }
}

export const wrappedBuilderNearbyBus: WrappedBuilder<[string]> =
  wrapBuilder(nearbyBusBuilder);