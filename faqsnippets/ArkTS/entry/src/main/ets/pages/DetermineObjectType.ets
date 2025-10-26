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
* FAQ:如何判断对象的类型
 */

// [Start determine_object_type]
class BaseClass {
  value: number = 0;


  printf() {
    console.info('base value:' + this.value);
  }


  setValue(val: number) {
    this.value = val;
  }
}


class AClass extends BaseClass {
  value: number = 1;


  setValue(val: number) {
    this.value = val;
  }


  getValue(): number {
    return this.value;
  }
}


class BClass extends BaseClass {
  value: number = 2;


  setValue(val: number) {
    this.value = val;
  }
}


function printValue(base: BaseClass) {
  base.printf();
  let flag = base instanceof AClass;
  console.info('printValue flag:' + flag);
  if (flag) {
    let val = (base as AClass).getValue();
    console.info('printValue val:' + val);
  }
}


@Entry
@Component
struct DetermineObjectType {
  aboutToAppear(): void {
    printValue(new AClass());
    printValue(new BClass());
  }


  build() {
  }
}
// [End determine_object_type]