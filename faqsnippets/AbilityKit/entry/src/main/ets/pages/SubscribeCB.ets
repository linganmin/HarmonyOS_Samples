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
* FAQ:ExtensionAbility如何与主进程通信
 */

// [Start subscribe_cb]
import { BusinessError } from '@kit.BasicServicesKit';
import { commonEventManager } from '@kit.BasicServicesKit';

// Define subscribers to save successfully created subscriber objects, which can be used to complete subscription and unsubscribe actions in the future
let subscriber: commonEventManager.CommonEventSubscriber;
// Subscriber information
let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
  events: ["event"]
};
// Subscribe to public event callbacks
function SubscribeCB(err: BusinessError, data: commonEventManager.CommonEventData) {
  if (err) {
    console.error(`Failed to subscribe. Code is ${err.code}, message is ${err.message}`);
  } else {
    console.info(`Succeeded in subscribing, data is ` + JSON.stringify(data));
  }
}
// Create subscriber callback
function createCB(err: BusinessError, commonEventSubscriber: commonEventManager.CommonEventSubscriber) {
  if(!err) {
    console.info(`Succeeded in creating subscriber.`);
    subscriber = commonEventSubscriber;
    // Subscribe to public events
    try {
      commonEventManager.subscribe(subscriber, SubscribeCB);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`Failed to subscribe. Code is ${err.code}, message is ${err.message}`);
    }
  } else {
    console.error(`Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
  }
}
// Create subscribers
try {
  commonEventManager.createSubscriber(subscribeInfo, createCB);
} catch (error) {
  let err: BusinessError = error as BusinessError;
  console.error(`Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
}
// [End subscribe_cb]