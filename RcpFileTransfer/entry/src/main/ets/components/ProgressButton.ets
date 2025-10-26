/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

@Component
export struct ProgressBtn {
  @Prop progress: number = 0;
  @Prop text: ResourceStr = '';
  @Prop buttonHeight: number = 40;

  build() {
    Stack({ alignContent: Alignment.End }) {
      if (this.progress) {
        Progress({
          value: this.progress,
          total: 100,
          type: ProgressType.Capsule
        })
          .height('100%')
          .width('100%')
        Row() {
          Text(this.text)
            .fontSize(14)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        Text(`${this.progress}%`)
          .fontSize(12)
          .padding(5)
      } else {
        Button(this.text)
          .width('100%')
          .height('100%')
      }
    }
    .height(this.buttonHeight)
  }
}