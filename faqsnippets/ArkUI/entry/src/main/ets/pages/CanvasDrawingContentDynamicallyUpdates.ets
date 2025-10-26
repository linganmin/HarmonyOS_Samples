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
* FAQ:Canvas绘制内容如何动态更新
*/

// [Start canvas_drawing_content_dynamically_updates]
@Entry
@Component
struct CanvasContentUpdate {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @State @Watch('draw')content: string = '';

  draw() {
    this.context.clearRect(0, 0, 200, 200); // Clean up canvas content
    this.context.fillText(this.content, 50, 50); // Refill
  }

  build() {
    Column() {
      Canvas(this.context)
        .width('100%')
        .height('25%')
        .backgroundColor('#F5DC62')
        .onReady(() => {
          //You can draw content here.
          this.context.font = '55px sans-serif';
          this.context.fillText(this.content, 50, 50);
        })
      TextInput({
        text:$$this.content
      })
    }
    .borderColor('#31525B')
    .borderWidth(12)
    .width('100%')
    .height('100%')
  }
}
// [End canvas_drawing_content_dynamically_updates]