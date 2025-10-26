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

import { Menu, numberKeyboardData } from '../viewmodel/MenuModel';
import { KeyboardController } from '../model/KeyboardController';
import { Constants } from '../constants/Constants';

// [Start NumberKeyboard_start]
@Component
export struct NumberKeyboard {
  @Consume inputText: string;
  @Consume keyboardController: KeyboardController;
  layoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
    irregularIndexes: [14, 16],
    onGetIrregularSizeByIndex: (index: number) => {
      if (index === 14) {
        return [2, 1];
      }
      return [1, 2];
    }
  };

  build() {
    Grid(undefined, this.layoutOptions) {
      ForEach(numberKeyboardData, (item: Menu) => {
        GridItem() {
          Button(item.text, { type: ButtonType.Normal })
            .fontColor(Color.Black)
            .backgroundColor(item.backgroundColor)
            .borderRadius(Constants.KEYBOARD_BUTTON_RADIUS)
            .fontSize(Constants.KEYBOARD_BUTTON_FONTSIZE_18)
            .padding(0)
            .width(item.width)
            .height(item.height)
            .onClick(() => {
              this.inputText = this.keyboardController.onInput(item.text);
            })
        }
      }, (item: Menu) => JSON.stringify(item))
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
    .rowsGap($r('app.float.number_keyboard_grid_gap'))
    .columnsGap($r('app.float.number_keyboard_grid_gap'))
  }
}
// [End NumberKeyboard_start]