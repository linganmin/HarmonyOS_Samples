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

// [Start implement_cross_file_component_reuse_one]
// Set Image width & height
export class ImageModifier implements AttributeModifier<ImageAttribute> {
  width: number = 60;
  height: number = 60;

  constructor(width: number, height: number) {
    this.width = width;
    this.height = height
  }

  applyNormalAttribute(instance: ImageAttribute): void {
    instance.width(this.width);
    instance.height(this.height);
  }
}

/*
  Custom class implementation of the AttributeModifier interface for text, used for initialization
*/
// Set Text textSize
export class TextModifier implements AttributeModifier<TextAttribute> {
  textSize: number = 12;

  constructor(textSize: number) {
    this.textSize = textSize;
  }

  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontSize(this.textSize);
    instance.fontColor(Color.Orange);
    instance.textAlign(TextAlign.Center);
    instance.border({ width: 1, color: Color.Orange, style: BorderStyle.Solid });
    instance.margin({ right: 10 });
  }
}

/*
  Customize class to implement the AttributeModifier interface for the checkbox, used for initialization
*/
export class CheckboxModifier implements AttributeModifier<CheckboxAttribute> {
  size: number = 15;

  constructor(size: number) {
    if (size < 0) {
      size = 15;
    }
    this.size = size;
  }

  applyNormalAttribute(instance: CheckboxAttribute): void {
    instance.width(this.size);
    instance.height(this.size);
  }
}

/**
 * Customize encapsulated graphic and text components
 */
@Component
export struct ImageText {
  @State textContent: string | Resource = 'default';
  @State imageSrc: PixelMap | ResourceStr | DrawableDescriptor = $r('app.media.icon');
  //Accept externally passed AttributeModifier class instances, which can customize only some components and selectively pass parameters.
  @State textModifier: AttributeModifier<TextAttribute> = new TextModifier(12);
  @State imageModifier: AttributeModifier<ImageAttribute> = new ImageModifier(60, 60);
  @State checkboxModifier: AttributeModifier<CheckboxAttribute> = new CheckboxModifier(15);

  build() {
    Row() {
      Checkbox()
        .attributeModifier(this.checkboxModifier)

      Image(this.imageSrc)
        .attributeModifier(this.imageModifier)
        .margin({ right: 10 })

      Text(this.textContent)
        .attributeModifier(this.textModifier)
        .fontColor(Color.Orange)
    }
    .padding({ top: 5 })
    .margin({ right: 10, bottom: 15 })
    .width(200)
    .height(100)
  }
}

// [End implement_cross_file_component_reuse_one]