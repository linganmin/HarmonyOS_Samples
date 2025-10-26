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

import { AppStorageV2, SymbolGlyphModifier } from '@kit.ArkUI';
import Constants from '../commom/Constants';
import SystemAreaModel from '../model/SystemAreaModel';
import PayCodeView from '../view/PayCodeView';

const context: UIContext = AppStorage.get("context") as UIContext;

@ComponentV2
struct PayCodePage {
  build() {
    Column() {
      PayCodeView()
    }
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#0954EA', 0.0], ['#6193F6', 0.5], ['#88AFFC', 1.0]]
    })
    .padding({ left: 16, right: 16 })
  }
}

const systemAreaModel: SystemAreaModel =
  AppStorageV2.connect(SystemAreaModel, 'systemAreaModel', () => new SystemAreaModel(0, 0)) as SystemAreaModel;

@Builder
function payCodePageBuilder(name: string): void {
  if (name === Constants.NAV_DESTINATION_ITEM_PAY_CODE) {
    NavDestination() {
      PayCodePage();
    }
    .backButtonIcon(new SymbolGlyphModifier().fontColor([Color.White]))
    .title(title())
    .backgroundColor('#0954EA')
    .padding({ top: context.px2vp(systemAreaModel.topRectHeight) })
  } else {
    NavDestination()
      .title('PayCodePage UI Error!')
  }
}

export const wrappedBuilderPayCode: WrappedBuilder<[string]> =
  wrapBuilder(payCodePageBuilder);

@Builder
function title() {
  Row() {
    Text($r('app.string.page_pay_code'))
      .fontSize(20)
      .fontWeight(700)
      .fontColor(Color.White)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .lineHeight(27)
      .width(152)
  }
  .width(Constants.FULL_PERCENT)
  .height(Constants.FULL_PERCENT)
  .padding({ left: 8 })
}