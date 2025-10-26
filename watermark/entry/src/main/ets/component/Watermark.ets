/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { getResourceString } from "../constants/Utils";
import { common } from "@kit.AbilityKit";

// [Start water_mark]
@Component
export struct Watermark {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  // [StartExclude water_mark]
  // [Start water_fill]
  @Prop watermarkWidth: number = 120;
  @Prop watermarkHeight: number = 120;
  @Prop watermarkText: string = this.getWatermarkText();
  @Prop rotationAngle: number = -30;
  @Prop fillColor: string | number | CanvasGradient | CanvasPattern = '#10000000';
  @Prop font: string = '16vp';

  draw() {
    this.context.fillStyle = this.fillColor;
    this.context.font = this.font;
    const colCount = Math.ceil(this.context.width / this.watermarkWidth);
    const rowCount = Math.ceil(this.context.height / this.watermarkHeight);
    for (let col = 0; col <= colCount; col++) {
      let row = 0;
      for (; row <= rowCount; row++) {
        const angle = this.rotationAngle * Math.PI / 180;
        this.context.rotate(angle);
        const positionX = this.rotationAngle > 0 ? this.watermarkHeight * Math.tan(angle) : 0;
        const positionY = this.rotationAngle > 0 ? 0 : this.watermarkWidth * Math.tan(-angle);
        this.context.fillText(this.watermarkText, positionX, positionY);
        this.context.rotate(-angle);
        this.context.translate(0, this.watermarkHeight);
      }
      this.context.translate(0, -this.watermarkHeight * row);
      this.context.translate(this.watermarkWidth, 0);
    }
  }
  // [End water_fill]
  getWatermarkText() {
    return getResourceString($r('app.string.watermark_screen_text'), this.getUIContext().getHostContext() as common.UIAbilityContext)
  }
  // [EndExclude water_mark]
  build() {
    Canvas(this.context)
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Transparent)
      .onReady(() => this.draw())
  }
}
// [End water_mark]