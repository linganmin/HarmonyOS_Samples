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
* FAQ:如何实现匿名内部类
*/

// [Start AnonymousInnerClass1]
class A {
  foo() {
    class B {
      v: number = 123;
    }
    let b = new B();
  }
}
// [End AnonymousInnerClass1]

// [Start AnonymousInnerClass2]
export interface AnonymousInnerClass<T> {
  onSuccess: (t: T) => void;
  onFailed: (code: string, reason: string) => void;
}

let AnonymousInnerClassInstance: AnonymousInnerClass<void> = {
  onSuccess: () => {
    console.log('success');
  },
  onFailed: () => {
    console.log('failed');
  }
}
// [End AnonymousInnerClass2]

