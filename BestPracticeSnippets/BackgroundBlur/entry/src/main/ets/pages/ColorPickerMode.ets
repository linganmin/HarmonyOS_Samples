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

// [Start color_picker]
import { image } from '@kit.ImageKit';
import { effectKit } from '@kit.ArkGraphics2D';

@Component
export struct ColorPickerMode {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State pixMap: image.PixelMap | null = null
  @State kitColor: effectKit.Color = {
    red: 255,
    green: 255,
    blue: 255,
    alpha: 255
  };
  @State blurColor: string = 'rgba(255,255,255,255)';

  async blurPix(resource: Resource) {
    try {
      const context: Context = this.getUIContext().getHostContext()!;
      const fileData: Uint8Array = await context.resourceManager.getMediaContent(resource.id);
      const buffer: ArrayBufferLike = fileData.buffer
      let imageSource: image.ImageSource = image.createImageSource(buffer as ArrayBuffer)
      this.pixMap = await imageSource.createPixelMap();
      // create a color picker for color extraction
      this.kitColor = (await effectKit.createColorPicker(this.pixMap, [0, 0, 1, 1])).getAverageColor();
      // convert to the format of the blur interface color parameter
      this.blurColor = 'rgba(' + this.kitColor.red + ',' + this.kitColor.green + ',' + this.kitColor.blue + ',0)';
    } catch (err) {
    }
  }

  build() {
    NavDestination() {
      Column() {
        Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          Text('Background Material Blur').fontColor('#FFFFFF')
        }
        .height('50%')
        .width('70%')
        // assign a value to the color parameter of a blur interface
        .backgroundEffect({
          radius: 20,
          saturation: 1.0,
          brightness: 1.0,
          color: this.blurColor
        })
        .position({ x: '15%', y: '30%' })
      }
      .height('100%')
      .width('100%')
      .backgroundImage($r('app.media.test'))
      .backgroundImageSize(ImageSize.Cover)
      .onAppear(() => {
        // import image resources
        this.blurPix($r('app.media.test'));
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
  }
}

// [End color_picker]
