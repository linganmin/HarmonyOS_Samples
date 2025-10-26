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
// [Start index]
// index.ets
import { util } from '@kit.ArkTS';
import { A } from '../components/baseAbility';

@Entry
@Component
struct Index {
  build() {
    // UI code
  }
}

util.Aspect.addBefore(A, 'getElementByIndex', false,
  // Check the parameters
  (instance: A, arr: Object, idx: number) => {
    if (!(arr instanceof Array)) {
      throw Error('arg arr is expected to be an array');
    }
    if (!(Number.isInteger(idx) && idx >= 0)) {
      throw Error('arg idx is expected to be a non-negative integer');
    }
    if (idx >= arr.length) {
      throw Error('arg idx is expected to be smaller than arr.length');
    }
  });
// The original method is executed
let buffer: Array<number> = [1, 2, 3, 5];
let that = new A();
that.getElementByIndex(buffer, -1);
that.getElementByIndex(buffer, 5);
that.getElementByIndex(123 as Object as Array<number>, 5)
// [End index]