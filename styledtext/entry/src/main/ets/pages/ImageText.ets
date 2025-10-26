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

import { i18n } from '@kit.LocalizationKit';
import { MyCustomSpan } from "../model/MyCustomSpan";
import { ImageTextMock, ImageTextMock_EN } from "../mock/MockData";
import { HandleData } from "../common/HandleData";
import { MyDrawCustomSpan } from "../components/MyDrawCustomSpan";

let gUIContext: UIContext | undefined = undefined;

@Component
export struct ImageText {
  private systemLanguage: string = 'zh-Hans';
  private controller: TextController = new TextController();
  // Text content font size
  defaultFontSize: string | number | Resource = $r('app.string.styled_text_font_size_default');
  // Text content font color
  defaultFontColor: ResourceColor = Color.Black;
  private styledStrings: MutableStyledString[] = [];
  // Custom span list data
  spans: MyCustomSpan[] = [];

  /*
   * handle ImageText
   */
  // [Start handle_image_text]
  handleImageText(span: MyCustomSpan) {
    let resourceStr = $r('app.media.doc_plaintext_green');
    // [StartExclude handle_image_text]
    if (span.url === "red") {
      resourceStr = $r('app.media.doc_plaintext_red');
    }
    // [EndExclude handle_image_text]

    this.styledStrings.push(new MutableStyledString(new ImageAttachment({
      resourceValue: resourceStr,
      size: {
        width: 13,
        height: 13
      },
      layoutStyle: {
        margin: { top: 4 }
      },
      verticalAlign: ImageSpanAlignment.CENTER
    })));
    // Calculate the required width based on language
    let width = 15 + 40 * span.content.length;
    if (this.systemLanguage !== 'zh-Hans') {
      width = 25 + 21 * span.content.length;
    }
    this.styledStrings.push(new MutableStyledString(new MyDrawCustomSpan(span.content, width, 20,this.systemLanguage,
      span.url, gUIContext)));
  }

  // [End handle_image_text]

  /*
   * Process the text into the final display attribute string
   */
  // [Start handle_styled_string]
  handleStyledString() {
    if (this.systemLanguage === 'zh-Hans') {
      this.spans = ImageTextMock;
    } else {
      this.spans = ImageTextMock_EN;
    }
    this.spans.forEach((span) => {
      if (span.url) {
        this.handleImageText(span);
      } else {
        this.styledStrings.push(new MutableStyledString(span.content, []));
      }
    });

    this.controller = HandleData.handleStyledString(this.styledStrings);
  }

  // [End handle_styled_string]

  @Builder
  navTitleBuilder() {
    Row() {
      Text($r("app.string.image_text"))
        .fontSize($r("app.integer.subtitle_font_size"))
        .fontWeight(FontWeight.Bold)
        .margin({ left: 10 })
    }
    .height('100%')
    .width('85%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  aboutToAppear(): void {
    this.systemLanguage = i18n.System.getSystemLanguage();
    gUIContext = this.getUIContext();
    // Process text
    this.handleStyledString();
  }

  // [Start set_text_style]
  aboutToReuse(): void {
    this.handleStyledString();
  }

  // [End set_text_style]

  build() {
    NavDestination() {
      Row() {
        Row() {
          Text(undefined, { controller: this.controller })
            .fontColor(this.defaultFontColor)
            .fontSize(this.defaultFontSize)
            .fontWeight(400)
            .fontFamily("HarmonyHeiTi")
            .width(328)
            .margin(16)
            .padding(16)
            .letterSpacing(0.1)
            .borderRadius(10)
            .backgroundColor('#ffff')
            .textAlign(TextAlign.JUSTIFY)
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .height("100%")
      .alignItems(VerticalAlign.Top)
      .backgroundColor($r('app.color.text_background_color'))
    }
    .title(this.navTitleBuilder())
  }
}