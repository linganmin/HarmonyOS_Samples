/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

const MAX_LENGTH: number = 2;

export default class DateUtils {
  public static format(date: Date, format: string = 'yyyy-MM-dd HH:mm:ss'): string {
    let year = date.getFullYear().toString();
    let month = (date.getMonth() + 1).toString().padStart(MAX_LENGTH, '0');
    let day = (date.getDate() + 1).toString().padStart(MAX_LENGTH, '0');
    let hour = (date.getHours() + 1).toString().padStart(MAX_LENGTH, '0');
    let minute = (date.getMinutes() + 1).toString().padStart(MAX_LENGTH, '0');
    let second = (date.getSeconds() + 1).toString().padStart(MAX_LENGTH, '0');
    let result = format.replace('yyyy', year);
    result = result.replace('MM', month);
    result = result.replace('dd', day);
    result = result.replace('HH', hour);
    result = result.replace('mm', minute);
    result = result.replace('ss', second);
    return result
  }
}