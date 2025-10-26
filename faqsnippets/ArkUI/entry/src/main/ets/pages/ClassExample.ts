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
* FAQ:应用通过对象字面量初始化class实例导致编译失败的原因和修改方案
*/

// [Start class_error_example]
// SDK
declare class Base {
  // since 9
  getPropA(): number;
  // since 12 new method
  getPropB(): number;
}
// apply
let b: Base = {
  getPropA() {
    return 0;
  }
}
// Error message after upgrading to API 12.
// Property 'getPropB' is missing in type '{ getPropA(): number; }' but required in type 'Base'.
// [End class_error_example]

// [Start not_recommended]
// SDK API
declare class Person1 {
  name: string;
  age: number;
  greet(): void;
}
// apply
const p: Person1 = {
  name: 'Bob',
  age: 40,
  greet() {} // Tampering with system greet behavior.
}
// [End not_recommended]

// [Start instance_of]
// SDK API
declare class Person2 {
  name: string;
  age: number;
  greet(): void;
}
// apply
const p1: Person2 = {
  name: 'Bob',
  age: 40,
  greet() {}
}
console.log(`${p1 instanceof Person2}`); // return false
// [End instance_of]

// [Start instantiate]
// SDK API
declare class Person3 {
  name: string;
  age: number;
  greet(): void;
}
const p2: Person3 = new Person3();
// [End instantiate]

// [Start extends]
// SDK API
declare class Person4 {
  name: string;
  age: number;
  greet(): void;
}

class Student extends Person4 {
  study() {}
}
// [End extends]

// [Start static_method]
// SDK API
declare class Person5 {
  name: string;
  age: number;
  static greet(): void;
}
Person5.greet();
// [End static_method]

// [Start other_way]
declare class Person6 {
  name: string;
  age: number;
  greet(): void;
}

const p3: Person2 = {
  name: 'Bob',
  age: 40,
  greet() {}
}
// [End other_way]

// [Start modification]
// SDK
declare class Base2 {
  // since 9
  getPropA(): number;
  // since 12 new method
  getPropB(): number;
}

// Initialize an instance of a class using the new method.
let b2: Base2 = new Base2();
// Upgrading to API 12 SDK will not result in errors.
// [End modification]