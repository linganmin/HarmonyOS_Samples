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
* FAQ:预览告警“There are properties not initialized”
*/

// [Start global_data]
// [Start import_mock_setup_annotation]
import { MockSetup } from '@ohos/hamock';
// [End import_mock_setup_annotation]

export default class Fruit{
  public name: string;

  getName(): string{
    return this.name;
  }

  constructor(name: string) {
    this.name = name;
  }

}

@Entry
@Component
struct GlobalData {
  @State fruit:Fruit = AppStorage.get("fruit") as Fruit;

  // [Start mock_setup_annotation]
  @MockSetup
  mock(){
    this.fruit = new Fruit("apple");
  }
  // [End mock_setup_annotation]

  build() {
    Row() {
      Column() {
        Text(this.fruit.name)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End global_data]
