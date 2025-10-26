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
import { TabButton } from './TabButton';

@Component
export struct TabView {
  build() {
    Row({ space: Constants.DEFAULT_COLUMN_SPACE }) {
      TabButton({ text: $r('app.string.tabButton_number_text'), type: Constants.NUMBER_KEYBOARD })
      TabButton({ text: $r('app.string.tabButton_english_text'), type: Constants.ENGLISH_KEYBOARD })
      TabButton({ text: $r('app.string.tabButton_system_text'), type: Constants.SYSTEM_KEYBOARD })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .margin({ top: $r('app.float.main_page_margin_top') })
    .height($r('app.float.tabview_height'))
    .backgroundColor($r('app.color.keyboard_background_color'))
  }
}