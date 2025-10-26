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
export struct LiveBusView {
  build() {
    Column() {
      CommonBusListView({
        type: 1,
        busName: busName
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor('#141414')
    .borderRadius('50%')
  }
}

let busName: Resource;

@Builder
function liveBusBuilder(name: string): void {
  if (name === CommonConstants.NAV_NEARBY_BUS_DES) {
    NavDestination() {
      LiveBusView();
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      busName = context.pathInfo.param as Resource;
    })
  }
}

export const wrappedBuilderLiveBus: WrappedBuilder<[string]> =
  wrapBuilder(liveBusBuilder);