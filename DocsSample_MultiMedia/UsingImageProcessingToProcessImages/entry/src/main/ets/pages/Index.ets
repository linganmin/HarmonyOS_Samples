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

import { image } from '@kit.ImageKit';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink('hdrPixelMap') hdrPixelMap: image.PixelMap | undefined = undefined;

  build() {
    Navigation(this.pageInfos) {
      Column({ space: 12 }) {
        Button($r('app.string.image_scaling'))
          .width('100%')
          .onClick(() => {
            this.pageInfos.pushPathByName('ImageScaling', null, true);
          })

        Button($r('app.string.image_space_conversion'))
          .width('100%')
          .onClick(() => {
            this.pageInfos.pushPathByName('ImageColorSpaceConversion', null, true);
          })

        Button($r('app.string.metadata_generation'))
          .width('100%')
          .enabled(this.hdrPixelMap === undefined ? false : true)
          .onClick(() => {
            this.pageInfos.pushPathByName('MetadataGeneration', null, true);
          })

        Button($r('app.string.image_layer_conversion'))
          .width('100%')
          .enabled(this.hdrPixelMap === undefined ? false : true)
          .onClick(() => {
            this.pageInfos.pushPathByName('HDRImageConversion', null, true);
          })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .title($r('app.string.ImageProcessing_Processes_Images'))
    .mode(NavigationMode.Stack)
    .backgroundColor($r('sys.color.container_modal_unfocus_background'))
  }
}