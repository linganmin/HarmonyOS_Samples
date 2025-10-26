/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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
* FAQ:如何在Index.ets中导出默认导出的对象
*/

// [Start implement_unified_page_graying_function]
@Entry
@Component
struct Index {
  @State grayscaleValue: number = 0;

  build() {
    Column({ space: 20 }) {
      Image($r("app.media.app_icon"))
        .height(100)
      Row({ space: 20 }) {
        Button("Set Gray")
          .onClick(() => {
            this.grayscaleValue = 1; // Set grayscale to 100%
          })
        Button("Restore")
          .onClick(() => {
            this.grayscaleValue = 0; // Set grayscale to 0%
          })
      }
    }
    .width("100%")
    .height("100%")
    .backgroundColor('#fcd473')
    .padding(10)
    .grayscale(this.grayscaleValue)
  }
}
// [End implement_unified_page_graying_function]