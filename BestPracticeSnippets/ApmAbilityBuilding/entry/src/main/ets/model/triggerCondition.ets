/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
// [Start triggerCondition]
import { hiAppEvent } from '@kit.PerformanceAnalysisKit';

export function triggerCondition() {
  let holder = hiAppEvent.addWatcher({
    name: "crash",
    /* Subscribe to system events, in this case to crash events */
    appEventFilters: [
      {
        domain: hiAppEvent.domain.OS,
        names: [ hiAppEvent.event.APP_CRASH ]
      }
    ],
    /* Set the trigger condition of the callback. Here, when a subscribed event is generated, the onTrigger callback
     will be triggered */
    triggerCondition: {
      row: 1,
    },
    onTrigger: (curRow: number, curSize: number, holder: hiAppEvent.AppEventPackageHolder) => {
      /* Implement onTrigger callback, which can be used in combination with triggerCondition to trigger the callback
       when the callback condition is met. After receiving the callback notice, use takeNext to query the
       subscribed events */
      let eventPkg = holder.takeNext();
    },
  });
}
// [End triggerCondition]