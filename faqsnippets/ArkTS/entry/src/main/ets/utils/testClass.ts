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
* FAQ:如何获取对象的所有方法
 */

// [Start test_class]
export class testClass {
  public test(): string {
    return "ArkUI Web Component";
  }


  public toString(): void {
    console.log('Web Component toString');
  }


  public FunToString(): void {
    console.log('Web Component toString');
  }
}
// [End test_class]