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
* FAQ:如何实现跨文件样式复用
*/

// [Start implement_cross_file_style_reuse_one]
/*
  Customize class to implement AttributeModifier interface for Text
*/
export class CommodityText implements AttributeModifier<TextAttribute> {
  textType: TextType = TextType.TYPE_ONE;
  textSize: number = 15;

  constructor( textType: TextType, textSize: number) {
    this.textType = textType;
    this.textSize = textSize;
  }

  applyNormalAttribute(instance: TextAttribute): void {
    if (typeof this.textSize !== 'number' || this.textSize <= 0) {
      throw new Error('Invalid textSize')
    }

    if (this.textType === TextType.TYPE_ONE) {
      instance.fontSize(this.textSize);
      instance.fontColor(Color.Orange);
      instance.fontWeight(FontWeight.Bolder);
      instance.width(200);
    } else if (this.textType === TextType.TYPE_TWO) {
      instance.fontSize(this.textSize);
      instance.fontWeight(FontWeight.Bold);
      instance.fontColor(Color.Blue);
      instance.width(200);
    } else if (this.textType === TextType.TYPE_THREE) {
      instance.fontColor(Color.Gray);
      instance.fontSize(this.textSize);
      instance.fontWeight(FontWeight.Normal);
      instance.width(200);
    } else if (this.textType === TextType.TYPE_FOUR) {
      instance.fontSize(this.textSize);
      instance.fontColor(Color.Orange);
      instance.textAlign(TextAlign.Center);
      instance.border({ width: 1, color: Color.Orange, style: BorderStyle.Solid });
      instance.margin({ right: 10 });
    } else {
     console.log(`TYPE is ${this.textType}`);
    }
  }
}
/*
 *  Enumerate text types
 */
export enum TextType {
  TYPE_ONE,
  TYPE_TWO,
  TYPE_THREE,
  TYPE_FOUR
}
// [End implement_cross_file_style_reuse_one]