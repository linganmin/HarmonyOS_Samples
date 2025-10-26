/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import CommonConstants from '../common/constants/CommonConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * Keyboard tool class.
 */
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
class KeyEventListen {
  public isMultiSelect: boolean = false;
  public selectionStart: number = CommonConstants.COMMON_INITIAL_VALUE;
  public selectionEnd: number = CommonConstants.COMMON_INITIAL_VALUE;
  public notSelectionStart: number = CommonConstants.COMMON_INITIAL_VALUE;
  public notSelectionEnd: number = CommonConstants.COMMON_INITIAL_VALUE;
  public cursorPosition: number = CommonConstants.CURSOR_POSITION_INIT;
  public inputContent: string = '';
  static keyEventListen: KeyEventListen;

  static getInstance() {
    if (KeyEventListen.keyEventListen == null) {
      KeyEventListen.keyEventListen = new KeyEventListen();
    }
    return KeyEventListen.keyEventListen;
  }

  /**
   * Keyboard method.
   *
   * @param action Keyboard input status.
   * @param content Input value.
   * @returns
   */
  onKeyboardMethod(action: string, content?: string): string {
    // Sets the position of the cursor in the search box.
    if (action === CommonConstants.DELETE_CHARACTERS) {
      if (content !== undefined) {
        // Multiple-choice deletion.
        if (this.isMultiSelect) {
          this.inputContent = content.replace(content?.substring(this.notSelectionStart, this.notSelectionEnd), '');
          this.cursorPosition = this.notSelectionStart;
        } else if (content.length === this.selectionStart && content.length === this.selectionEnd) {
          // Deletes a character from the front or middle.
          this.inputContent = content?.substring(0, content.length - 1);
          this.cursorPosition = this.selectionEnd - 1;
        } else if (this.selectionStart === this.selectionEnd && content.length > this.selectionEnd) {
          // Deletes a character from the front or middle.
          this.inputContent = content.replace(content?.substring(this.selectionStart - 1, this.selectionEnd), '');
          this.cursorPosition = this.selectionStart - 1;
        }else{
          this.inputContent = content;
        }
      }
    } else if (action === CommonConstants.CLEAR_CHARACTERS) {
      this.inputContent = '';
      this.cursorPosition = 0;
    } else if (this.inputContent.length >= CommonConstants.MAXIMUM_NUMBER_INPUTS) {
      try {
        uiContext!.getPromptAction().showToast({
          message: $r('app.string.search_box_prompt')
        });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'KeyEventListen', `showToast failed, error code=${err.code}, message=${err.message}`);
      }
      return this.inputContent;
    } else if (action === CommonConstants.STRING_CHARACTERS && content !== undefined) {
      if (this.isMultiSelect) {
        // Obtains the characters in the current search box.
        let currentContent = this.inputContent;
        // Obtains the selected deleted characters.
        currentContent = currentContent.replace(currentContent?.substring(this.notSelectionStart,
          this.notSelectionEnd), '');
        // Add Characters.
        this.inputContent = currentContent.slice(0, this.notSelectionStart) +
          content + currentContent.slice(this.notSelectionStart);
        this.cursorPosition = this.notSelectionStart + content.length;
      } else if (this.selectionStart === this.selectionEnd && this.selectionStart < this.inputContent.length) {
        if (this.selectionStart === 0 && this.selectionEnd === 0) {
          // Add a character from the front.
          this.inputContent = content + this.inputContent;
          this.cursorPosition = content.length;
        } else {
          // Add a character from the middle.
          this.inputContent = this.inputContent.slice(0, this.selectionStart) +
            content + this.inputContent.slice(this.selectionStart);
          this.cursorPosition = this.selectionStart + content.length;
        }
      } else {
        // Add a character from the last.
        this.inputContent += content;
        this.cursorPosition = this.selectionEnd + content.length;
      }
    }
    return this.inputContent;
  }
}

export default KeyEventListen.getInstance();