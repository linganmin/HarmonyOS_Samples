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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { HMLifecycleState, HMRouterMgr } from '@hadss/hmrouter';
import { CommonConstants } from '../../common/constants/CommonConstants';
import { ShoppingBagDiscounts } from './ShoppingBagDiscounts';
import { ShoppingBagView } from './ShoppingBarView';

@Component
export struct ShoppingBagContentNavBar {
  aboutToAppear(): void {
    const lifecycle = HMRouterMgr.getCurrentLifecycleOwner();
    lifecycle?.addObserver?.(HMLifecycleState.onShown, (ctx): void => {
      hilog.info(0x0000, 'ShoppingBag', '%{public}s', 'navbar onShown');
    });
    lifecycle?.addObserver?.(HMLifecycleState.onHidden, (ctx): void => {
      hilog.info(0x0000, 'ShoppingBag', '%{public}s', 'navbar onHidden');
    });
    lifecycle?.addObserver?.(HMLifecycleState.onBackPressed, (ctx): boolean => {
      hilog.info(0x0000, 'ShoppingBag', '%{public}s', 'navbar onBackPressed');
      return false;
    });
    lifecycle?.addObserver?.(HMLifecycleState.onDisAppear, (ctx): void => {
      hilog.info(0x0000, 'ShoppingBag', '%{public}s', 'navbar onDisAppear');
    });
  }

  build() {
    Row() {
      ShoppingBagView();
      ShoppingBagDiscounts();
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.tab_background_color'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}