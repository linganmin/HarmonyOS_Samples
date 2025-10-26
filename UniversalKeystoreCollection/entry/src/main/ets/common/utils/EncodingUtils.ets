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

import { buffer } from '@kit.ArkTS';

export class EncodingUtils {
  // Convert strings to byte streams, encoded in UTF-8 format.
  static stringToUnit8Array(str: string) {
    return new Uint8Array(buffer.from(str, 'utf8').buffer);
  }

  // Convert a stream of bytes to a string.
  static unit8ArrayToString(array: Uint8Array) {
    let out: string = '';
    let index: number = 0;
    let len: number = array.length;
    while (index < len) {
      let character = array[index++];
      switch (character >> 4) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
          out += String.fromCharCode(character);
          break;
        case 12:
        case 13:
          out += String.fromCharCode(((character & 0x1F) << 6) | (array[index++] & 0x3F));
          break;
        case 14:
          out += String.fromCharCode(((character & 0x0F) << 12) | (array[index++] & 0x3F) << 6 |
            (array[index++] & 0x3F) << 0);
          break;
        default:
          break;
      }
    }
    return out;
  }

  static unit8ArrayToBigInt(array: Uint8Array): bigint {
    let i: number = 0;
    const byteMax: bigint = BigInt('0x100');
    let result: bigint = BigInt('0');
    while (i < array.length) {
      result = result * byteMax;
      result = result + BigInt(array[i]);
      i++;
    }
    return result;
  }
}