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
* FAQ:如何理解AspectRatio对布局的影响
*/

// [Start understand_the_aspect_ratio_layout]
@Entry
@Component
struct VideoAdaptPage {
  build() {
    Column() {
      Column() {
        Video({})
          .layoutWeight(1)
          .borderRadius(12)
          .clip(true)
          .aspectRatio(1)
          .loop(true)
          .autoPlay(true)
          .muted(true)
          .margin({
            left: 20,
            top: 20,
            right: 20,
          })
      }
    }.height(2000)
  }
}
// [End understand_the_aspect_ratio_layout]