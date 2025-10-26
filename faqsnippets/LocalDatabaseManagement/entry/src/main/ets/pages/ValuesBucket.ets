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
import { ValueType } from '@kit.ArkData';

/*
* ValuesBucket是否有可动态添加字段的方式
 */

// [Start ValuesBucket1]
export type ValuesBucket = Record<string, ValueType | Uint8Array | null>;
// [End ValuesBucket1]

// [Start ValuesBucket2]
function set(): void {

  let value : ValuesBucket={};
  let name : string ='NAME';
  value[name]= 'cxx';
  value['AGE']=18;
  value['SALARY']=20000;
}
// [End ValuesBucket2]