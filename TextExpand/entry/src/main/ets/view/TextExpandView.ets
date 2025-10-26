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
// [Start TextExpandView]
import { LastSpanAttribute, TextExpandModel, TextSectionAttribute } from '../utils/Models';
import { TextUtils } from '../utils/TextUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from  '@kit.BasicServicesKit'

@Component
export struct TextExpandView {
  //[StartExclude TextExpandView]
  // Text chapter attribute class
  @Prop @Watch('textSectionAttributeChange') textSectionAttribute: TextSectionAttribute;
  // Controls the text or image properties of text folding
  @Prop lastSpanAttribute: LastSpanAttribute;
  // Whether to expand or not
  @State expanded: boolean = true;
  // Text expansion properties
  @State textModifier: TextExpandModel = new TextExpandModel();
  uiContext = this.getUIContext()

  aboutToAppear(): void {
    this.getIsExpanded();
  }

  //[EndExclude TextExpandView]

  // [Start TextExpandView_textSectionAttributeChange]
  textSectionAttributeChange() {
    try {
      this.textModifier.title = this.uiContext
        .getHostContext()!.resourceManager.getStringSync($r('app.string.text_expand_long_title').id);
      this.lastSpanAttribute.content = [this.uiContext
        .getHostContext()!.resourceManager.getStringSync($r('app.string.text_expand_expand_title').id),
        this.uiContext
          .getHostContext()!.resourceManager.getStringSync($r('app.string.text_expand_collapse_title').id),
      ];
      this.getIsExpanded();
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
    }
  }

  // [End TextExpandView_textSectionAttributeChange]

  // [Start TextExpandView_getIsExpanded]
  getIsExpanded() {
    let titleSize: SizeOptions = this.uiContext.getMeasureUtils().measureTextSize({
      textContent: this.textSectionAttribute.title, //The text content is calculated
      lineHeight: this.textSectionAttribute.lineHeight,
      constraintWidth: this.textSectionAttribute.constraintWidth, //The text layout width is calculated
      fontSize: this.textSectionAttribute.fontSize //The text font size is calculated
    });
    let height = this.getUIContext().px2vp(Number(titleSize.height));
    if (height <= this.textSectionAttribute.lineHeight * 2) {
      this.textModifier.needProcess = false;
      this.textModifier.title = this.textSectionAttribute.title;
      return;
    } else {
      this.textModifier.needProcess = true;
    }
    if (this.expanded) {
      this.collapseText();
    } else {
      this.expandText();
    }
  }

  // [End TextExpandView_getIsExpanded]

  build() {
    Column({ space: 3 }) {
      //[StartExclude TextExpandView]
      Text() {
        Span(this.textModifier.title)
        if (this.textModifier.needProcess && !this.textModifier.exceedOneLine) {
          Span(this.lastSpanAttribute.content[0])
            .fontColor(this.lastSpanAttribute.color)
        } else if (this.textModifier.needProcess) {
          Span(this.lastSpanAttribute.content[1])
            .fontColor(this.lastSpanAttribute.color)
        }
      }
      .fontSize(this.lastSpanAttribute.size)
      .width(this.textSectionAttribute.constraintWidth)
      .lineHeight(this.textSectionAttribute.lineHeight)

      //[EndExclude TextExpandView]
    }
    .onClick(() => {
      if (!this.textModifier.needProcess) {
        return;
      }
      this.process();
    })
    .margin({
      left: $r('app.integer.text_expand_item_main_body_column_margin'),
      bottom: $r('app.integer.text_expand_item_main_body_column_margin'),
      right: $r('app.integer.text_expand_item_main_body_column_margin')
    })
  }

  // [Start TextExpandView_process]
  process(): void {
    if (this.expanded) {
      this.expandText();
      this.expanded = false;
      this.textModifier.exceedOneLine = true;
    } else {
      this.expanded = true;
      this.textModifier.exceedOneLine = false;
      this.collapseText();
    }
  }

  // [End TextExpandView_process]

  // [Start TextExpandView_expandText]
  // Expand text
  expandText(): void {
    if (this.textModifier.needProcess) {
      this.textModifier.title = this.textSectionAttribute.title;
    }
  }

  // [End TextExpandView_expandText]

  // [Start TextExpandView_collapseText]
  // Collapse text
  collapseText(): void {
    if (!this.textModifier.needProcess) {
      return;
    }
    this.textModifier.title =
      TextUtils.getShortText(
        this.textSectionAttribute,
        this.expanded ? `${this.lastSpanAttribute.content[0]}` : `${this.lastSpanAttribute.content[1]}`);
    // [End TextExpandView_collapseText]
  }
}

// [End TextExpandView]

