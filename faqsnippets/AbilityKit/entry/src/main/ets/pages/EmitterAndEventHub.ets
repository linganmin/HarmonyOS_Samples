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
* FAQ:关于emitter、eventHub的使用场景
 */

// [Start EmitterAndEventHub3]
import { emitter } from '@kit.BasicServicesKit';

// [End EmitterAndEventHub3]

// [Start EmitterAndEventHub4]
// Define an event with an eventId of 1 and a priority of Low 
let event: emitter.InnerEvent = {
  eventId: 1,
  priority: emitter.EventPriority.LOW
};

let eventData: emitter.EventData = {
  data: {
    content: 'c',
    id: 1,
    isEmpty: false
  }
};

// Send an event with eventId 1 and the event content is eventData
emitter.emit(event,eventData);
// [End EmitterAndEventHub4]