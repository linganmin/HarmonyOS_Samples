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
/*
* Best Practices: Enhancing Performance with Self-Drawing Capabilities
* Task: When the GlassCoverView subpage uses the @Watch decorator to detect updates in the homepage position list data
* pointsToDraw, it will render 1,000 transparent hollow circles on the page (refer to the onDraw() method for details).
*/
// [Start glass_cover_view]
// entry\src\main\ets\view\GlassCoverView.ets
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';

/**
 * glass overlay effect
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
    // hollow transparent circle
    hiTraceMeter.startTrace('slow', 1);
    console.info('debug: slow start');
    // Save drawing context
    canvas.save();
    // Clear specified pixels within the given rectangle.
    canvas.clearRect(0, 0, this.viewWidth, this.viewHeight);
    // Specify the fill color to be drawn
    canvas.fillStyle = '#77CCCCCC';
    // Fill a rectangle
    canvas.fillRect(0, 0, this.viewWidth, this.viewHeight);
    // draw hollow circles
    canvas.globalCompositeOperation = 'destination-out';
    canvas.fillStyle = '#CCCCCC';
    this.pointsToDraw.forEach((xy: number[]) => {
      this.drawOneCell(canvas, xy[0] * this.viewWidth, xy[1] * this.viewHeight, this.getUIContext().px2vp(15));
    })
    canvas.fill();
    // Restore the saved drawing context
    canvas.restore();
    console.info('debug: slow end');
    hiTraceMeter.finishTrace('slow', 1);
  }

  /**
   * Draw a circle based on the specified position and width.
   */
  private drawOneCell(canvas: CanvasRenderer, x: number, y: number, width: number): void {
    canvas.moveTo(x + width, y);
    canvas.arc(x, y, width, 0, Math.PI * 2);
  }
}
// [End glass_cover_view]