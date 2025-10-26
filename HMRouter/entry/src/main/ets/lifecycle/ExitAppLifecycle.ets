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

import { HMLifecycle, HMLifecycleContext, IHMLifecycle } from '@hadss/hmrouter';
import { CommonConstants } from '../component/common/constants/CommonConstants'

// [Start exit_app_lifecycle]
@HMLifecycle({ lifecycleName: 'ExitAppLifecycle' })
export class ExitAppLifecycle implements IHMLifecycle {
  private lastTime: number = 0;

  onBackPressed(ctx: HMLifecycleContext): boolean {
    let time = new Date().getTime();
    if (time - this.lastTime > 1000) {
      this.lastTime = time;
      ctx.uiContext.getPromptAction().showToast({
        message: '再次返回退出应用',
        duration: 1000
      });
      return true;
    } else {
      return false;
    }
  }
}

// [End exit_app_lifecycle]
