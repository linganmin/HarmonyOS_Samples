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
* 最佳实践: 一多窗口适配开发实践
*/

// [Start index]
@Entry
@Component
struct Index {
  @StorageLink('topAvoidHeight') topAvoidHeight: number = 0;
  @StorageLink('bottomAvoidHeight') bottomAvoidHeight: number = 0;

  build() {
    Column() {
      // ...
    }
    .height('100%')
    .width('100%')
    .padding({
      top: this.topAvoidHeight,
      bottom: this.bottomAvoidHeight
    })
  }
}
// [End index]