/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

import { WarningBox } from './WarningBox';

@Component
export struct HeaderBar {
  build() {
    Column() {
      Text('XXX')
        .height(56)
        .width('100%')
        .fontColor('rgb(24, 36, 49)')
        .fontSize(18)
        .fontWeight(500)
        .lineHeight(21)
        .letterSpacing(0)
        .textAlign(TextAlign.Center)
      WarningBox()
    }
    .width('100%')
    .zIndex(1)
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.KEYBOARD])
    .justifyContent(FlexAlign.Center)
  }
}