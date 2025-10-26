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

// [Start RichTextModel]
export class RichTextModel {
  // All the text
  text: string = '';
  // Array of information
  textArray: RichTextContentModel[] = [];
  // fontSize
  fontSize: number = 16;
}

export class RichTextContentModel {
  // The index value of a single piece of information throughout the text
  index: number = 0;
  // The length of a single text (the agreed length in the case of an image)
  length: number = 0;
  // The type of text
  type: string = '';
  // images
  images: string[] = [];
  // content
  content: string = '';
  // Hyperlinks
  link: string = '';
  // fontColor
  fontColor: string = '#000';
  // fontSize
  fontSize: number = 16;
  // Image width
  imgWidth: number = 16;
  // Image height
  imgHeight: number = 16;
  // If the number of lines exceeds the limit, the entire message will be intercepted, and the content to be displayed will be intercepted
  shortContent: string = '';
}
// [End RichTextModel]

// [Start TextExpand_TabData]
export class TabData {
  id: number;
  name: string | Resource;
  ItemList: ItemData[] = [
    new ItemData(),
    new ItemData(),
    new ItemData()
  ];

  constructor(id: number, name: string | Resource) {
    this.id = id;
    this.name = name
  }
}

export class ItemData {
  profileImg: Resource = $r('app.media.head_0');
  profileImg1: Resource = $r('app.media.head_1');
  rawTitle: Resource | string = $r('app.string.text_expand_long_title')
  imgUrlList: Resource[] | string[] = [
    $r('app.media.text_expand_img2'),
    $r('app.media.text_expand_img3'),
    $r('app.media.text_expand_img4')
  ];
  imgUrl: Resource | string = $r('app.media.text_expand_img2')
  iconUrlList: Resource[] | string[] = [
    $r('app.media.ic_pl_light'),
    $r('app.media.ic_sc_light'),
    $r('app.media.ic_dz_light'),
    $r('app.media.ic_fx_light')
  ]
}
// [End TextExpand_TabData]

// [Start RichTextExpandModel]
/**
 * Rich text expands the view model
 * @param {RichTextContentModel[]} textContentArray - Textual content
 * @param {boolean} needProcess - Whether to display the Expand and collapse button
 * @param {exceedOneLine} boolean - When adding the word 'collapse', more than one line needs to be wrapped
 */
export class RichTextExpandModel {
  textContentArray: RichTextContentModel[] = [];
  needProcess: boolean = true;
  exceedOneLine: boolean = false;
}

// [End RichTextExpandModel]

// [Start RichTextSectionAttribute]
/**
 * Rich Text Attribute
 *
 * @param {ResourceStr} title - Textual content
 * @param {number} {maxLines} - maxLines
 * @param {ResourceStr} {fontColor} - fontColor
 * @param { Resource | number | string} {fontSize} - fontSize
 * @param { number } {imgWidth} - Image width
 * @param { number } {lineHeight} - Image height
 * @param {number} lineHeight - lineHeight
 * @param {Resource | number | string} contraintWidth - Sets the maximum width of the text on the line
 */

export class RichTextSectionAttribute {
  title: ResourceStr = '';
  maxLines: number;
  fontColor: ResourceStr;
  fontSize: number;
  imgWidth: number;
  imgHeight: number;
  lineHeight: number;
  constraintWidth: number;

  constructor(title: ResourceStr = '', maxLines: number = 3, fontColor: ResourceStr = '#000',
    fontSize: number = 16, imgWidth: number = 0, imgHeight: number = 0, lineHeight: number = 16,
    constraintWidth: number = 350) {
    this.title = title;
    this.maxLines = maxLines;
    this.fontColor = fontColor;
    this.fontSize = fontSize;
    this.imgWidth = imgWidth;
    this.imgHeight = imgHeight;
    this.lineHeight = lineHeight;
    this.constraintWidth = constraintWidth;
  }
}

// [End RichTextSectionAttribute]

// [Start LastSpanAttribute]
/**
 * Text that controls text folding
 *
 * @param {number} lastSpanType - Type (0 for text)
 * @param {number} charactersNumber - The number of characters in the collapsed text or image
 * @param {ResourceStr[]} -Text or image content
 * @param {size} Text or image size
 * @param {color} color
 */
export class LastSpanAttribute {
  lastSpanType: number;
  charactersNumber: number;
  content: string[];
  size: ResourceStr | number;
  color: ResourceStr | Color;

  constructor(lastSpanType: number, charactersNumber: number = 1,
    content: string[], size: ResourceStr | number, color: ResourceStr | Color = Color.Orange) {
    this.lastSpanType = lastSpanType;
    this.charactersNumber = charactersNumber;
    this.content = content;
    this.size = size;
    this.color = color;
  }
}

// [End LastSpanAttribute]

// [Start TextExpandModel]
/**
 * Plain text expands the view model
 * @param {ResourceStr} title - Textual content
 * @param {boolean} needProcess - Whether to display the Expand and collapse button
 * @param {exceedOneLine} boolean - When adding the word 'collapse', more than one line needs to be wrapped
 */
export class TextExpandModel {
  title: ResourceStr = '';
  needProcess: boolean = true;
  exceedOneLine: boolean = false;
}

// [End TextExpandModel]

// [Start TextSectionAttribute]
/**
 * Plain Text Attribute
 *
 * @param {ResourceStr} title - Textual content
 * @param {number} {maxLines} - maxLines
 * @param {ResourceStr} {fontColor} - fontColor
 * @param { Resource | number | string} {fontSize} - fontSize
 * @param {number} lineHeight - lineHeight
 * @param {Resource | number | string} contraintWidth - Sets the maximum width of the text on the line
 */

export class TextSectionAttribute {
  title: ResourceStr = '';
  maxLines: number;
  fontColor: ResourceStr;
  fontSize: Resource | number | string;
  lineHeight: number;
  constraintWidth: Resource | number | string;

  constructor(title: ResourceStr = '', maxLines: number = 2, fontColor: ResourceStr = '#000',
    fontSize: Resource | number | string = '16vp', lineHeight: number = 16,
    constraintWidth: Resource | number | string = 350) {
    this.title = title;
    this.maxLines = maxLines;
    this.fontColor = fontColor;
    this.fontSize = fontSize;
    this.lineHeight = lineHeight;
    this.constraintWidth = constraintWidth;
  }
}

// [End TextSectionAttribute]
