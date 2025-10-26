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

import { LengthMetrics } from "@kit.ArkUI";
import { i18n } from '@kit.LocalizationKit';
import { VideoLinkMock, VideoLinkMock_EN } from "../mock/MockData";
import { MyCustomSpan } from "../model/MyCustomSpan";
import { HandleData } from "../common/HandleData";

@Component
export struct VideoLink {
  private systemLanguage: string = 'zh-Hans';
  private controller: TextController = new TextController();
  // Text content font size
  defaultFontSize: string | number | Resource = $r('app.string.styled_text_font_size_default');
  // Text content font color
  defaultFontColor: ResourceColor = Color.Black;
  private styledStrings: MutableStyledString[] = [];
  // Custom span list data
  spans: MyCustomSpan[] = [];
  // [Start text_style]
  textAttribute: TextStyle = new TextStyle({
    fontColor: $r('app.color.styled_text_link_font_color'),
    fontSize: LengthMetrics.fp(14)
  });

  // [End text_style]
  /*
   * handle VideoLink
   */
  // [Start handle_video_link]
  handleVideoLink(span: MyCustomSpan) {
    // If the pixelMap for the video link icon exists, add an image attachment styled string before the corresponding link
    this.styledStrings.push(new MutableStyledString(new ImageAttachment({
      resourceValue: $r('app.media.play_round_rectangle'),
      size: {
        width: $r('app.integer.styled_text_video_link_icon_size'),
        height: $r('app.integer.styled_text_video_link_icon_size')
      },
      verticalAlign: ImageSpanAlignment.CENTER,
      objectFit: ImageFit.Contain
    })));
    this.styledStrings.push(new MutableStyledString(span.content, [{
      start: 0,
      length: span.content.length,
      styledKey: StyledStringKey.GESTURE,
      styledValue: this.generateClickStyle(span)
    }, {
      start: 0,
      length: span.content.length,
      styledKey: StyledStringKey.FONT,
      styledValue: this.textAttribute
    }
    ]));
  }

  // [End handle_video_link]

  /*
   * Generate click gesture style
   * @param {MyCustomSpan} span - Custom text span containing the text type and content
   * @returns {GestureStyle} - Gesture style object containing click event handling
   */
  // [Start generate_click_style]
  generateClickStyle(span: MyCustomSpan): GestureStyle {
    return new GestureStyle({
      onClick: () => {
        this.linkClickCallback(span);
      }
    })
  }

  // [End generate_click_style]

  /*
   * Process the text into the final display attribute string
   */
  // [Start handle_styled_string]
  handleStyledString() {
    if (this.systemLanguage === 'zh-Hans') {
      this.spans = VideoLinkMock;
    } else {
      this.spans = VideoLinkMock_EN;
    }
    this.spans.forEach((span) => {
      if (span.url) {
        this.handleVideoLink(span);
      } else {
        this.styledStrings.push(new MutableStyledString(span.content, []));
      }
    });

    this.controller = HandleData.handleStyledString(this.styledStrings);
  }

  // [End handle_styled_string]

  /*
   * Link callback
   */
  // [Start link_callback]
  private linkClickCallback: (span: MyCustomSpan) => void =
    (span: MyCustomSpan) => {
      // Process according to the type of text hyperlink.
      if (span) {
        let uiContext = this.getUIContext();
        let router = uiContext.getRouter();
           if (span.url !== null) {
          router.pushUrl({ url: span.url });
        }
      }
    };

  // [End link_callback]

  @Builder
  navTitleBuilder() {
    Row() {
      Text($r("app.string.video_link"))
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