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

// [Start glass_cover_view]
import { hilog, hiTraceMeter } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'GlassCoverView';
const FORMAT = '%{public}s';

/**
 * Glass cladding effect
 */
@Preview
@Component
export default struct GlassCoverView {
  @Prop @Watch('onDraw') pointsToDraw: number[][] = [];
  private settings = new RenderingContextSettings(true);
  private renderContext = new CanvasRenderingContext2D(this.settings);
  private viewWidth: number = 0;
  private viewHeight: number = 0;

  build() {
    Stack() {
      Canvas(this.renderContext)
        .width('100%')
        .height('100%')
        .onAreaChange((_: Area, newValue: Area) => {
          this.handleAreaChange(newValue);
        })
    }
    .height('100%')
    .width('100%')
  }

  private handleAreaChange(area: Area): void {
    this.viewWidth = parseInt(area.width.toString());
    this.viewHeight = parseInt(area.height.toString());
    this.onDraw();
  }

  private onDraw(): void {
    const canvas = this.renderContext;
    canvas.reset();
    if (canvas === undefined) {
      return;
    }
    // Hollow transparent circle
    hiTraceMeter.startTrace('slow', 1);
    hilog.info(DOMAIN, TAG, FORMAT, 'debug: slow start');
    // Save drawing context
    canvas.save();
    // Clears the specified pixel within the given rectangle
    canvas.clearRect(0, 0, this.viewWidth, this.viewHeight);
    // Specifies the fill color of the drawing
    canvas.fillStyle = '#77CCCCCC';
    // Fill a rectangle
    canvas.fillRect(0, 0, this.viewWidth, this.viewHeight);
    // Draw a hollow circle
    canvas.globalCompositeOperation = 'destination-out';
    canvas.fillStyle = '#CCCCCC';
    this.pointsToDraw.forEach((xy: number[]) => {
      this.drawOneCell(canvas, xy[0] * this.viewWidth, xy[1] * this.viewHeight, this.getUIContext().px2vp(15));
    })
    canvas.fill();
    // Restore the saved drawing context
    canvas.restore();
    hilog.info(DOMAIN, TAG, FORMAT, 'debug: slow end');
    hiTraceMeter.finishTrace('slow', 1);
  }

  /**
   * Draw a circle according to the specified position and width
   */
  private drawOneCell(canvas: CanvasRenderer, x: number, y: number, width: number): void {
    canvas.moveTo(x + width, y);
    canvas.arc(x, y, width, 0, Math.PI * 2);
  }
}
// [End glass_cover_view]