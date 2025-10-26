/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Constants from '../common/Constants'
import AutoModeView from '../view/AutoModeView';

@Component
struct AutoModePage {
  build() {
    Column() {
      AutoModeView()
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .padding({ left: 16, right: 16 })
  }
}

@Builder
function autoPageBuilder(name: string): void {
  if (name === Constants.NAV_DESTINATION_ITEM_AUTO_MODE) {
    NavDestination() {
      AutoModePage();
    }
    .title(title())
    .backgroundColor('#F1F3F5')
  } else {
    NavDestination()
      .title('UI Error')
  }
}

export const wrappedBuilderAutoMode: WrappedBuilder<[string]> =
  wrapBuilder(autoPageBuilder);

@Builder
function title() {
  Row() {
    Text($r('app.string.auto_mode'))
      .fontSize(20)
      .fontWeight(700)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .lineHeight(27)
      .width(152)
  }
  .width(Constants.FULL_PERCENT)
  .height(Constants.FULL_PERCENT)
  .padding({ left: 8 })
}