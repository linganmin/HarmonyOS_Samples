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
 * 最佳实践：页面埋点开发
 */

import { HMLifecycle, HMLifecycleContext, IHMLifecycle } from '@hadss/hmrouter';

// [Start page_duration_life_cycle]
@HMLifecycle({ lifecycleName: 'PageDurationLifecycle', global: true })
export class PageDurationLifecycle implements IHMLifecycle {
  private time: number = 0;

  onShown(): void {
    this.time = new Date().getTime();
  }

  onHidden(ctx: HMLifecycleContext): void {
    const duration = new Date().getTime() - this.time;
    console.log(`Page ${ctx.navContext?.pathInfo.name} stay ${duration}`);
  }
}

// [End page_duration_life_cycle]