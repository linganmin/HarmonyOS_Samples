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

// [Start gestures_conflict_scene6]
@Entry
@Component
struct GesturesConflictScene6 {
  @State message: string = 'Hello World';

  build() {
    Column()
      .width('100%')
      .height(200)
      .backgroundColor(Color.Brown)
      .onDragStart(() => {
        console.info('GesturesConflictScene6 Drag start.');
      })
      .gesture(
        TapGesture({ count: 1 })
          .tag('tap1')
          .onAction(() => {
            console.info('GesturesConflictScene6 TapGesture onAction.');
          }),
      )
      .onGestureJudgeBegin((gestureInfo: GestureInfo, event: BaseGestureEvent) => {
        if (gestureInfo.type === GestureControl.GestureType.LONG_PRESS_GESTURE) {
          let longPressEvent = event as LongPressGestureEvent;
          console.info('GesturesConflictScene6: ' + longPressEvent.repeat);
        }
        if (gestureInfo.type === GestureControl.GestureType.DRAG) {
          // Returning to the REJECT will fail the drag gesture
          return GestureJudgeResult.REJECT;
        } else if (gestureInfo.tag === 'tap1' && event.pressure > 10) {
          return GestureJudgeResult.CONTINUE
        }
        return GestureJudgeResult.CONTINUE;
      })
  }
}

// [End gestures_conflict_scene6]