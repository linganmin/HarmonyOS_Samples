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
* FAQ:ArkTS是否支持反射调用类的静态成员函数和实例成员函数
* FAQ:是否支持模块的动态加载？如何实现
 */

// [Start harlibrary_index]
// HAP's Index.ets
import('harlibrary').then((ns:ESObject) => {
  ns.Calc.staticAdd(8, 9);  // Call static member functions staticAdd()
  let calc:ESObject = new ns.Calc();  // Instantiate class Calc
  calc.instanceAdd(10, 11);  // Call member functions instanceAdd()
  ns.addHarlibrary(6, 7);  // Call global methods addHarlibrary()

  // Use string names of classes, member functions, and methods for reflection calls
  let className = 'Calc';
  let methodName = 'instanceAdd';
  let staticMethod = 'staticAdd';
  let functionName = 'addHarlibrary';
  ns[className][staticMethod](12, 13);  // Call static member functions staticAdd()
  let calc1:ESObject = new ns[className]();  // Instantiate class Calc
  calc1[methodName](14, 15);  // Call member functions instanceAdd()
  ns[functionName](16, 17);  // Call global methods addHarlibrary()
});
// [End harlibrary_index]