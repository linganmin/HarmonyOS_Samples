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

import { wrappedBuilderGoWherePathDes } from '../view/GoWhereDesView';
import { wrappedBuilderGoWherePath } from '../view/GoWhereView';
import { wrappedBuilderLiveBus } from '../view/LiveBusView';
import { wrappedBuilderNearbyBus } from '../view/NearbyBusView';
import { CommonConstants } from './CommonConstants';

export class GlobalBuilderContext {
  private static instance: GlobalBuilderContext;
  private objects = new Map<string, Object>();

  public static getContext(): GlobalBuilderContext {
    if (!GlobalBuilderContext.instance) {
      GlobalBuilderContext.instance = new GlobalBuilderContext();
      GlobalBuilderContext.instance.setObject(CommonConstants.NAV_NEARBY_BUS, wrappedBuilderNearbyBus);
      GlobalBuilderContext.instance.setObject(CommonConstants.NAV_NEARBY_BUS_DES, wrappedBuilderLiveBus);
      GlobalBuilderContext.instance.setObject(CommonConstants.NAV_GO_WHERE_PATH, wrappedBuilderGoWherePath);
      GlobalBuilderContext.instance.setObject(CommonConstants.NAV_GO_WHERE_PATH_DES, wrappedBuilderGoWherePathDes);
    }
    return GlobalBuilderContext.instance;
  }

  getObject(key: string): Object | undefined {
    return this.objects.get(key);
  }

  setObject(key: string, objectClass: Object): void {
    this.objects.set(key, objectClass);
  }
}