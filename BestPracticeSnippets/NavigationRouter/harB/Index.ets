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
import { BuilderNameConstants } from '@ohos/routermodule';

// [Start har_init]
export function harInit(builderName: string): void {
  // 根据routerModule中路由表的key值动态加载要跳转的页面的相对路径
  switch (builderName) {
    case BuilderNameConstants.HARB_B1:
      import("./src/main/ets/components/mainpage/B1");
      break;
    case BuilderNameConstants.HARB_B2:
      import("./src/main/ets/components/mainpage/B2");
      break;
    case BuilderNameConstants.HARB_B3:
      import("./src/main/ets/components/mainpage/B3");
      break;
    default:
      break;
  }
}
// [End har_init]