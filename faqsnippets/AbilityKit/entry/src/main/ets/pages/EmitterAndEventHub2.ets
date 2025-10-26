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
import { emitter } from '@kit.BasicServicesKit';

/*
* FAQ:关于emitter、eventHub的使用场景
 */


@Entry
@Component
struct Index {
  set() {
    // [Start EmitterAndEventHub2]
    // Define an event with an eventId of 1
    let event: emitter.InnerEvent = {
      eventId: 1
    };

    // Execute the callback after receiving an event with eventId 1
    let callback = (eventData: emitter.EventData): void => {
      this.getUIContext().getPromptAction().showToast({
        message: JSON.stringify(eventData)
      });
    };

    // Subscribe to events with eventId 1
    emitter.on(event,callback);
    this.getUIContext().getPromptAction().showToast({
      message: 'subscribe_success'
    });
    // [End EmitterAndEventHub2]
  }

  build() {
    RelativeContainer() {
      Text('Hello World')
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__',align: VerticalAlign.Center },
          middle: { anchor: '__container__',align: HorizontalAlign.Center }
        })
        .onClick(() => {
        })
    }
    .height('100%')
    .width('100%')
  }
}

