/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
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
import { LengthMetrics } from '@kit.ArkUI'

@Component
struct DialogComponent {
  build() {
    Column() {
      TextInput({ placeholder: 'Please input' })
        .width('100%')
        .height(100)
        .backgroundColor(Color.White)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#80000000')
  }
}

@Entry
@Component
struct CustomDialogAvoid {
  @Builder
  customDialogBuilder() {
    DialogComponent()
  }

  build() {
    Column() {
      Blank().layoutWeight(1)
      Button('Open CustomDialog Avoid None')
        .onClick(() => {
          // [Start dialog_avoid_mode]
          this.getUIContext().getPromptAction().openCustomDialog({
            builder: () => {
              this.customDialogBuilder();
            },
            alignment: DialogAlignment.Bottom,
            width: '100%',
            // Set not avoid keyboard
            keyboardAvoidMode: KeyboardAvoidMode.NONE,
          });
          // [End dialog_avoid_mode]
        })

      Button('Open CustomDialog Set Distance')
        .onClick(() => {
          // [Start set_distance]
          this.getUIContext().getPromptAction().openCustomDialog({
            builder: () => {
              this.customDialogBuilder();
            },
            alignment: DialogAlignment.Bottom,
            width: '100%',
            // Set the distance between the soft keyboard and custom dialog to 0
            keyboardAvoidDistance:LengthMetrics.vp(0)
          });
          // [End set_distance]
        })
        .margin({
          top: 16,
          bottom: 50
        })
    }
    .height('100%')
    .width('100%')
  }
}