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

import { TextureCompression } from './TextureCompression';
import { OptimizeWebImagesUsingCDN } from './OptimizeWebImagesUsingCDN';
import { DownsampleThePixelmapUsingDesiredSize } from './DownsampleThePixelmapUsingDesiredSize';
import { UseAutoResizeToDownsampleTheImageComponent } from './UseAutoResizeToDownsampleTheImageComponent';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string, param: string): void {
    if (name === 'TextureCompression') {
      TextureCompression()
    } else if (name === 'OptimizeWebImagesUsingCDN') {
      OptimizeWebImagesUsingCDN()
    } else if (name === 'DownsampleThePixelmapUsingDesiredSize') {
      DownsampleThePixelmapUsingDesiredSize()
    } else if (name === 'UseAutoResizeToDownsampleTheImageComponent') {
      UseAutoResizeToDownsampleTheImageComponent()
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Column({ space: 12 }) {
          Button('使用纹理压缩优化预置图片')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('TextureCompression', '');
            })

          Button('使用CDN优化网络图片资源')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('OptimizeWebImagesUsingCDN', '');
            })

          Button('使用desiredSize对pixelmap进行降采样')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.pageInfos.pushPathByName('DownsampleThePixelmapUsingDesiredSize', '');
            })

          Button('使用autoResize对Image组件进行降采样')
            .width('100%')
            .borderRadius(20)
            .backgroundColor('#0A59F7')
            .margin({ bottom: 16 })
            .onClick(() => {
              this.pageInfos.pushPathByName('UseAutoResizeToDownsampleTheImageComponent', '');
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16
      })
      .justifyContent(FlexAlign.End)
    }
    .title('图片资源加载优化')
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
    .navDestination(this.PageMap)
  }
}