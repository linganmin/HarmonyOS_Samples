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

import { CustomExeColumnModifier } from '../viewmodel/ComponentModifier';

@Component
export struct ShowInfoComponent {
  @Link executeContents: string;
  @Link threadContents: string;
  private exeColumn: CustomExeColumnModifier = new CustomExeColumnModifier();

  build() {
      Column({ space: 12 }) {
        Text($r('app.string.RunInfo'))
          .width('100%')
          .fontWeight(FontWeight.Bold)

        Column() {
          Scroll() {
            Text(this.executeContents)
              .width('100%')
          }
          .margin({ top: '8vp', left: '16vp', right: '16vp' })
        }
        .height('328vp')
        .attributeModifier(this.exeColumn)

        Text($r('app.string.ThreadInfo'))
          .width('100%')
          .fontWeight(FontWeight.Bold)

        Column() {
          Scroll() {
            Text(this.threadContents)
              .width('100%')
          }
          .margin({ top: '8vp', left: '16vp', right: '16vp' })
        }
        .height('128vp')
        .attributeModifier(this.exeColumn)
      }
      .width('100%')
      .margin({ bottom: '4vp' })
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Center)
    }
}