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
* FAQ:如何判断能否对接口进行插桩或替换
 */

// [Start replaced]
import { ObjectUtil } from '../utils/ObjectUtil'

class Test {
  static data: string = "initData";
  static printData(): void {
    console.log("execute original printData");
  }
}

@Entry
@Component
export  struct AOPReplaced {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            // Obtain the property descriptor of myMethod
            let des = ObjectUtil.ObjectGetOwnPropertyDescriptor(Test, 'printData')
            console.log('des',JSON.stringify(des))
            // Determine whether the writable field is true
            if (des && des.writable) {
              console.log('Method is writable');
            } else {
              console.log('Method is not writable or does not exist');
            }
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End replaced]