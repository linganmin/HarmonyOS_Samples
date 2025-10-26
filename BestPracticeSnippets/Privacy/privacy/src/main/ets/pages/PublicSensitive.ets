/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

/**
 * 最佳实践：应用安全编码实践
 * 场景十一：建议对涉及敏感功能的公共事件进行访问权限控制
 */

// [Start public_sensitive]
import { commonEventManager } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

let subscriber: commonEventManager.CommonEventSubscriber;
//Subscriber information
let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
  events: ['event'],
  publisherPermission: 'ohos.permission.publisherPermission1', // Set the subscription permission
};

// Create a subscriber
try {
  commonEventManager.createSubscriber(subscribeInfo, (err, commonEventSubscriber) => {
    if (!err) {
      hilog.info(0x0000, 'privacy', 'createSubscriber');
      subscriber = commonEventSubscriber;
      //Subscribe to public events
      try {
        commonEventManager.subscribe(subscriber, (err, data) => {
          if (err) {
            hilog.error(0x0000, 'privacy', `subscribe failed, code is ${err.code}, message is ${err.message}`);
          } else {
            //Event processing after receiving public events
            // doSomeDangerousThing(data)
          }
        });
      } catch (err) {
        hilog.error(0x0000, 'privacy', `subscribe failed, code is ${err.code}, message is ${err.message}`);
      }
    } else {
      hilog.error(0x0000, 'privacy', `createSubscriber failed, code is ${err.code}, message is ${err.message}`);
    }
  });
} catch (err) {
  hilog.error(0x0000, 'privacy', `createSubscriber failed, code is ${err.code}, message is ${err.message}`);
}
// [End public_sensitive]