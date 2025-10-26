/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

// [Start Case9]
import { emitter } from '@kit.BasicServicesKit';
const CHANGE_COLOR_EVENT_ID = 1;
@Component
export struct ButtonComponent {
  value: number = 2;
  build() {
    Button(`下标是${this.value}的倍数的组件文字变为红色`)
      .onClick(() => {
        let event: emitter.InnerEvent = {
          eventId: CHANGE_COLOR_EVENT_ID,
          priority: emitter.EventPriority.LOW
        };
        let eventData: emitter.EventData = {
          data: {
            value: this.value
          }
        };
        // Sends an event with eventId of CHANGE_COLOR_EVENT_ID and event content of eventData
        emitter.emit(event, eventData);
        this.value++;
      })
  }
}
// [End Case9]