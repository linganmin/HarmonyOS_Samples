/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ:如何监听系统公共事件，如熄屏、亮屏、开机等
 */

// [Start CommonEvent1]
import { commonEventManager } from '@kit.BasicServicesKit';

let subscriber:commonEventManager.CommonEventSubscriber;
let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
  events: ['usual.event.SCREEN_OFF'], // Subscribe to screen out public events
  priority:80
}
commonEventManager.createSubscriber(subscribeInfo, (err, data) => {
  if (err) {
    console.error(`Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
    return;
  }
  console.info('Succeeded in creating subscriber1.');
  subscriber = data;
  // Subscribe to public event callbacks
  commonEventManager.subscribe(subscriber, (err, data) => {
    if (err) {
      console.error(`Failed to subscribe common event. Code is ${err.code}, message is ${err.message}`);
      return;
    } else {
      console.info(`Succeeded in subscribe common event Succeeded1 `);
    }
  })
})
// [End CommonEvent1]