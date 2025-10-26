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

import { CommonConstants } from '../constants/CommonConstants';
import { ContactInfo, GraphicTitle, TopicInfo } from '../models/CommonModel';
import { getResourceString } from '../utils/CommonUtil';

// [Start TextSpan]
interface TextSpan {
  value: string;
  spanRange: [number, number];
  type: string;
  data: ESObject;
}
// [End TextSpan]

// [Start CustomSpan]
export interface CustomSpan {
  value?: string;
  resourceValue?: ResourceStr;
  type?: string;
  data?: ESObject;
}
// [End CustomSpan]

@Component
export struct EditorView {
  private context: Context = this.getUIContext().getHostContext()!;
  @StorageProp('contactInfo') @Watch('contactInfoChange') contactInfo?: ContactInfo = undefined;
  @Consume @Watch('titleInfoChange') titleInfo: GraphicTitle;
  @Consume @Watch('topicInfoChange') topicInfo: TopicInfo;
  private richEditorController: RichEditorController = new RichEditorController();
  /**
   * Flag indicating if the @-contact or #-topic panel was triggered by keyboard input.
   * When true, the keyboard-typed character (@ or #) should be removed after
   * a contact or topic is added. This cleanup is unnecessary for panel openings
   * triggered by button clicks.
   */
  // [Start isKeyboardTriggered]
  @State isKeyboardTriggered: boolean = false;
  // [StartExclude isKeyboardTriggered]
  @Link isTopicViewVisible: boolean;
  // [Start textSpans]
  private textSpans: TextSpan[] = [];
  // [StartExclude textSpans]
  // [Start isEmojiKeyboard]
  @Link isEmojiKeyboard: boolean;
  // [StartExclude isEmojiKeyboard]
  onReady: (getData: () => CustomSpan[]) => void = () => {};

  aboutToAppear(): void {
    this.onReady(() => {
      return this.getData()
    });
  }

  // [EndExclude textSpans]
  // Update the textSpans range that come after the current offset
  updateTextSpans(insertOffset: number, insertLength: number) {
    this.textSpans.forEach(textSpan => {
      if (textSpan.spanRange[0] >= insertOffset) {
        textSpan.spanRange[0] += insertLength;
        textSpan.spanRange[1] += insertLength;
      }
    })
  }
  // [End textSpans]

  getEmojiIcons(): Resource[] {
    const getRandomNum = () => Math.floor(Math.random() * 2) + 3;
    return Array(40).fill(1).map(() => $r(`app.media.emoji_${getRandomNum()}`));
  }

  // [EndExclude isKeyboardTriggered]
  deletePrevChar() {
    const controller = this.richEditorController;
    const offset = controller.getCaretOffset();
    const range: RichEditorRange = { start: offset - 1, end: offset };
    controller.deleteSpans(range);
  }
  // [StartExclude isKeyboardTriggered]

  // [Start addImageSpan]
  addImageSpan(value: ResourceStr) {
    const controller = this.richEditorController;
    const curOffset = controller.getCaretOffset();
    controller.addImageSpan(value, {
      offset: curOffset,
      imageStyle: {
        size: [16, 16]
      }
    });
    // Update the textSpans spanRange that come after the current offset
    this.updateTextSpans(curOffset, 1);
  }
  // [End addImageSpan]

  // [EndExclude isKeyboardTriggered]
  // [Start addTextSpan]
  // [Start addCustomTextSpan]
  addTextSpan(value: string, type: string, data: ESObject, style: RichEditorTextStyle) {
    // [StartExclude addTextSpan]
    // [StartExclude addCustomTextSpan]
    if (this.isKeyboardTriggered) {
      this.deletePrevChar()
      this.isKeyboardTriggered = false;
    }
    // [StartExclude isKeyboardTriggered]
    // [EndExclude addTextSpan]
    const controller = this.richEditorController;
    const curOffset = controller.getCaretOffset();
    controller.addTextSpan(value, {
      offset: curOffset,
      style
    });
    const splitChar = ' ';
    controller.addTextSpan(splitChar, {
      offset: controller.getCaretOffset()
    });
    // [EndExclude addCustomTextSpan]
    // [StartExclude addTextSpan]
    this.updateTextSpans(curOffset, value.length + splitChar.length);
    this.textSpans.push({
      value,
      type,
      data,
      spanRange: [curOffset, curOffset + value.length],
    })
    // [EndExclude isKeyboardTriggered]
    // [EndExclude addTextSpan]
  }
  // [End addTextSpan]
  // [End addCustomTextSpan]
  // [StartExclude isKeyboardTriggered]

  contactInfoChange() {
    const value = `@${getResourceString(this.contactInfo!.name, this.context)}`;
    this.addTextSpan(value, 'contact', this.contactInfo, {
      fontColor: '#5291FF'
    });
  }

  titleInfoChange(): void {
    const value = `${this.titleInfo.titlePicUrl}${getResourceString(this.titleInfo.title, this.context)}`;
    this.addTextSpan(value, 'graphicTitle', this.titleInfo, {
      fontWeight: FontWeight.Bolder
    });
  }

  topicInfoChange(): void {
    const value = `#${getResourceString(this.topicInfo.title, this.context)}#`;
    this.addTextSpan(value, 'topic', this.topicInfo, {
      fontColor: '#5291FF'
    });
  }

  // [EndExclude isKeyboardTriggered]
  aboutToIMEInput: (value: RichEditorInsertValue) => boolean = value => {
    if (value.insertValue === '@') {
      this.isKeyboardTriggered = true;
      this.getUIContext().getRouter().pushUrl({ url: 'pages/ContactListPage' });
      // [StartExclude isKeyboardTriggered]
    } else if (value.insertValue === '#') {
      this.isKeyboardTriggered = true;
      this.isTopicViewVisible = true;
      // [EndExclude isKeyboardTriggered]
    }
    return true;
  }
  // [End isKeyboardTriggered]

  onDidIMEInput: (range: TextRange) => void = range => {
    this.updateTextSpans(range.start!, range.end! - range.start!);
  }

  // [Start aboutToDelete]
  aboutToDelete: (value: RichEditorDeleteValue) => boolean = deleteValue => {
    const start = deleteValue.offset;
    const end = start + deleteValue.length;
    const snapStart = this.snapCaretToTextSpanBoundary(start, 'start');
    const snapEnd = this.snapCaretToTextSpanBoundary(end, 'end');
    this.richEditorController.deleteSpans({
      start: snapStart,
      end: snapEnd
    });
    // delete all textSpans in selection
    this.textSpans = this.textSpans.filter(ts => {
      const isInRange = ts.spanRange[0] >= snapStart && ts.spanRange[1] <= snapEnd
      return !isInRange;
    });
    this.updateTextSpans(snapStart, snapStart - snapEnd);
    return false;
  }
  // [End aboutToDelete]

  // [Start onSelect]
  onSelect: (selection: RichEditorSelection) => void = richEditorSelection => {
    const caretStart = richEditorSelection.selection[0];
    const caretEnd = richEditorSelection.selection[1];
    // Determine if the selected content lies within a single textSpan.
    // If it does, adjust the selection range to the start and end of that textSpan.
    const textSpan = this.textSpans.find(textSpan => {
      return caretStart >= textSpan.spanRange[0] && caretEnd <= textSpan.spanRange[1];
    });
    if (textSpan) {
      this.richEditorController.setSelection(textSpan.spanRange[0], textSpan.spanRange[1]);
      return;
    }
    // Both values being -1 indicates clear selection operation.
    if (caretStart === -1 && caretEnd ===  -1) {
      return
    }
    const selectionStart = this.snapCaretToTextSpanBoundary(caretStart);
    const selectionEnd = this.snapCaretToTextSpanBoundary(caretEnd);
    this.richEditorController.setSelection(selectionStart, selectionEnd);
  }
  // [End onSelect]

  // [Start onSelectionChange]
  onSelectionChange: (range: RichEditorRange) => void = range => {
    // When start and end values are the same, it indicates a cursor position change triggered by a click, with no selected area.
    if (range.start === range.end) {
      const targetCaretOffset = this.snapCaretToTextSpanBoundary(range.start!);
      this.richEditorController.setCaretOffset(targetCaretOffset);
    }
  }
  // [End onSelectionChange]

  /**
   * adjusts the caret position to either the start or end boundary of that text span,
   * based on the specified type or the nearest boundary principle.
   *
   * @param {number} caretOffset - Current offset position of the caret
   * @param {'start' | 'end'} [type] - Optional parameter specifying whether to snap to
   *                                   the start('start') or end('end') of the text span
   * @returns {number} Adjusted caret offset, or original offset if no corresponding text span is found
   */
  // [Start snapCaretToTextSpanBoundary]
  snapCaretToTextSpanBoundary(caretOffset: number, type?: 'start' | 'end') {
    const textSpan = this.textSpans.find(textSpan => {
      return caretOffset > textSpan.spanRange[0] && caretOffset < textSpan.spanRange[1];
    });
    if (!textSpan) return caretOffset;
    if (type === 'start') return textSpan.spanRange[0];
    if (type === 'end') return textSpan.spanRange[1];
    const disToStart = caretOffset - textSpan.spanRange[0];
    const disToEnd = textSpan.spanRange[1] - caretOffset;
    if (disToStart <= disToEnd) return textSpan.spanRange[0];
    return textSpan.spanRange[1];
  }
  // [End snapCaretToTextSpanBoundary]

  isTheSameRange(range1: [number, number], range2: [number, number]): boolean {
    return range1[0] === range2[0] && range1[1] === range2[1];
  }

  // [Start getData]
  getData(): CustomSpan[] {
    const customSpans = this.richEditorController.getSpans().map(span => {
      const textSpan = span as RichEditorTextSpanResult;
      const imageSpan = span as RichEditorImageSpanResult;
      // is imageSpan
      if (!textSpan.value) {
        return { resourceValue: imageSpan.valueResourceStr } as CustomSpan;
      }
      // is textSpan
      const customTextSpan = this.textSpans.find(customTextSpan => {
        return this.isTheSameRange(customTextSpan.spanRange, textSpan.spanPosition.spanRange);
      })
      if (!customTextSpan) {
        return { value: textSpan.value } as CustomSpan;
      }
      return {
        value: customTextSpan.value,
        type: customTextSpan.type,
        data: customTextSpan.data
      } as CustomSpan;
    });
    return customSpans;
  }
  // [End getData]

  @Builder
  EmojiKeyboard() {
    Grid() {
      ForEach(this.getEmojiIcons(), (icon: Resource) => {
        GridItem() {
          Image(icon)
            .width(40)
            .onClick(() => {
              this.addImageSpan(icon);
            })
        }
      })
    }
    .width('100%')
    .height(280)
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
    .rowsGap(15)
    .padding(10)
    .scrollBar(BarState.Off)
  }

  // [EndExclude isEmojiKeyboard]
  build() {
    // [Start RichEditor]
    RichEditor({
      controller: this.richEditorController
    })
      // [StartExclude RichEditor]
      .customKeyboard(this.isEmojiKeyboard ? this.EmojiKeyboard() : undefined, {
        supportAvoidance: true
      })
      // [StartExclude isEmojiKeyboard]
      .id(CommonConstants.RICH_EDITOR_ID)
      .width('100%')
      .constraintSize({
        minHeight: 100
      })
      .margin({
        bottom: 10
      })
      .placeholder($r('app.string.richEditor_placeholder'), { fontColor: '#666666' })
      // [EndExclude RichEditor]
      .onReady(() => {
        this.richEditorController.setTypingStyle({
          fontColor: Color.Black,
        })
      })
      // [End RichEditor]
      .onDidIMEInput(this.onDidIMEInput)
      .aboutToIMEInput(this.aboutToIMEInput)
      .aboutToDelete(this.aboutToDelete)
      .onSelectionChange(this.onSelectionChange)
      .onSelect(this.onSelect)
      .onClick(() => {
        this.isEmojiKeyboard = false;
      })
      // [EndExclude isEmojiKeyboard]
  }
  // [End isEmojiKeyboard]
}