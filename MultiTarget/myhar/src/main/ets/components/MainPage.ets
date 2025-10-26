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
import BuildProfile from '../../../../BuildProfile';
import { OfficialSecond } from '../../../official_pages/OfficialSecondPage';
import { TestSecond } from '../../../test_pages/TestSecondPage';

@Component
export struct MainPage {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @Builder
  PagesMap(name: string) {
    if (name == 'official') {
      OfficialSecond();
    } else {
      TestSecond();
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Row() {
        Column() {
          TextArea({ text: $r('app.string.title_description') })
            .fontSize(16)
            .width('100%')
            .fontColor('#e6000000')
            .fontWeight(FontWeight.Normal)
            .borderRadius(16)
            .focusable(false)
          Image($r('app.media.HarImage'))
            .width('100%')
            .borderRadius(12)
            .padding({ top: 16 })
          Blank()
          Button($r('app.string.button_describe'))
            .fontSize(16)
            .height(40)
            .width('100%')
            .onClick(() => {
              this.pageInfos.pushPath({ name: BuildProfile.productName });
            })
        }
        .width('100%')
        .height('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .height('100%')
    }
    .navDestination(this.PagesMap)
    .hideTitleBar(true)
  }
}