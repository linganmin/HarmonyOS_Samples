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
* FAQ:如何处理大整数
 */

// [Start big_int_num]
@Entry
@Component
struct BigIntNum {
  build() {
    Row() {
      Column() {
        Button('BigInt num')
          .onClick(() => {
            let bigIntNum: bigint = 12345678901234567890n; // Add n suffix after integer
            let anotherBigInt: bigint = BigInt(9007199254740992); // Use BigInt() constructor
            let sumBigInt: bigint = bigIntNum + anotherBigInt;
            console.info('bigIntNum:' + bigIntNum);
            console.info('anotherBigInt:' + anotherBigInt);
            console.info('bigIntNum + anotherBigInt:' + sumBigInt);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End big_int_num]