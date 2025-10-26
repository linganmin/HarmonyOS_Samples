/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * FAQ: 如何在ArkTS侧引用其他三方so库
 */
// [Start import_third_party_libraries_ets]
import testNapi from 'libimportthirdpartylibraries.so';
import myNapi from 'libapplication.so';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            console.info(`MyTest NAPI 2 + 3 = ${myNapi.add(2, 3)}`);
            console.info(`MyTest NAPI 2 - 3 = ${testNapi.sub(2, 3)}`);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End import_third_party_libraries_ets]