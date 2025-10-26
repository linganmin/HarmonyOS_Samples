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

// [Start gestures_conflict_scene2]
@Entry
@Component
struct GesturesConflictScene2 {
  @State count1: number = 0;
  @State count2: number = 0;

  build() {
    Column() {
      Text('Exclusive gesture\n' + 'Click count is:' + this.count1 + '\nDouble click count is:' + this.count2 + '\n')
        .fontSize(28)
    }
    .height(200)
    .width('100%')
    // The following gestures are mutually exclusive. After the gesture is successfully recognized, the gesture cannot be recognized by double-clicking
    // [Start getture_group2]
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        TapGesture({ count: 1 })
          .onAction(() => {
            this.count1++;
          }),
        TapGesture({ count: 2 })
          .onAction(() => {
            this.count2++;
          })
      )
    )
    // [End getture_group2]
  }
}

// [End gestures_conflict_scene2]