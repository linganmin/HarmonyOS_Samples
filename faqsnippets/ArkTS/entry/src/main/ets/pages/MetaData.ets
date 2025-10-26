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
* FAQ:如何在ArkTS中实现运行时注解的能力
 */

// [Start metadata]
import "reflect-metadata";

// The ability of third-party packaging is exposed in Reflect
@Reflect.metadata("TargetClass", 'classData')
  // Tag class, key is "targetClass", data is classData
class MyClass {
  @Reflect.metadata("TargetMethod", 'methodData')
  // Tag method, key is' Target Method ', data is' methodData'
  myMethod() {
  }

  @Reflect.metadata("Static", 'staticData')
  static invoke() {
  }
}

// Retrieve tag information at runtime
console.info(Reflect.getMetadata("TargetClass", MyClass)); //classData
console.info(Reflect.getMetadata("TargetMethod", new MyClass(), "myMethod")); //methodData
console.info(Reflect.getMetadata("Static", MyClass, "invoke")); // staticData
// [End metadata]