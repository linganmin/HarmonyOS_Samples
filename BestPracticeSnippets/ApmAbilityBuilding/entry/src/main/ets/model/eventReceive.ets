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
// [Start eventReceive]
import { hiAppEvent } from '@kit.PerformanceAnalysisKit';

export function eventReceive() {
  let holder = hiAppEvent.addWatcher({
    name: "crash",
    /* Subscribe to system events, in this case to crash events */
    appEventFilters: [
      {
        domain: hiAppEvent.domain.OS,
        names: [ hiAppEvent.event.APP_CRASH ]
      }
    ],
    onReceive: (domain: string, appEventGroups: Array<hiAppEvent.AppEventGroup>) => {
      /* Implement onReceive callback, and call back in real time after monitoring system events */
    },
  });
}
// [End eventReceive]