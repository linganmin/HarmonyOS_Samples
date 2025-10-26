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
* FAQ:如何实现跨文件组件复用
*/

// [Start implement_cross_file_component_reuse_two]
import { ImageText, ImageModifier, TextModifier, CheckboxModifier } from './CommonText';

@Entry
@Component
struct Details {
  // User creates an AttributeModifier implementation class instance for the provider
  @State textOne: TextModifier = new TextModifier(36);
  @State imageModifier: ImageModifier = new ImageModifier(100, 100);
  @State checkboxModifier: CheckboxModifier = new CheckboxModifier(20);

  build(){
    Row(){
      ImageText({
        textOne: this.textOne,
        imageModifier: this.imageModifier,
        imageSrc: $r('app.media.icon'),
        checkboxModifier: this.checkboxModifier,
        textOneContent: 'hello'
      })
    }
    .width('100%')
    .height('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
// [End implement_cross_file_component_reuse_two]