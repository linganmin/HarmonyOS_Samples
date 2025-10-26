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
* FAQ:如何读取运动传感器比如加速度传感器
 */

// [Start Accelerometer1]
import { sensor } from '@kit.SensorServiceKit';
// [End Accelerometer1]

export async function set() {
  // [Start Accelerometer2]
  try {
    sensor.on(sensor.SensorId.ACCELEROMETER, (data) => {
      console.info('X-coordinate component: ' + data.x);
      console.info('Y-coordinate component: ' + data.y);
      console.info('Z-coordinate component: ' + data.z);
    }, { interval: 10000000 });
  } catch (err) {
    console.error('On fail, errCode: ' + err.code + ' ,msg: ' + err.message);
  }
  // [End Accelerometer2]
}
