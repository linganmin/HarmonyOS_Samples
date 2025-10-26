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

import CommunicationArea from '../view/CommunicationArea';
import { FooterBar } from '../view/FooterBar';
import { HeaderBar } from '../view/HeaderBar';
import { common } from '@kit.AbilityKit';

// [Start pull_up_application]
const pullUpApplication = (context: common.UIAbilityContext) => {
  const link = 'https://appgallery.huawei.com/app/detail?id=com.huawei.hmsapp.books';
  context.openLink(link);
}
// [End pull_up_application]

@Entry
@Component
struct Index {
  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        CommunicationArea()
        HeaderBar()
      }
      .layoutWeight(1)

      FooterBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}