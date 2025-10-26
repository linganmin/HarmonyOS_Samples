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

import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit';
import ParamPassing from 'libentry.so';

@Builder
export function pixelMapPage(_entry: string, param: string) {
  NavDestination() {
    MainComponent()
  }
  .title(param)
  .backgroundColor($r('app.color.sub_window_background'))
}

@Preview
@Component
struct MainComponent {
  @State pixelMap: image.PixelMap | undefined = undefined;
  @State loadComplete: boolean = false;

  // [Start load_pixel_map]
  // entry/src/main/ets/pages/PixelMapPage.ets
  async loadPixelMap() {
    let resourceManager = this.getUIContext().getHostContext()!.resourceManager;
    try {
      let imageArray = await resourceManager.getMediaContent($r('app.media.SampleImage').id);
      let imageResource = image.createImageSource(imageArray.buffer);
      let opts: image.DecodingOptions = { editable: true, desiredPixelFormat: image.PixelMapFormat.BGRA_8888 };
      imageResource.createPixelMap(opts).then((pixelMap) => {
        this.pixelMap = pixelMap;
        this.loadComplete = true;
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `getMediaContent fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  aboutToAppear(): void {
    this.loadPixelMap();
  }

  // [End load_pixel_map]

  build() {
    Column() {
      // [Start load_complete]
      // entry/src/main/ets/pages/PixelMapPage.ets
      if (this.loadComplete) {
        Image(this.pixelMap)
          .height(400)
      } else {
        Image($r('app.media.loading'))
          .height(400)
      }
      // [End load_complete]
      Blank()
      Button($r('app.string.button_text_execute'))
        .onClick(() => {
          // [Start pixel_map]
          // entry/src/main/ets/pages/PixelMapPage.ets
          if (this.pixelMap) {
            this.loadComplete = false;
            ParamPassing.pixelMapPassing(this.pixelMap);
            // Only modifying PixelMap cannot cause the system to re render,
            // so this method is required to manually refresh the image component.
            setTimeout(() => this.loadComplete = true, 500);
          }
          // [End pixel_map]
        })
        .width($r('app.string.100percent'))
    }
    .padding($r("app.string.margin_l"))
    .width($r('app.string.100percent'))
    .height($r('app.string.100percent'))
  }
}