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

import { emitter } from '@kit.BasicServicesKit';
import { Constants } from '../constants/Constants';

export class KeyboardController {
  textInputController?: TextInputController;
  text: string = '';
  leftCaretPos: number = 0;
  rightCaretPos: number = 0;
  targetCaretPos: number = 0;
  keyboardType: string = Constants.NUMBER_KEYBOARD;
  isUpperCase: boolean = false;

  // [Start onInput_start]
  onInput(value: string | Resource): string {
    // [StartExclude onInput_start]
    if (value === undefined || value === null) {
      return '';
    }
    if (typeof value === 'string') {
      this.text = this.text.substring(0, this.leftCaretPos) + value + this.text.substring(this.rightCaretPos);
      this.targetCaretPos = this.leftCaretPos + value.length;
      return this.text;
    }
    // [EndExclude onInput_start]

    switch (value.id) {
      // [StartExclude onInput_start]
      case $r('app.string.keyboardButton_delete').id:
        if (this.rightCaretPos === this.leftCaretPos && this.leftCaretPos > 0) {
          this.leftCaretPos--;
        }
        this.text = this.text.substring(0, this.leftCaretPos) + this.text.substring(this.rightCaretPos);
        this.targetCaretPos = this.leftCaretPos;
        break;
      case $r('app.string.keyboardButton_clear').id:
        this.text = '';
        this.targetCaretPos = 0;
        break;
    // [EndExclude onInput_start]
      case $r('app.string.keyboardButton_finish').id:
        this.textInputController?.stopEditing();
        break;
    // [StartExclude onInput_start]
      case $r('app.string.tabButton_english_text').id:
        this.keyboardType = Constants.ENGLISH_KEYBOARD;
        break;
      case $r('app.string.tabButton_number_text').id:
        this.keyboardType = Constants.NUMBER_KEYBOARD;
        break;
      case $r('app.string.keyboardButton_space').id:
        this.text = this.text.substring(0, this.leftCaretPos) + ' ' + this.text.substring(this.rightCaretPos);
        this.targetCaretPos = this.leftCaretPos + 1;
        break;
      case $r('app.media.arrowshape_up').id:
      case $r('app.media.arrowshape_up_fill').id:
        this.isUpperCase = !this.isUpperCase;
        break;
      // [EndExclude onInput_start]
    }
    return this.text;
  }
  // [End onInput_start]

  onPaste(value: string) {
    this.text = this.text.substring(0, this.leftCaretPos) + value + this.text.substring(this.rightCaretPos);
    this.targetCaretPos = this.leftCaretPos + value.length;
  }

  // [Start textInputController_start]
  onChange(value: string) {
    this.text = value;
    if (this.keyboardType !== 'System') {
      this.textInputController?.caretPosition(this.targetCaretPos);
    }
  }
  // [End textInputController_start]

  setCaretPosition(start: number, end: number) {
    this.leftCaretPos = start;
    this.rightCaretPos = end;
  }

  onCut() {
    this.text = this.text.substring(0, this.leftCaretPos) + this.text.substring(this.rightCaretPos);
    this.targetCaretPos = this.leftCaretPos;
  }

  // [Start changeAvoidHeight_start]
  changeAvoidHeight(value: number) {
    let event: emitter.InnerEvent = {
      eventId: Constants.AVOID_EVENT_ID
    };
    let eventData: emitter.EventData = {
      data: {
        'avoidHeight': value
      }
    };
    emitter.emit(event, eventData);
  }
  // [End changeAvoidHeight_start]
}