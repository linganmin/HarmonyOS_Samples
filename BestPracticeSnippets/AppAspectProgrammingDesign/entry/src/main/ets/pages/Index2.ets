/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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
* 最佳实践: 应用切面编程设计
*/

// [Start index2]
// index2.ets
import {util} from '@kit.ArkTS';
import { Test1 } from '../components/somePackage1';

@Entry
@Component
struct Index {
  build() {
    // UI code
  }
}
// Print the time before and after the insertion, and encapsulate the insertion action into an interface
function addTimePrinter(targetClass: Object, methodName: string, isStatic: boolean) {
  let t1 = 0;
  let t2 = 0;
  util.Aspect.addBefore(targetClass, methodName, isStatic, () => {
    t1 = new Date().getTime();
  });
  util.Aspect.addAfter(targetClass, methodName, isStatic, () => {
    t2 = new Date().getTime();
    console.log("t2---t1 = " + (t2 - t1).toString());
  });
}
// Add the logic for printing the execution time to the doSomething instance method of Test
addTimePrinter(Test1, 'doSomething', false);
new Test1().doSomething()
// Add the logic for printing the execution time to the test static method of the test
addTimePrinter(Test1, 'test', true);
Test1.test()
// [End index2]