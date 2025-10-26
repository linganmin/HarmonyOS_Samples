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
import { RouterModule } from '../utils/RouterModule';

// Routing information.
// [Start build_routerModel]
// 路由信息类，便于跳转时传递更多信息
export class RouterModel {
  // 路由页面别名，形式为${包名}_${页面名}
  builderName: string = "";
  // 路由栈名称
  routerName: string = "";
  // 需要传入页面的参数
  param?: object = new Object();
}

// 创建路由信息，并放到路由栈表中
export function buildRouterModel(routerName: string, builderName: string, param?: object) {
  let router: RouterModel = new RouterModel();
  router.builderName = builderName;
  router.routerName = routerName;
  router.param = param;
  RouterModule.push(router);
}
// [End build_routerModel]
