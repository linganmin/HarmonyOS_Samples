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

// [Start RichTextExpandView]
import {
  LastSpanAttribute,
  RichTextContentModel,
  RichTextExpandModel,
  RichTextModel,
  RichTextSectionAttribute
} from '../utils/Models';
import { TextUtils } from '../utils/TextUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from  '@kit.BasicServicesKit'

@Component
export struct RichTextExpandView {
  //[StartExclude RichTextExpandView]
  // Text chapter attribute class
  textSectionAttribute: RichTextSectionAttribute = new RichTextSectionAttribute();
  // Controls the text or image properties of text folding
  @Prop lastSpanAttribute: LastSpanAttribute;
  // Whether to expand or not
  @State expanded: boolean = true;
  // Text expansion properties
  @State textModifier: RichTextExpandModel = new RichTextExpandModel();
  @Prop @Watch('dataModelChange') dataModel: RichTextModel;

  aboutToAppear(): void {
    this.getIsExpanded()
  }
  //[EndExclude RichTextExpandView]

  // [Start RichTextExpandView_dataModelChange]
  dataModelChange() {
    try {
      this.lastSpanAttribute.content = [this.getUIContext()
        .getHostContext()!.resourceManager.getStringSync($r('app.string.text_expand_expand_title').id),
        this.getUIContext()
          .getHostContext()!.resourceManager.getStringSync($r('app.string.text_expand_collapse_title').id),
      ];
      this.getIsExpanded()
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
    }
  }
  // [End RichTextExpandView_dataModelChange]

  // [Start RichTextExpandView_getIsExpanded]
  getIsExpanded() {
    let paragraph = TextUtils.getParagraph(this.dataModel.textArray, this.dataModel.fontSize,
      this.textSectionAttribute.constraintWidth);
    this.textModifier.needProcess = paragraph.getLineCount() > this.textSectionAttribute.maxLines ? true : false;
    if (this.expanded) {
      this.collapseText();
    } else {
      this.expandText();
    }
  }
  // [End RichTextExpandView_getIsExpanded]

  build() {
    Column() {
      //[StartExclude RichTextExpandView]
      Column({ space: 3 }) {
        Text() {
          ForEach(this.textModifier.textContentArray, (item: RichTextContentModel) => {
            if (item.type === 'topic' || item.type === 'text') {
              Span(this.expanded && item.shortContent ? item.shortContent : item.content)
                .fontSize(item.fontSize)
                .fontColor(item.fontColor)
            } else if (item.type === 'images') {
              ForEach(item.images, (url: string) => {
                ImageSpan($r('app.media.' + url))
                  .objectFit(ImageFit.Fill)
                  .width(item.imgWidth)
                  .height(item.imgHeight)
              })
            } else if (item.type === 'link') {
              Span(this.expanded && item.shortContent ? item.shortContent : item.content)
                .fontSize(item.fontSize)
                .fontColor(item.fontColor)
                .onClick(() => {
                  // Hyperlink jumps need to be implemented according to your needs
                  this.getUIContext().getPromptAction().showToast({
                    message: $r('app.string.toast')
                  })
                })
            }
          })

          // [Start RichTextExpandView_isExpand]
          if (this.textModifier.needProcess && !this.textModifier.exceedOneLine) {
            Span(this.lastSpanAttribute.content[0])
              .fontColor(this.lastSpanAttribute.color)
          } else if (this.textModifier.exceedOneLine) {
            Span(this.lastSpanAttribute.content[1])
              .fontColor(this.lastSpanAttribute.color)
          }
          // [End RichTextExpandView_isExpand]
        }
        .width(this.textSectionAttribute.constraintWidth)
      }
      //[End RichTextExpandView]
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

  // [Start RichTextExpandView_process]
  // Click event
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
  // [End RichTextExpandView_process]

  // [Start RichTextExpandView_expandText]
  // Expand text
  expandText(): void {
    if (this.textModifier.needProcess) {
      this.textModifier.textContentArray = this.dataModel.textArray;
    }
  }
  // [End RichTextExpandView_expandText]

  // [Start RichTextExpandView_collapseText]
  // Collapse text
  collapseText(): void {
    if (!this.textModifier.needProcess) {
      return;
    }
    this.textModifier.textContentArray =
      TextUtils.getShortRichText(this.dataModel,
        this.textSectionAttribute,
        this.expanded ? this.lastSpanAttribute.content[0] : this.lastSpanAttribute.content[1]);
  }
  // [End RichTextExpandView_collapseText]
}
// [End RichTextExpandView]