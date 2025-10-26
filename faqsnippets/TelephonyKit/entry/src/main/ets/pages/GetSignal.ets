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
* FAQ:如何判断蜂窝信号强度
 */

// [Start getSignalInformation]
import { radio, observer } from '@kit.TelephonyKit';

// Taking obtaining the signal strength of card 1 as an example
let slotId: number = 0;
radio.getSignalInformation(slotId, (err, data) => {
  if (!err) {
    console.log("get signal information success.");
    // Traverse the array and output the signal strength under different network standards
    for (let j = 0; j < data.length; j++) {
      console.log("type:" + data[j].signalType + ", level:" + data[j].signalLevel);
    }
  } else {
    console.error("get signal information fail, err is:" + JSON.stringify(err));
  }
});

// Subscription to cellular network signal changes (optional)
observer.on("signalInfoChange", (data) => {
  console.log("signal info change, data is:" + JSON.stringify(data));
});

// [End getSignalInformation]