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

import { hiAppEvent } from '@kit.PerformanceAnalysisKit';
import { Logger } from '../log/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = 'eventSubscription';

export function eventSubscription(): void {
  try {
    // Add application event observer method, which can be used to subscribe to application events
    hiAppEvent.addWatcher({
      // Developers can customize observer names, which the system will use to identify different observers
      name: 'mst',
      // Developers can subscribe to system events of interest, where they have subscribed to crash events
      appEventFilters: [
        {
          domain: hiAppEvent.domain.OS,
          names: [hiAppEvent.event.APP_CRASH, hiAppEvent.event.APP_FREEZE]
        }
      ],
      // Knowledge point: Obtain event group information.
      // Developers can implement subscription callback functions themselves,
      // and crash and freeze events will be called back to developers the next time the application starts
      onReceive: async (domain: string, appEventGroups: Array<hiAppEvent.AppEventGroup>) => {
        Logger.info(TAG, `HiAppEvent onReceive: domain=${domain}`);
        // Obtain event group information and perform bidirectional data binding with
        // @StorageLink('faultMessage') faultMessage in the ApplicationException file
        // Performance concerns: If developers have synchronized code that requires time-consuming operations,
        // it is recommended to start worker or taskpool threads to handle it.
        // But if developers use storage and preferences, they can simply call them.
        AppStorage.setOrCreate('appEventGroups', appEventGroups);
      }
    });
  } catch (error) {
    let err = error as BusinessError;
    Logger.error(TAG, `addWatcher failed, error code=${err.code}, message=${err.message}`);
  }
}