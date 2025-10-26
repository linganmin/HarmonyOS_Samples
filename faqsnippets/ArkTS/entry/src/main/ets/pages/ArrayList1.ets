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
* FAQ:如何通过Index获取ArrayList中的元素
 */

// [Start array_list]
import { ArrayList } from '@kit.ArkTS';

let arrayList: ArrayList<number> = new ArrayList();
arrayList.add(0);
arrayList.add(1);
arrayList.add(2);
arrayList.add(3);
arrayList.add(4);
arrayList.add(5);
arrayList.add(6);
arrayList.add(7);
arrayList.add(8);
arrayList.add(9);

@Entry
@Component
struct Index {
  @State message: string = 'get arrayList value';

  build() {
    Row() {
      Column() {
        Button(this.message)
          .onClick(() => {
            console.info('arrayList[6]:', arrayList[6]);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End array_list]