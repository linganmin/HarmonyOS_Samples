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
* FAQ:如何将JSON对象转换成HashMap
 */

// [Start hash_map]
import { HashMap } from '@kit.ArkTS';

let str: string = '{\"common_params\": {' +
  '\"city_id\": 1,' +
  '\"nav_id_list\": \"\",' +
  '\"show_hook_card\": 2,' +
  '\"use_one_stop_structure\": 1,' +
  '\"version_tag\": \"homepageonestop\"' +
  '}' +
  '}';

let jsonObj: Object = JSON.parse(str);
let commObj = (jsonObj as Record<string, Object>);
let commRecord = (commObj['common_params'] as Record<string, Object>);
let keyStr = Object.keys(commRecord);

for (let index: number = 0; index < keyStr.length; index++) {
  commRecord[keyStr[index].toString()].toString();
}

let hashMapData: HashMap<string, Object> = new HashMap();
hashMapData.set('common_params', commRecord);

@Entry
@Component
struct Index {
  build() {
    Row() {
      Column() {
        Button('JSON to HashMap')
          .onClick(() => {
            // common_params: {"city_id":1,"nav_id_list":"","show_hook_card":2,"use_one_stop_structure":1,"version_tag":"homepageonestop"}
            console.log('common_params:', JSON.stringify(hashMapData.get('common_params')));
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End hash_map]