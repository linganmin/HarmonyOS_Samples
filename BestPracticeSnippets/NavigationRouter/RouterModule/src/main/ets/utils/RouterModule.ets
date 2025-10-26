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
import { RouterModel } from '../model/RouterModel';
import Logger from './Logger';

// [Start class_routerModule]
export class RouterModule {
  // WrappedBuilder支持@Builder描述的组件以参数的形式进行封装存储
  static builderMap: Map<string, WrappedBuilder<[object]>> = new Map<string, WrappedBuilder<[object]>>();
  // 初始化路由栈，需要关联Navigation组件
  static routerMap: Map<string, NavPathStack> = new Map<string, NavPathStack>();

  // [StartExclude class_routerModule]
  // [Start static_registerBuilder]
  // 通过名称注册路由栈
  public static registerBuilder(builderName: string, builder: WrappedBuilder<[object]>): void {
    RouterModule.builderMap.set(builderName, builder);
  }

  // 获取路由表中指定的页面组件
  public static getBuilder(builderName: string): WrappedBuilder<[object]> {
    const builder = RouterModule.builderMap.get(builderName);
    if (!builder) {
      Logger.info('not found builder ' + builderName);
    }
    return builder as WrappedBuilder<[object]>;
  }

  // [End static_registerBuilder]
  // 通过名称注册路由栈
  public static createRouter(routerName: string, router: NavPathStack): void {
    RouterModule.routerMap.set(routerName, router);
  }

  // 通过名称获取路由栈
  public static getRouter(routerName: string): NavPathStack {
    return RouterModule.routerMap.get(routerName) as NavPathStack;
  }

  // 通过传入RouterModule跳转到指定页面组件，RouterModule中需要增加routerName字段用于获取路由栈
  // [Start static_async_push]
  // src/main/ets/utils/RouterModule.ets
  public static async push(router: RouterModel): Promise<void> {
    const harName = router.builderName.split('_')[0];
    await import(harName).then((ns: ESObject): Promise<void> => ns.harInit(router.builderName));
    RouterModule.getRouter(router.routerName).pushPath({ name: router.builderName, param: router.param });
  }

  // [End static_async_push]
  // [Start static_pop]
  // 通过路由栈名routerName获取对应的NavPathStack对象，并使用该对象的pop方法实现返回上个路由
  public static pop(routerName: string): void {
    RouterModule.getRouter(routerName).pop();
  }
  // [End static_pop]

  // 获取页面栈并清空
  public static clear(routerName: string): void {
    RouterModule.getRouter(routerName).clear();
  }

  // [Start static_popToName]
  // 直接跳转到指定路由
  public static popToName(routerName: string, builderName: string): void {
    RouterModule.getRouter(routerName).popToName(builderName);
  }
  // [End static_popToName]
  // [EndExclude class_routerModule]
}
// [End class_routerModule]