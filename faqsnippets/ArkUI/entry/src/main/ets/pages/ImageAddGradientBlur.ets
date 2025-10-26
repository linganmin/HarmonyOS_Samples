/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ:图片如何添加渐变模糊
*/

// [Start image_add_gradient_blur]
@Entry
@Component
struct ImageExample1 {
  privateResource1: Resource = $r('app.media.icon');
  @State imageSrc: Resource = this.privateResource1;

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
        Row({ space: 5 }) {
          Image(this.imageSrc)
            .linearGradientBlur(60, {
              fractionStops: [[0, 0], [0, 0.33], [1, 0.66], [1, 1]],
              direction: GradientDirection.Bottom
            })
        }
      }
    }
  }
}
// [End image_add_gradient_blur]