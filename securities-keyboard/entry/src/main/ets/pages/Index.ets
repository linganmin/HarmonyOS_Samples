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
import KeyEventListen from '../viewmodel/KeyEventListen';
import { NumberKeyboard } from '../view/NumberKeyboard';
import { EnglishKeyboard } from '../view/EnglishKeyboard';

@Entry
@Component
struct Index {
  // Content in the search box.
  @Provide searchContent: string = '';
  // Input method type displayed in the menu on the page, Default: Securities Input Method.
  @Provide menuType: number = CommonConstants.KEYBOARD_TYPE_DIGIT;
  private searchController: SearchController = new SearchController();

  @Builder
  KeyBoardWindow() {
    Column() {
      Row() {
        Image($r('app.media.down'))
          .objectFit(ImageFit.Contain)
          .width($r('app.float.down_image_size'))
          .aspectRatio(CommonConstants.IMAGE_ASPECT_RATIO)
          .margin({
            top: $r('app.float.down_image_margin'),
            right: CommonConstants.DOWN_IMAGE_RIGHT
          })
          .onClick(() => this.searchController.stopEditing())
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
      .width(CommonConstants.PERCENTAGE_MAX)
      .backgroundColor($r('app.color.keyboard_background_color'))

      if (this.menuType === CommonConstants.KEYBOARD_TYPE_DIGIT) {
        NumberKeyboard()
      } else {
        EnglishKeyboard()
      }
    }
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      Row() {
        Column() {
          Search({
            controller: this.searchController,
            value: this.searchContent,
            placeholder: $r('app.string.search_content')
          })
            .selectionMenuHidden(true)
            .copyOption(CopyOptions.InApp)
            .width(CommonConstants.SEARCH_BOX_WIDTH)
            .height($r('app.float.search_height'))
            .margin($r('app.float.search_margin'))
            .borderRadius($r('app.float.search_border_radius'))
            .backgroundColor($r('app.color.search_background_color'))
            .fontColor($r('app.color.search_font_color'))
            .enableKeyboardOnFocus(false)
            .customKeyboard(this.KeyBoardWindow())
            .onTextSelectionChange((selectionStart: number, selectionEnd: number) => {
              if (selectionStart !== selectionEnd) {
                KeyEventListen.isMultiSelect = true;
                KeyEventListen.notSelectionStart = selectionStart;
                KeyEventListen.notSelectionEnd = selectionEnd;
              } else {
                KeyEventListen.isMultiSelect = false;
                KeyEventListen.selectionStart = selectionStart;
                KeyEventListen.selectionEnd = selectionEnd;
              }
            })
            .onChange((value: string) => {
              // Clear the contents of the search box.
              if (value === '') {
                this.searchContent = '';
                KeyEventListen.inputContent = '';
              }
              // Set the focus of the search box.
              this.searchController.caretPosition(KeyEventListen.cursorPosition);
            })
        }
        .justifyContent(FlexAlign.Start)
        .width(CommonConstants.PERCENTAGE_MAX)
        .height(CommonConstants.PERCENTAGE_MAX)
      }
      .justifyContent(FlexAlign.Start)
      .backgroundColor(Color.White)
      .width(CommonConstants.PERCENTAGE_MAX)
    }
  }
}