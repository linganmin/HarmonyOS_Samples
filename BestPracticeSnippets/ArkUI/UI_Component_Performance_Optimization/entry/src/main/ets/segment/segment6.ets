/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
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

@Observed
class User {
  avatarImage: ResourceStr;
  name: string;

  constructor(name: string, avatarImage: ResourceStr) {
    this.name = name;
    this.avatarImage = avatarImage;
  }
}

// [Start Case4]
// 1.Custom Attribute Modifier, this class implements the AttributeModifier interface
class RowModifier implements AttributeModifier<RowAttribute> {
  private customImage: ResourceStr = '';
  private static instance: RowModifier;

  constructor() {
  }

  setCustomImage(customImage: ResourceStr) {
    this.customImage = customImage;
    return this;
  }

  // Adopting a singleton pattern avoids creating a new modifier for each component, increasing the performance overhead incurred by creating the
  public static getInstance(): RowModifier {
    if (!RowModifier.instance) {
      RowModifier.instance = new RowModifier();
    }
    return RowModifier.instance;
  }

  // 2.Implement the applyNormalAttribute method of the AttributeModifier interface to customize the logic of attribute setting.
  applyNormalAttribute(instance: RowAttribute) {
    if (this.customImage) {
      instance.backgroundImage(this.customImage);
      instance.backgroundImageSize(ImageSize.Cover);
    } else {
      instance.backgroundColor(Color.Blue);
      instance.justifyContent(FlexAlign.Center);
      // instance.padding(2)
      // instance.margin(2)
      // instance.opacity(1)
      // instance.clip(false)
      // instance.layoutWeight(1)
      // instance.backgroundBlurStyle(BlurStyle.NONE)
      // instance.alignItems(VerticalAlign.Center)
      // instance.borderWidth(1)
      // instance.borderColor(Color.Pink)
      // instance.borderStyle(BorderStyle.Solid)
      // instance.expandSafeArea([SafeAreaType.SYSTEM])
      // instance.rotate({ angle: 5 })
      // instance.responseRegion({x: 0})
      //instance.mouseResponseRegion({x: 0})
      // instance.constraintSize({minWidth: 25})
      // instance.hitTestBehavior(HitTestMode.Default)
      //instance.backgroundImagePosition(Alignment.Center)
      //instance.foregroundBlurStyle(BlurStyle.NONE)
    }
    instance.size({ width: 50, height: 50 });
    instance.borderRadius(25);
  }
}


@Component
struct Avatar {
  @ObjectLink user: User;

  build() {
    Row() {
      if (!this.user.avatarImage) {
        Text(this.user.name.charAt(0))
          .fontSize(28)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
    }
    // 3.Pass a custom RowModifier class as a parameter to enable on-demand property registration
    .attributeModifier(RowModifier.getInstance().setCustomImage(this.user.avatarImage))
  }
}

// [End Case4]

