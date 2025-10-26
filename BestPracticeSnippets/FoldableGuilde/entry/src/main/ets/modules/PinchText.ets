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

@Component
export struct PinchText {
  text: string =
    '亲近大海，领悟海，体会到了海的心声，海自然与你共鸣，无需可以强求，也无需费力搜寻，海，始终都会以潮声与你相亲，已其海色伴你舒适。';
  @State textFontSize: number = 26;

  build() {
    Column() {
      Text(this.text).fontSize(this.textFontSize)
    }
    .gesture(PinchGesture({ fingers: 2 }).onActionUpdate((event: GestureEvent) => {
      let tmp = event.scale;
      if (tmp > 1.45) {
        tmp = 1.45;
      } else {
        tmp = 0.75;
      }
      this.textFontSize = 16 * tmp;
    }))
  }
}