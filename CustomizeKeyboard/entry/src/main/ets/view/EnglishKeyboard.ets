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

import { EnglishKeyboardData, Menu } from '../viewmodel/MenuModel';
import { KeyboardController } from '../model/KeyboardController';
import { Constants } from '../constants/Constants';

@Component
export struct EnglishKeyboard {
  build() {
    Row() {
      Scroll() {
        Column() {
          Row({ space: Constants.ENGLISH_KEYBOARD_BUTTON_SPACE }) {
            ForEach(EnglishKeyboardData[0], (item: Menu) => {
              EnglishButton({ item: item })
            }, (item: Menu) => JSON.stringify(item))
          }

          Row({ space: Constants.ENGLISH_KEYBOARD_BUTTON_SPACE }) {
            ForEach(EnglishKeyboardData[1], (item: Menu) => {
              EnglishButton({ item: item })
            }, (item: Menu) => JSON.stringify(item))
          }
          .padding({
            left: $r('app.float.english_keyboard_padding_left'),
            right: $r('app.float.english_keyboard_padding_right'),
            top: $r('app.float.english_keyboard_padding_top')
          })

          Row({ space: Constants.ENGLISH_KEYBOARD_BUTTON_SPACE }) {
            ForEach(EnglishKeyboardData[2], (item: Menu) => {
              EnglishButton({ item: item })
            }, (item: Menu) => JSON.stringify(item))
          }
          .padding({ top: $r('app.float.english_keyboard_padding_top') })

          Row({ space: Constants.ENGLISH_KEYBOARD_BUTTON_SPACE }) {
            ForEach(EnglishKeyboardData[3], (item: Menu) => {
              EnglishButton({ item: item })
            }, (item: Menu) => JSON.stringify(item))
          }
          .padding({ top: $r('app.float.english_keyboard_padding_top') })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
  }
}

// [Start EnglishButton_start]
@Component
struct EnglishButton {
  @Consume inputText: string;
  // [StartExclude EnglishButton_start]
  @Prop item: Menu;
  @Consume keyboardController: KeyboardController;

  getEnglishText(item: Menu): string | Resource {
    if (this.keyboardController.isUpperCase && item.upperText) {
      return item.upperText;
    } else {
      return item.text;
    }
  }
  // [EndExclude EnglishButton_start]

  build() {
    Button({ type: ButtonType.Normal })
    // [StartExclude EnglishButton_start]
    {
      if (typeof this.getEnglishText(this.item) === 'string' ||
        (this.getEnglishText(this.item) as Resource).type !== Constants.RESOURCE_TYPE_MEDIA) {
        Text(this.getEnglishText(this.item))
      } else {
        Image(this.getEnglishText(this.item))
          .width(Constants.KEYBOARD_BUTTON_FONTSIZE_18)
          .height(Constants.KEYBOARD_BUTTON_FONTSIZE_18)
      }
    }
    .fontColor(Color.Black)
    .backgroundColor(this.item.backgroundColor)
    .borderRadius(Constants.KEYBOARD_BUTTON_RADIUS)
    .fontSize(Constants.KEYBOARD_BUTTON_FONTSIZE_18)
    .padding(0)
    .width(this.item.width)
    .height(this.item.height)
    // [EndExclude EnglishButton_start]
    .onClick(() => {
      this.inputText = this.keyboardController.onInput(this.getEnglishText(this.item));
    })
  }
}
// [End EnglishButton_start]