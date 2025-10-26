/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:使用Canvas如何实现部分区域镂空的效果
*/

// [Start canvas_realizes_region_hollowing_out]
@Entry
@Component
struct HollowOutWithCanvas {
  @State circleCenterX: number = 0;
  @State circleCenterY: number = 0;
  @State circleRadius: number = 1000;
  private contextSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.contextSettings);

  build() {
    Row() {
      Column() {
        Stack() {
          Image($r('app.media.startIcon'))
            .height(300)
          // Use Canvas to draw masks to cover images, cameras, etc
          Canvas(this.context)
            .width('100%')
            .height('100%')
            .backgroundColor('#00000000')
            .onReady(() => {
              this.circleCenterX = this.context.width / 2;
              this.circleCenterY = this.context.height / 2;
              this.context.fillStyle = 'rgba(0,0,0,0.67)';
              if (this.circleRadius > this.circleCenterX) {
                this.circleRadius = this.circleCenterX / 2;
              }
              // Draw a circular path for semi transparent filling
              this.context.beginPath();
              this.context.moveTo(0, 0);
              this.context.lineTo(0, this.context.height);
              this.context.lineTo(this.context.width, this.context.height);
              this.context.lineTo(this.context.width, 0);
              this.context.lineTo(0, 0);
              this.context.arc(this.circleCenterX, this.circleCenterY, this.circleRadius, 0, Math.PI * 2);
              this.context.fill();
              this.context.closePath();
            })
        }
        .width('1456px')
        .height('1456px')
      }
      .width('100%')
    }
    .height('100%')
  }
}

// [End canvas_realizes_region_hollowing_out]