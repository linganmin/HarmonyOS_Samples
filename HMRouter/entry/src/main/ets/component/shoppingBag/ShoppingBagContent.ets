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

/**
 * 最佳实践：基于HMRouter路由框架的页面跳转开发实践
 */

import { taskpool } from '@kit.ArkTS';
import {
  HMDefaultGlobalAnimator,
  HMLifecycle,
  HMLifecycleContext,
  HMNavigation,
  HMRouter,
  HMRouterMgr,
  IHMLifecycle
} from '@hadss/hmrouter';
import { ShoppingNavModifier } from './ShoppingNavModifier';
import { ShoppingBagContentNavBar } from './components/ShoppingBagContentNavBar';
import { TempObj } from '../../service/ServiceSample';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';

// [Start newwork_request]
@Concurrent
async function networkRequest(lifecycle: string): Promise<string> {
  // [StartExclude newwork_request]
  return await new Promise<string>((resolve) => {
    setTimeout(() => {
      resolve(`${lifecycle} request Http sucess`);
    }, 5000);
  });
  // [EndExclude newwork_request]
}

// [End newwork_request]

// [Start example_life_cycle]
@HMLifecycle({ lifecycleName: 'requestLifecycle' })
export class ExampleLifecycle implements IHMLifecycle {
  private requestModel: RequestModel = new RequestModel();

  onPrepare(): void {
    console.log(this.requestModel.data);
    let task: taskpool.Task = new taskpool.Task(networkRequest, 'onPrepare');
    taskpool.execute(task).then((res: Object) => {
      console.log(res + '');
    });
  }

  // [StartExclude example_life_cycle]
  onBackPressed(ctx: HMLifecycleContext): boolean {
    HMRouterMgr.popAsync({ navigationId: 'mainNavigationId', animator: false });
    return true;
  }

  // [EndExclude example_life_cycle]
}

// [End example_life_cycle]

@Observed
export class RequestModel {
  data: string = 'lifecycle onPrepare init data';
}

// [Start HMRouter_life_cycle_name]
@Component
export struct ShoppingBagContent {
  // [StartExclude HMRouter_life_cycle_name]
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @Provide('ShoppingNavModifier') modifier: ShoppingNavModifier = new ShoppingNavModifier();
  private requestModel: RequestModel = new RequestModel();

  aboutToAppear(): void {
    console.log(this.requestModel.data);
    let task: taskpool.Task = new taskpool.Task(networkRequest, 'aboutToAppear');
    taskpool.execute(task).then((res: Object) => {
      console.log(JSON.stringify(res));
    });
    this.service();
  }

  aboutToDisappear(): void {
  }

  service(): void {
    HMRouterMgr.request('testConsole');

    console.log(HMRouterMgr.request('testFunWithReturn').data);

    // Asynchronous calls will be executed at the end
    HMRouterMgr.request('testAsyncFun').data.then((res: string) => console.log(res));

    const tempObjParam: TempObj = { paramA: '', paramB: 20 };
    console.log(HMRouterMgr.request('testFunWithParams', 'testStr', 10, false, tempObjParam).data);
  }

  build() {
    ShoppingBagContentNavBar();
  }

  // [EndExclude HMRouter_life_cycle_name]
}

// [End HMRouter_life_cycle_name]