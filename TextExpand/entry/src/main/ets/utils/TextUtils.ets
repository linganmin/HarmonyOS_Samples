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

// [Start TextUtils]
import { BusinessError } from '@kit.BasicServicesKit';
import { RichTextContentModel, RichTextModel, RichTextSectionAttribute, TextSectionAttribute } from './Models';
import { text } from '@kit.ArkGraphics2D';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const suffix: string = '... ';

export class TextUtils {
  /**
   * Gets the collapsed short paragraph string
   *
   * @param textSectionAttribute    Plain Text Attribute
   * @param lastSpan                Expand the collapse button text
   * @returns                       Short paragraph strings
   */
  // [Start TextUtils_getShortText]
  public static getShortText(textSectionAttribute: TextSectionAttribute, lastSpan: string): string {
    let text = TextUtils.getStringFromResource(textSectionAttribute.title);
    const minLinesTextSize: SizeOptions | undefined = uiContext?.getMeasureUtils().measureTextSize({
      textContent: text,
      fontSize: textSectionAttribute.fontSize,
      maxLines: textSectionAttribute.maxLines,
      wordBreak: WordBreak.BREAK_ALL,
      constraintWidth: textSectionAttribute.constraintWidth
    });
    const minHeight: Length | undefined = minLinesTextSize?.height;
    if (minHeight === undefined) {
      return '';
    }
    // Use the dichotomy to find strings that are exactly two lines in length
    let textStr: string[] = Array.from(text); //Split the string to avoid special characters and inconsistent sizes
    let leftCursor: number = 0;
    let rightCursor: number = textStr.length;
    let cursor: number = Math.floor(rightCursor / 2);
    let tempTitle: string = '';
    while (true) {
      tempTitle = text.substring(0, cursor) + suffix + lastSpan;
      const currentLinesTextSize: SizeOptions | undefined = uiContext?.getMeasureUtils().measureTextSize({
        textContent: tempTitle,
        fontSize: textSectionAttribute.fontSize,
        wordBreak: WordBreak.BREAK_ALL,
        constraintWidth: textSectionAttribute.constraintWidth
      });
      const currentLineHeight: Length | undefined = currentLinesTextSize?.height;
      if (currentLineHeight === undefined) {
        return '';
      }
      if (currentLineHeight > minHeight) {
        // The current character has exceeded two lines, continue to look to the left
        rightCursor = cursor;
        cursor = leftCursor + Math.floor((cursor - leftCursor) / 2);
      } else {
        // The current character is less than two lines, it may be OK, but you still need to look to the right
        leftCursor = cursor;
        cursor += Math.floor((rightCursor - cursor) / 2);
      }
      if (Math.abs(rightCursor - leftCursor) <= 1) {
        // The two pointers basically coincide, which means that they have been found
        break;
      }
    }
    return text.substring(0, cursor) + suffix;
  }

  // [End TextUtils_getShortText]

  // [Start TextUtils_getStringFromResource]
  public static getStringFromResource(source: Resource | string): string {
    try {
      if (typeof source === 'string') {
        return source;
      }
      if (uiContext?.getHostContext()) {
        return uiContext?.getHostContext()!.resourceManager.getStringSync(source.id);
      }
      return '';
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      console.log('getStringFromResource' + code + message);
      return '';
    }
  }

  // [End TextUtils_getStringFromResource]

  /**
   * Set up paragraph layout
   * @param contentArray  Typography content
   * @param fontSize
   * @param textWidth
   */
  public static getParagraph(contentArray: RichTextContentModel[], fontSize: number,
    textMaxWidth: number): text.Paragraph {
    // Set up paragraph layout
    // [Start TextUtils_paragraphBuilder]
    let myTextStyle: text.TextStyle = {
      fontSize: uiContext?.fp2px(fontSize)
    };

    let myParagraphStyle: text.ParagraphStyle = {
      textStyle: myTextStyle,
      align: text.TextAlign.START,
      maxLines: 300, // Just specify a large enough number of rows
      breakStrategy: text.BreakStrategy.GREEDY,
      wordBreak: text.WordBreak.BREAK_WORD
    };

    let fontCollection = new text.FontCollection();
    let paragraphGraphBuilder = new text.ParagraphBuilder(myParagraphStyle, fontCollection);
    // [End TextUtils_paragraphBuilder]
    contentArray.forEach((item, index) => {
      if (item.type === 'topic') {
        // The text specifies the style
        paragraphGraphBuilder.pushStyle({
          fontSize: fontSize,
        });
        paragraphGraphBuilder.addText(item.content);
      } else if (item.type === 'images') {
        item.images.forEach(() => {
          // Add a placeholder to specify the style
          // [Start TextUtils_addPlaceholder]
          paragraphGraphBuilder.addPlaceholder({
            width: item.imgWidth,
            height: item.imgHeight,
            align: text.PlaceholderAlignment.BOTTOM_OF_ROW_BOX,
            baseline: text.TextBaseline.IDEOGRAPHIC,
            baselineOffset: 0
          });
          // [End TextUtils_addPlaceholder]
        });

      } else if (item.type === 'link') {
        // [Start TextUtils_addText]
        paragraphGraphBuilder.pushStyle({
          fontSize: fontSize,
        });
        paragraphGraphBuilder.addText(item.content);
        // [End TextUtils_addText]
      } else {
        paragraphGraphBuilder.pushStyle({
          fontSize: fontSize,
        });
        paragraphGraphBuilder.addText(item.content);
      }
    })
    // [Start TextUtils_getParagraph_build]
    let paragraph = paragraphGraphBuilder.build();
    paragraph.layoutSync(textMaxWidth);
    // [End TextUtils_getParagraph_build]
    return paragraph;
  }

  // [End TextUtils_getParagraph]

  // [Start TextUtils_getShortRichText]
  /**
   * Get the collapsed dash word data
   *
   * @param dataModel             Content Model
   * @param textSectionAttribute  Rich Text Attribute
   * @param lastSpan              Expand the collapse button text
   * @returns                     Short paragraph strings
   */

  public static getShortRichText(dataModel: RichTextModel, textSectionAttribute: RichTextSectionAttribute,
    lastSpan: string): RichTextContentModel[] {
    let paragraph =
      TextUtils.getParagraph(dataModel.textArray, dataModel.fontSize, textSectionAttribute.constraintWidth);
    const minLinesTextSize: SizeOptions | undefined = uiContext?.getMeasureUtils().measureTextSize({
      textContent: suffix + lastSpan,
      fontSize: dataModel.fontSize,
    });
    const widthMore = uiContext?.px2vp(Number(minLinesTextSize?.width));
    // Calculates the coordinates of the last text before three points
    let x: number = 0;
    let y: number = 0;
    // [Start TextUtils_getShortRichText_y]
    for (let i = 0; i < textSectionAttribute.maxLines; i++) {
      y += i === textSectionAttribute.maxLines - 1 ? paragraph.getLineHeight(i) / 2 : paragraph.getLineHeight(i);
    }
    // [End TextUtils_getShortRichText_y]

    // [Start TextUtils_getShortRichText_x]
    if (paragraph.getLineWidth(textSectionAttribute.maxLines - 1) + Number(widthMore) >
    textSectionAttribute.constraintWidth) {
      x = textSectionAttribute.constraintWidth - Number(widthMore);
    } else {
      x = paragraph.getLineWidth(textSectionAttribute.maxLines - 1)
    }
    // [End TextUtils_getShortRichText_x]

    // [Start TextUtils_getShortRichText_Index]
    // The conversion coordinates correspond to the index
    let positionWithAffinity = paragraph.getGlyphPositionAtCoordinate(x, y);
    let index = 0;
    if (positionWithAffinity.affinity === text.Affinity.UPSTREAM) {
      index = positionWithAffinity.position;
    } else {
      index = positionWithAffinity.position + 1;
    }
    // [Start TextUtils_getShortRichText_Index]
    // The position of the last character
    let lastIndex = index - 1;
    let shortContentArray: RichTextContentModel[] = [];
    for (let i = 0; i < dataModel.textArray.length; i++) {
      let model = dataModel.textArray[i];
      // Determine which text message is in the truncated position, process it, and sort out the display content
      if (0 <= lastIndex - model.index && lastIndex - model.index <= model.length) {
        model.shortContent = model.content.substring(0, lastIndex - model.index) + suffix;
        let b = lastIndex - model.index;
        let a = model.content.substring(0, lastIndex - model.index);
        shortContentArray.push(model);
        return shortContentArray;
      } else {
        shortContentArray.push(model);
      }
    }
    return [];
  }
}

// [End TextUtils]