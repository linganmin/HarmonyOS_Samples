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

import { Decimal } from '@kit.ArkTS';
import { sensor } from '@kit.SensorServiceKit';

/**
 * Obtain device degree by sensor data
 * @param data
 * @returns
 */
function getRealData(data: sensor.GravityResponse): number {
  let getDeviceDegree: number = 0;
  console.info('Succeeded in invoking once. X-coordinate component: ' + data.x);
  console.info('Succeeded in invoking once. Y-coordinate component: ' + data.y);
  console.info('Succeeded in invoking once. Z-coordinate component: ' + data.z);
  let x = data.x;
  let y = data.y;
  let z = data.z;
  if ((x * x + y * y) * 3 < z * z) {
    return getDeviceDegree;
  } else {
    try {
      let sd: Decimal = Decimal.atan2(y, -x);
      let sc: Decimal = Decimal.round(Number(sd) / 3.141592653589 * 180)
      getDeviceDegree = 90 - Number(sc);
      getDeviceDegree = getDeviceDegree >= 0 ? getDeviceDegree % 360 : getDeviceDegree % 360 + 360;
    } catch (error) {
      console.error(`The getRealData call failed. error: ${JSON.stringify(error)}`);
    } finally {
      return getDeviceDegree;
    }
  }
}

/**
 * Obtain device data from gravity sensors
 * @returns
 */
export async function getGravity(): Promise<number> {
  let promise: Promise<number> = Promise.resolve(0);
  let isSupported: boolean = false
  try {
    const data = await sensor.getSensorList()
    for (let i = 0; i < data.length; i++) {
      if (data[i].sensorId === sensor.SensorId.GRAVITY) {
        isSupported = true;
        break;
      }
    }
    if (!isSupported) {
      console.error(`The getGravity call failed. error is device unsupported`);
    } else {
      promise = new Promise((resolve) => {
        sensor.once(sensor.SensorId.GRAVITY, (data: sensor.GravityResponse) => {
          resolve(getRealData(data));
        });
      })
    }
  } catch (error) {
    console.error(`The getGravity call failed. error: ${JSON.stringify(error)}`);
  } finally {
    return promise;
  }
}