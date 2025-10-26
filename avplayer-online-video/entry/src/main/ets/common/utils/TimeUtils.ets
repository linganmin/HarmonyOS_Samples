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

import { CommonConstants } from '../constants/CommonConstants';

export class TimeUtil {

  static millisecondsToTime(milliseconds: number): string {
    let hourUnit = CommonConstants.HOUR_UNIT * CommonConstants.HOUR_UNIT * CommonConstants.SECOND_TO_MS;
    let minuteUnit = CommonConstants.HOUR_UNIT * CommonConstants.SECOND_TO_MS;
    let secondUnit = CommonConstants.SECOND_TO_MS;

    let hour: number = Math.floor(milliseconds / hourUnit);
    let minute: number = Math.floor((milliseconds - hour * hourUnit) / minuteUnit);
    let second: number = Math.floor((milliseconds - hour * hourUnit - minute * minuteUnit) / secondUnit);

    let hourStr = hour > 0 ? `${hour.toString().padStart(2, '0')}:` : '';
    return hourStr + `${minute.toString().padStart(2, '0')}:${second.toString()
      .padStart(2, '0')}`;

  }

}

