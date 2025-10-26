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

/*
 * 最佳实践：Image白块解决问题指导
 *
 * 直接使用Image原生组件加载网络图片白块时长较长  反例
 */

// [Start PageOne_builder_other]
@Builder
export function PageOneBuilder(name: string) {
  PageOne()
}

@Component
export struct PageOne {
  pageInfo: NavPathStack = new NavPathStack();
  @State name: string = 'pageOne';

  build() {
    NavDestination() {
      Row() {
        // Not recommended usage: Using Image to directly load images from the internet is subject to delays caused by image downloading and parsing, which can easily result in white blocks.
        Image("https://www.example.com/xxx.png") // Please fill in a specific URL of the online image here.
          .objectFit(ImageFit.Auto)
          .width('100%')
          .height('100%')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .title(this.name)
  }
}
// [End PageOne_builder_other]