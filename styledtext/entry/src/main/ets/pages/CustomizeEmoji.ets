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

import { EmojiMock, EMOJI_DATA } from "../mock/MockData";
import { MyCustomSpan } from "../model/MyCustomSpan";
import { HandleData } from "../common/HandleData";

@Component
export struct CustomizeEmoji {
  private controller: TextController = new TextController();
  // Text content font size
  defaultFontSize: string | number | Resource = $r('app.string.styled_text_font_size_default');
  // Text content font color
  defaultFontColor: ResourceColor = Color.Black;
  private styledStrings: MutableStyledString[] = [];
  // Custom span list data
  spans: MyCustomSpan[] = [];

  /*
   * handle Emoji
   */
  // [Start handle_emoji]
  handleEmoji(span: MyCustomSpan) {
    this.styledStrings.push(new MutableStyledString(new ImageAttachment({
      resourceValue: EMOJI_DATA.get(span.content),
      size: {
        width: 16,
        height: 16
      }
    })));
  }

  // [End handle_emoji]

  /*
   * Process the text into the final display attribute string
   */
  // [Start handle_styled_string]
  handleStyledString() {
    this.spans = EmojiMock;
    this.spans.forEach((span) => {
      this.handleEmoji(span);
    });

    this.controller = HandleData.handleStyledString(this.styledStrings);
  }

  // [End handle_styled_string]

  @Builder
  navTitleBuilder() {
    Row() {
      Text($r("app.string.customize_emoji"))
        .fontSize($r("app.integer.subtitle_font_size"))
        .fontWeight(FontWeight.Bold)
        .margin({ left: 10 })
    }
    .height('100%')
    .width('85%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  aboutToAppear(): void {
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