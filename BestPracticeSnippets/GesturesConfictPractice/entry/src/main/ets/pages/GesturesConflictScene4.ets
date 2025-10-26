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

// [Start gestures_conflict_scene4]
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct GesturesConflictScene4 {
  build() {
    Stack() {
      Column()// The bottom column
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)
        .gesture(
          SwipeGesture({ direction: SwipeDirection.Horizontal })//水平方向滑动手势
            .onAction((event) => {
              if (event) {
                try {
                  this.getUIContext().getPromptAction().showToast({ message: 'SwipeGesture' });
                } catch (err) {
                  let error = err as BusinessError;
                  hilog.error(0x0000, 'testTag', `showToast err, code: ${error.code}, mesage: ${error.message}`);
                }
              }
            })
        )
      Column()// The upper-level column
        .width(300)
        .height(100)
        .backgroundColor(Color.Red)
        .hitTestBehavior(HitTestMode.None)
    }
    .width(300)
    .height(300)
  }
}

// [End gestures_conflict_scene4]