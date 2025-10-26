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
* FAQ:使用BuilderParam在父组件调用this的方法报错：Error message:is not callable
*/

// [Start resolving_is_not_callable_one]
@Component
struct Child {
  @Builder
  FunABuilder0() {};

  @BuilderParam aBuilder0: () => void = this.FunABuilder0;

  build() {
    Column() {
      this.aBuilder0()
    }
  }
}

@Entry
@Component
struct Parent {
  @Builder
  componentBuilder() {
    Text('Parent builder')
      .onClick(() => {
        this.test1();
      })
  }

  test1(): void {
    console.info('test1');
  }

  build() {
    Column() {
      Child({ aBuilder0: this.componentBuilder })
    }
  }
}

// [End resolving_is_not_callable_one]


@Component
struct ChildTest {
  @Builder
  componentBuilder() {
    Text('Parent builder')
      .onClick(() => {
      })
  }

  build() {
    // [Start resolving_is_not_callable_two]
    Child({
      aBuilder0: () => {
        this.componentBuilder()
      }
    })
    // [End resolving_is_not_callable_two]
  }
}
