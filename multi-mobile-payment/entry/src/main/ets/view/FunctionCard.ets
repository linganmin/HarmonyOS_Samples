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

import { Constants } from '../common/Constants';
import { QuickFunctionItem } from '../viewmodel/PayHubViewModel';

@Component
export struct FunctionCard {
  @Prop data: QuickFunctionItem;

  build() {
    Column() {
      Image(this.data.getImg())
        .width($r('app.float.icon_size'))
        .height($r('app.float.icon_size'))
        .objectFit(ImageFit.Contain)
        .margin({ bottom: 2 })
      Text(this.data.getText())
        .fontFamily($r('app.string.normal_font_family'))
        .fontSize($r('app.float.smallest_font_size'))
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .fontWeight(Constants.FONT_WEIGHT[0])
    }
  }
}