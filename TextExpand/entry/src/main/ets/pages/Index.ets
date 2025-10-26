/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

//[Start Expand_index]
import { RichTextExpand } from './RichTextExpand';
import { TextExpand } from './TextExpand';
import router from '@ohos.router';

@Entry
@Component
struct Index {
  uiContext = this.getUIContext()

  build() {
    Column({ space: 15 }) {
      //[StartExclude Expand_index]
      Row() {
        Text($r('app.string.home_Title'))
          .margin({ top: 68 })
          .fontSize(26)
          .fontWeight(700)
      }
      .width('100%')

      Column({ space: 15 }) {
        Button($r('app.string.home_Title'), { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
          .width('100%')
          .onClick(() => {
            this.uiContext.getRouter().pushUrl({
              url: 'pages/RichTextExpand'
            });
          })

        Button($r('app.string.home_Title_plain'),
          { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
          .width('100%')
          .onClick(() => {
            this.uiContext.getRouter().pushUrl({
              url: 'pages/TextExpand'
            });
          })
      }
      //[EndExclude Expand_index]
    }
    .padding({ left: 16, right: 16, bottom: 16 })
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  //[Start expand_index_page]
  @Builder
  PageBuilder(name: string) {
    if (name === 'TextExpand') {
      TextExpand();
    } else if (name === 'RichTextExpand') {
      RichTextExpand();
    }
  }

  //[End expand_index_page]
}

//[End expand_index]