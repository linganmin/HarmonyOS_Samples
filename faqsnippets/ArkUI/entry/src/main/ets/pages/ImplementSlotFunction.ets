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
* FAQ:如何实现类似插槽的功能
*/

// [Start implement_slot_function]
@Component
struct Child {
  @Builder funABuilder0() {}
  @BuilderParam aBuilder0: () => void = this.funABuilder0;

  build() {
    Column() {
      this.aBuilder0()
    }
  }
}

@Entry
@Component
struct Parent {
  @Builder componentBuilder() {
    Text(`Parent builder `)
  }

  build() {
    Column() {
      Child({ aBuilder0: this.componentBuilder })
    }
  }
}
// [End implement_slot_function]