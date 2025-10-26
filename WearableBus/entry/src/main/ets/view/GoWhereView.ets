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
import { CommonHomeView } from './CommonHomeView';

@Component
export struct GoWhereView {
  build() {
    Column() {
      CommonHomeView({
        type: 1,
        goHomeOrCompany: ()=> {
          pageStack.pushPathByName(CommonConstants.NAV_GO_WHERE_PATH_DES, null);
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
function goWhereBuilder(name: string): void {
  if (name === CommonConstants.NAV_GO_WHERE_PATH) {
    NavDestination() {
      GoWhereView();
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      pageStack = context.pathStack;
    })
  }
}

export const wrappedBuilderGoWherePath: WrappedBuilder<[string]> =
  wrapBuilder(goWhereBuilder);