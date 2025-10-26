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

import { UIAbility } from "@kit.AbilityKit";
import { window, KeyboardAvoidMode } from '@kit.ArkUI';

@Entry
@Component
struct ExamplePage {
  // [Start set_avoid_mode_none]
  aboutToAppear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.NONE);
  }
  // [End set_avoid_mode_none]

  build() {
   Column(){
     // [Start Text_input_true]
     TextInput()
       .defaultFocus(true)
     // [End Text_input_true]
     // [Start Text_input_input1]
     TextInput({ placeholder: 'Please enter a contact name' })
       .id('input1')

     Button('login')
       .onClick(() => {
         this.getUIContext().getFocusController().requestFocus('input1');
       })
     // [End Text_input_input1]
     // [Start Button_search]
     Button('Search')
       .onClick(() => {
         this.getUIContext().getFocusController().clearFocus();
       })
     // [End Button_search]
   }
  }
}

// [Start Entry_ability_set_keyboard_avoid_mode_resize]
export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/GetSafeAreaHeightDemo', (err) => {
      // Compression mode
      windowStage.getMainWindowSync().getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
    });
  }
}
// [End Entry_ability_set_keyboard_avoid_mode_resize]

// [Start stop_editing]
@Component
struct StopEditingCpt {
  private controller: TextInputController = new TextInputController();

  build() {
    Column() {
      TextInput({ placeholder: 'Input', controller: this.controller })

      Button('Search')
        .onClick(() => {
          this.controller.stopEditing();
        })
    }
  }
}
// [End stop_editing]
