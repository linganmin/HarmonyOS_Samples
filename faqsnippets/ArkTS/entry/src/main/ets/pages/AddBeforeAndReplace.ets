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
* FAQ:如何对异步方法进行插桩/替换
*/

// [Start AddBeforeAndReplace]
import { util } from '@kit.ArkTS';

class Test1 {
  static data: string = "initData";

  static async printData(arg: string) { // asynchronous method
    console.log("execute original printData");
    console.log("Test.data is" + Test1.data);
    console.log('arg', arg);
    return 0;
  }
}

// Pile insertion
util.Aspect.addBefore(Test1, "printData", true,
  (classObj: Object, arg: string): void => {
    console.log("execute before");
    Reflect.set(classObj, "data", "dataChangedByBefore");
    console.log("arg is " + arg);
  }
);

Test1.printData("m1").then((res) => {
  console.log("res = " + res.toString());
  console.log("Test.data = " + Test1.data);
});

class Test2 {
  static data: string = "initData";

  static async printData(arg: string) { // asynchronous method
    console.log("execute original printData");
    console.log("Test.data is" + Test2.data);
    console.log('arg', arg);
    return 0;
  }
}

// replace
util.Aspect.replace(Test2, "printData", true,
  // Replace with another asynchronous function
  async (classObj: Object, arg: string): Promise<number> => {
    console.log("execute instead");
    Reflect.set(classObj, "data", "dataChangedByInstead");
    console.log("arg is " + arg);
    return Promise.resolve(100);
  });

Test2.printData("m1").then((res) => {
  console.log("res = " + res.toString());
  console.log("Test.data = " + Test2.data);
});
// [End AddBeforeAndReplace]