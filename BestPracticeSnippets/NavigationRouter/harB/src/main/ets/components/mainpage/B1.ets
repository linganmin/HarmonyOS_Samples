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
import { BuilderNameConstants, buildRouterModel, RouterModule, RouterNameConstants, } from '@ohos/routermodule';

// [Start function_har_builder_b1]
// harB模块的B1页面
@Builder
export function harBuilder(value: object) {
  NavDestination() {
    Column() {
      // [StartExclude function_har_builder_b1]
      Button($r("app.string.to_harb_pageB2"), { stateEffect: true, type: ButtonType.Capsule })
        .width('80%')
        .height(40)
        .margin(20)
        .onClick(() => {
          buildRouterModel(RouterNameConstants.ENTRY_HAP, BuilderNameConstants.HARB_B2);
        })
      // [EndExclude function_har_builder_b1]
    }
    // [StartExclude function_har_builder_b1]
    .width('100%')
    .height('100%')

    // [EndExclude function_har_builder_b1]
  }
  // [StartExclude function_har_builder_b1]
  .title('B1Page')
  .onBackPressed(() => {
    RouterModule.pop(RouterNameConstants.ENTRY_HAP);
    return true;
  })

  // [EndExclude function_har_builder_b1]
}

// 在页面首次加载时触发执行
const builderName = BuilderNameConstants.HARB_B1;
// 判断表中是否已存在路由信息，避免重复注册
if (!RouterModule.getBuilder(builderName)) {
  // 通过系统提供的wrapBuilder接口封装@Builder装饰的方法，生成harB1页面builder
  let builder: WrappedBuilder<[object]> = wrapBuilder(harBuilder);
  // 注册harB1页面到全局路由表
  RouterModule.registerBuilder(builderName, builder);
}
// [End function_har_builder_b1]