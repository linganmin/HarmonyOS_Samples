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
* FAQ:如何主动通过手势缩放变焦比
*/

// [Start GestureScale]
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  build() {
    Column() {
      // Binding gestures
    }.gesture(PinchGesture({ fingers: 2 })
      .onActionStart((event: GestureEvent) => {
        hilog.info(0x0001, '[Scan Sample]', 'Pinch start');
      })
      .onActionUpdate((event: GestureEvent) => {
        if (event) {
          // Gesture scaling ratio
          let scaleValue = event.scale;
          // 1. Set zoom ratio during gesture following process
        }
      })
      .onActionEnd((event: GestureEvent) => {
        // 2. After lifting the gesture, set the zoom ratio
      })
    )
  }
}
// [End GestureScale]

