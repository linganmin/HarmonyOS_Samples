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

export default class MemoryTool {
  private unit: Array<string> = ['B', 'KB', 'MB', 'GB'];

  public convert(byte: number) {
    if (byte === 0) {
      return '0B';
    }
    let unitIndex: number = 0;
    let integerValue: number = byte;
    while (integerValue >= 1024) {
      if (unitIndex >= this.unit.length) {
        return integerValue.toFixed(1) + this.unit[unitIndex];
      }
      integerValue = integerValue / 1024;
      unitIndex++;
    }
    return integerValue.toFixed(1) + this.unit[unitIndex];
  }
}