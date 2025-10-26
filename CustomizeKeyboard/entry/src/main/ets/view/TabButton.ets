/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Constants } from '../constants/Constants';
import { KeyboardController } from '../model/KeyboardController';

@Component
export struct TabButton {
  @Consume isCustomKeyboardAttach: boolean;
  @Prop text: Resource;
  @Prop type: string;
  @Consume keyboardController: KeyboardController;

  build() {
    Button(this.text, { type: ButtonType.Normal })
      .width($r('app.float.tabview_button_width'))
      .height($r('app.float.tabview_button_height'))
      .borderRadius(Constants.BUTTON_BORDER)
      .fontSize(Constants.KEYBOARD_BUTTON_FONTSIZE_20)
      .margin({ top: $r('app.float.keyboard_padding_top') })
      .backgroundColor(this.keyboardController.keyboardType === this.type ? Color.White :
      $r('app.color.keyboard_background_color'))
      .fontColor(this.keyboardController.keyboardType === this.type ? $r('app.color.menu_color_blue') :
      Color.Black)
      .onClick(() => {
        this.keyboardController.keyboardType = this.type;
        this.isCustomKeyboardAttach = this.type !== Constants.SYSTEM_KEYBOARD;
      })
  }
}