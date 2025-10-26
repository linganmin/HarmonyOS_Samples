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
import { KeySourceListType } from '../model/MenuData';
import { Logger } from '../common/utils/Logger';

@Component
export struct EnglishKeyItem {
  public keyValue: KeySourceListType | undefined = undefined;
  public color: ResourceStr = $r('app.color.font_background_white');
  @Link upper: boolean;
  @Consume searchContent: string;
  @Consume menuType: number;

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.state_styles_pressed'))
  }

  @Styles
  normalStyles() {
    .backgroundColor(this.color)
  }

  getResourceString(resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (error) {
      Logger.error('getResourceString err:' + JSON.stringify(error));
    }
    return resourceString;
  }

  build() {
    Text(this.upper ? this.keyValue?.upperContent : this.keyValue?.content)
      .fontSize($r('app.float.comm_text_size'))
      .fontColor(this.keyValue?.content === $r('app.string.text_search') ?
        $r('app.color.font_background_white') : $r('app.color.font_color'))
      .textAlign(TextAlign.Center)
      .borderRadius($r('app.float.comm_image_radius'))
      .width(CommonConstants.PERCENTAGE_MAX)
      .height(CommonConstants.PERCENTAGE_MAX)
      .onClick(() => {
        if (this.keyValue?.content === CommonConstants.TEXT_DIGIT) {
          this.menuType = CommonConstants.KEYBOARD_TYPE_DIGIT;
        } else if (this.getResourceString(this.keyValue?.content as Resource) ===
        this.getResourceString($r('app.string.text_space'))) {
          this.searchContent = KeyEventListen.onKeyboardMethod(CommonConstants.STRING_CHARACTERS, ' ');
        } else if (this.getResourceString(this.keyValue?.content as Resource) ===
        this.getResourceString($r('app.string.text_search'))) {
          return;
        } else {
          this.searchContent = KeyEventListen.onKeyboardMethod(CommonConstants.STRING_CHARACTERS, this.upper ?
            this.keyValue?.upperContent as string : this.keyValue?.content as string);
        }
      })
      .stateStyles({ normal: this.normalStyles, pressed: this.pressedStyles })
  }
}