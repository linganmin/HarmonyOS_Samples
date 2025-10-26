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
import { getResourceString } from "../model/GetResourceString";

// [Start my_button_modifier1]
// The provider creates a custom Class that implements the system's AttributeModifier interface.
export class MyButtonModifier implements AttributeModifier<ButtonAttribute> {
  private buttonType: ButtonType = ButtonType.Normal;

  constructor() {
  }

  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.type(this.buttonType);
    instance.width(200);
    instance.height(50);
    instance.fontSize(20);
    instance.fontColor('#0A59F7')
    instance.backgroundColor('#0D000000')
  }

  applyPressedAttribute(instance: ButtonAttribute): void {
    instance.fontColor('#0A59F7')
    instance.backgroundColor('#26000000')
  }

  type(type: ButtonType): MyButtonModifier {
    this.buttonType = type;
    return this;
  }
}
// [End my_button_modifier1]

@Builder
export function AttributeStylePageBuilder() {
  AttributeStylePage()
}

// [Start use_modifier]
@Entry
@Component
struct AttributeStylePage {
  modifier = new MyButtonModifier()
    .type(ButtonType.Capsule)

  build() {
    NavDestination() {
      Column() {
        Button('Capsule Button')
          .attributeModifier(this.modifier)
      }
      .margin({ top: $r('app.float.margin_top') })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
    }
    .title(getResourceString($r('app.string.common_style_extract'), this))
  }
}
// [End use_modifier]