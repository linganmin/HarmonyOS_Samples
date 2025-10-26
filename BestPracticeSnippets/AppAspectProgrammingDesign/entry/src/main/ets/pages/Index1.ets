// index.ets
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

// [Start index1]
// index.ets
import { util } from '@kit.ArkTS';
import { Test } from '../components/somePackage';

@Entry
@Component
struct Index {
  build() {
    // UI code
  }
}
util.TextDecoder.toString();
// increment call count
let countFoo = 0;
util.Aspect.addBefore(Test, 'foo', false, () => {
  countFoo++;
});
// Invoke and print logs
new Test().foo();
console.log('countFoo = ', countFoo);
// [LOG]: "countFoo = ", 1
let a = new Test();
a.foo()
console.log('countFoo = ', countFoo);
// [LOG]: "countFoo = ", 2
function bar(a: Test) {
  a.foo();
  console.log('countFoo = ', countFoo);
  new Test().foo();
  console.log('countFoo = ', countFoo);
}
bar(a);
// [LOG]: "countFoo = ", 3
// [LOG]: "countFoo = ", 4
console.log('countFoo = ', countFoo);
// [LOG]: "countFoo = ", 4
// [End index1]