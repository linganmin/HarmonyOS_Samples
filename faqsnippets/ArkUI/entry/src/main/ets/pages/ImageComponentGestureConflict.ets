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
* FAQ:Image组件长按和拖拽的系统手势和自定义手势冲突
*/

// [Start image_component_gesture_conflict]
@Entry
@Component
struct Index {
  build() {
    Column() {
      Image($r('app.media.app_icon'))
        .width('80%')
        .parallelGesture(GestureGroup(GestureMode.Exclusive,
          TapGesture({ count: 2, fingers: 1 })
          // Double click
            .onAction(() => {
              console.log('TapGesture--double click');
            }),
          TapGesture({ count: 1, fingers: 1 })
          // TapGesture single
            .onAction(() => {
              console.log('TapGesture--single click');
            }),
          LongPressGesture({ repeat: true })
          // LongPressGesture Long
            .onAction(() => {
              console.log('LongPressGesture--Long press');
            }),
          PanGesture()
          // PanGesture drag
            .onActionStart((gestureEvent: GestureEvent | undefined) => {
              console.info('PanGesture--drag');
            })
        ))
    }
    .height('100%')
    .width('100%')
  }
}

// [End image_component_gesture_conflict]