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
* FAQ:父组件如何与孙子组件进行状态同步
*/

// [Start component_status_synchronization_two_one]
@Entry
@ComponentV2
struct Father {
  @Local reviewVotes: number = 0;


  build() {
    Column() {
      Son({ reviewVotes: this.reviewVotes })
      Button(`Father: ${this.reviewVotes}`)
    }
  }
}
// [End component_status_synchronization_two_one]

// [Start component_status_synchronization_two_two]
@ComponentV2
struct Son {
  @Require @Param reviewVotes: number = 1;


  build() {
    Column() {
      Grandson({ reviewVotes: this.reviewVotes })
    }
  }
}
// [End component_status_synchronization_two_two]

// [Start component_status_synchronization_two_three]
@ComponentV2
struct Grandson {
  @Require @Param reviewVotes: number = 1;


  build() {
    Column() {
      Button(`Grandson: ${this.reviewVotes}`)
    }.width('100%')
  }
}
// [End component_status_synchronization_two_three]