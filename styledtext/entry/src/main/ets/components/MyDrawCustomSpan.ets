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

import { common2D, drawing } from '@kit.ArkGraphics2D';

// [Start draw_span]
export class MyDrawCustomSpan extends CustomSpan {
  width: number = 0;
  word: string = "drawing";
  height: number = 10;
  systemLanguage: string = 'zh-Hans';
  color: string | undefined = undefined;
  gUIContext: UIContext | undefined = undefined;

  // [StartExclude draw_span]
  constructor(word: string, width: number, height: number, systemLanguage: string, color: string | undefined,
    gUIContext: UIContext | undefined) {
    super();
    this.word = word;
    this.width = width;
    this.height = height;
    this.systemLanguage = systemLanguage;
    this.color = color;
    this.gUIContext = gUIContext;
  }

  onMeasure(): CustomSpanMetrics {
    // Calculate the required width based on language
    let _width = 5 + this.word.length * 13;
    if (this.systemLanguage !== 'zh-Hans') {
      _width = 10 + this.word.length * 7;
    }
    return { width: _width, height: this.height };
  }

  // [EndExclude draw_span]

  // Draw
  onDraw(context: DrawContext, options: CustomSpanDrawInfo) {
    let canvas = context.canvas;

    // Set brush
    const brush = new drawing.Brush();
    // [StartExclude draw_span]
    if (this.color === 'green') {
      brush.setColor({
        alpha: 51,
        red: 100,
        green: 187,
        blue: 92
      });
    } else if (this.color === 'red') {
      brush.setColor({
        alpha: 51,
        red: 187,
        green: 100,
        blue: 92
      });
    }
    canvas.attachBrush(brush);
    // [EndExclude draw_span]

    // Calculate offset
    let _left = options.x - 50;
    if (this.systemLanguage !== 'zh-Hans') {
      _left = options.x - 40;
    }

    // Draw a rounded rectangle
    let rect: common2D.Rect = {
      left: _left,
      top: options.lineTop + 11,
      right: options.x + this.width,
      bottom: options.lineBottom
    };

    let roundRect = new drawing.RoundRect(rect, 10, 10);
    canvas.drawRoundRect(roundRect);
    // [StartExclude draw_span]
    if (this.color === 'green') {
      brush.setColor({
        alpha: 255,
        red: 100,
        green: 187,
        blue: 92
      });
    } else if (this.color === 'red') {
      brush.setColor({
        alpha: 255,
        red: 232,
        green: 64,
        blue: 38
      });
    }
    // [EndExclude draw_span]

    const font = new drawing.Font();
    font.setSize(40);
    const textBlob = drawing.TextBlob.makeFromString(this.word, font, drawing.TextEncoding.TEXT_ENCODING_UTF8);
    canvas.attachBrush(brush);
    canvas.drawTextBlob(textBlob, options.x + 5, options.lineBottom - 10);
    canvas.detachBrush();
  }

  setWord(word: string) {
    this.word = word;
  }
}

// [End draw_span]