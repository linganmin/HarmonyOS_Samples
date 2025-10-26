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

// [Start index6]
// index.ets
import {util} from '@kit.ArkTS';
import { Base } from '../components/base';
import { Child1 } from '../components/child1';
import { Child2 } from '../components/child2';

@Entry
@Component
struct Index {
  build() {
    // UI code
  }
}
// Modify the implementation of foo in Child1
util.Aspect.replace(Child1, 'foo', false, () => {
  console.log('changed Child1 foo');
});
new Base().foo();
// [LOG]: "hello"
new Child1().foo();
// [LOG]: "changed Child1 foo"
new Child2().foo();
// [LOG]: "hello"
// [End index6]