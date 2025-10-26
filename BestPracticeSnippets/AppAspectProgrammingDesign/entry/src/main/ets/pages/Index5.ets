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

// [Start index5]
// index.ets
import {util} from '@kit.ArkTS';
import { Test2 } from '../components/somePackage';

@Entry
@Component
struct Index {
  build() {
    // UI code
  }
}
new Test2().foo('123');
// [LOG]: "123"
// replace the original method
util.Aspect.replace(Test2, 'foo', false, (instance: Test2, arg: string) => {
  console.log(arg + ' __replaced implementation');
});
new Test2().foo('123');
// [LOG]: "123 __replaced implementation"
// [End index5]