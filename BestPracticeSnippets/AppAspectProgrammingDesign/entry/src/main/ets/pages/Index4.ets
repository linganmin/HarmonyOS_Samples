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

// [Start index4]
// index.ets
import {util} from '@kit.ArkTS';
import { Person } from '../components/somePackage';

@Entry
@Component
struct Index {
  build() {
    // UI code
  }
}
// Verify the name and age members
util.Aspect.addBefore(Person, 'getInfo', false, (instance: Person) => {
  if (instance.name.length == 0) {
    throw Error('empty name');
  }
  if (instance.age < 0) {
    throw Error('invalid age');
  }
});
new Person('c', -1).getInfo();
// [End index4]