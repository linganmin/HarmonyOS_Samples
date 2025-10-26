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

// Define type
type BeforeHook = (instance: any, ...args: any[]) => void;

class MethodDecorator {
  // [Start addbefore]
  // Instrument before class method execution
  static addBefore(targetClass, methodName, isStatic, before): void {
    let target =  isStatic ? targetClass : targetClass.prototype;
    let origin = target[methodName];
    // Define a new function that first executes "before" and then executes the old method.
    let newFunc = function (...args) {
      before(this, ...args);
      return origin.bind(this)(...args);
    }
    // Replace the method with a new function
    target[methodName] = newFunc;
  }
  // [End addbefore]

  // [Start add_after]
  // Instrument after class method execution
  static addAfter(targetClass, methodName, isStatic, after) : void {
    let target =  isStatic ? targetClass : targetClass.prototype;
    let origin = target[methodName];
    // Define a new function that first executes the old method, then executes after.
    let newFunc = function (...args) {
      let ret = origin.bind(this)(...args);
      return after(this, ret, ...args);
    }
    // Replace the method with a new function
    target[methodName] = newFunc;
  }
  // [End add_after]

  // [Start replace]
  static replace(targetClass, methodName, isStatic, instead) : void {
    let target =  isStatic ? targetClass : targetClass.prototype;
    // Define a new function that only executes "instead" inside.
    let newFunc = function (...args) {
      return instead(this, ...args);
    }
    // Replace the method with a new function
    target[methodName] = newFunc;
  }
  // [End replace]
}