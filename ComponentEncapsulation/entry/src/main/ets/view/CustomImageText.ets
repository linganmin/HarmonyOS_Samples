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


// [Start image_modifier]
// The AttributeModifier interface implementation class for the Image component.
export class CustomImageModifier implements AttributeModifier<ImageAttribute> {
  private imageWidth: Length = 0;
  private imageHeight: Length = 0;

  constructor(width: Length, height: Length) {
    this.imageWidth = width;
    this.imageHeight = height;
  }

  width(width: Length) {
    this.imageWidth = width;
    return this;
  }

  height(height: Length) {
    this.imageHeight = height;
    return this;
  }

  applyNormalAttribute(instance: ImageAttribute): void {
    instance.width(this.imageWidth);
    instance.height(this.imageHeight);
    instance.borderRadius($r('app.float.border_radius'))

  }
}

// Text component's AttributeModifier interface implementation class.
export class CustomTextModifier implements AttributeModifier<TextAttribute> {
  constructor() {
  }

  applyNormalAttribute(instance: TextAttribute): void {
    instance.fontSize($r('app.float.font_size_l'));
  }
}
// [End image_modifier]

// [Start custom_image_text]
@Component
export struct CustomImageText {
  @Prop imageAttribute: AttributeModifier<ImageAttribute> = new CustomImageModifier(100, 100);
  @Prop textAttribute: AttributeModifier<TextAttribute> = new CustomTextModifier();
  @Prop imageSrc: PixelMap | ResourceStr | DrawableDescriptor;
  @Prop text: string;
  onClickEvent?: () => void;

  build() {
    Column({ space: 12 }) {
      Image(this.imageSrc)
        .attributeModifier(this.imageAttribute)
      Text(this.text)
        .attributeModifier(this.textAttribute)
    }.onClick(() => {
      if (this.onClickEvent !== undefined) {
        this.onClickEvent();
      }
    })
  }
}
// [End custom_image_text]
