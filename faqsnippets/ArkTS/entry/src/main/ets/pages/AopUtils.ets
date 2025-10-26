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
* FAQ:如何通过AOP统计方法执行时间
 */

// [Start aop_utils]
import { util } from '@kit.ArkTS';
import { systemDateTime } from '@kit.BasicServicesKit';

class Utils {
  Add(len: number): number {
    let num = 0;
    for (let index = 1; index <= len; index++) {
      num += index;
    }
    return num;
  }
}

let startTime = 0; // Initialization start time
let endTime = 0; // Initialization end time

util.Aspect.addBefore(Utils, 'Add', false, () => {
  startTime = systemDateTime.getTime(true); // Return the start time in nanoseconds
})

util.Aspect.addAfter(Utils, 'Add', false, () => {
  endTime = systemDateTime.getTime(true); // Return the end time in nanoseconds
})

let utilsObj = new Utils();
utilsObj.Add(1000);

@Entry
@Component
struct Index {
  build() {
    Row() {
      Column() {
        Button('get execution time')
          .onClick(() => {
            console.log('startTime:', startTime);
            console.log('endTime:', endTime);
            console.log('endTime - startTime = ', endTime - startTime);
          })
      }
      .width('100%')
    }.height('100%')
  }
}
// [End aop_utils]