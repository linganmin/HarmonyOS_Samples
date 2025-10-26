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
* FAQ:如何拉起拨号界面并指定号码
 */

// [Start start_call_dialog]
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';

function startCallDialog(): void {
  let isSupport = call.hasVoiceCapability();
  if (!isSupport) {
    console.error('Not support voice capability.');
    return;
  }

  call.makeCall('16888888888', (err: BusinessError) => {
    if (err) {
      console.error(`Failed to make call. Code is ${err.code}, Message is ${err.message}`);
      return;
    }
    console.info('Succeeded in making call.');
  })
}

@Entry
@Component
struct StartCallDialogView {
  @State message: string = 'How to pull up the dialing interface and specify the number';

  build() {
    Row() {
      Column() {
        Button(this.message)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            startCallDialog();
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End start_call_dialog]