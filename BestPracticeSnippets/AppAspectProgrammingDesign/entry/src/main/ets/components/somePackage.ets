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

// [Start test]
// somePackage.ets
export class Test {
  foo(){}
}
// [End test]

// [Start person]
// somePackage.ets
export class Person {
  name: string;
  age: number;
  constructor(n: string, a: number) {
    this.name = n;
    this.age = a;
  }
  getInfo(): string {
    return 'name: ' + this.name + ', ' + 'age: ' + this.age.toString();
  }
}
// [End person]

// [Start test2]
export class Test2 {
  foo(arg: string) {
    console.log(arg);
  }
}
// [End test2]