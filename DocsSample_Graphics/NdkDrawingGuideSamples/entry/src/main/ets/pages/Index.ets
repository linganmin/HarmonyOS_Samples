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

import XComponentContext from "../interface/XComponentContext";
import { FrameNode, NodeController, RenderNode } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';

enum DrawType {
  none,
  canvasState,
  shape,
  path,
  picText,
  complex,
}

@Entry
@Component
struct Index {
  private xComponentContext: XComponentContext | undefined = undefined;
  private pMap: image.PixelMap | undefined = undefined;
  aboutToAppear() {
    const context: Context = getContext(this);
    const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
    resourceMgr.getRawFileContent('startIcon.png').then((fileData: Uint8Array) => {
      console.log('Succeeded in getting RawFileContent');
      const buffer = fileData.buffer.slice(0);
      const imageSource: image.ImageSource = image.createImageSource(buffer);
      imageSource.createPixelMap().then((pMap: image.PixelMap) => {
        this.pMap = pMap;
      }).catch((err: BusinessError) => {
        console.error('Failed to creating PixelMap');
      });
    }).catch((err: BusinessError) => {
      console.error('Failed to get RawFileContent');
    });
  }
  build() {
    Column() {
      Row() {
        XComponent({ id: 'xcomponentId', type: 'surface', libraryname: 'entry' })
          .onLoad((xComponentContext) => {
            this.xComponentContext = xComponentContext as XComponentContext;
          }).width('100%') // Multiples of 64
      }
      .width('100%')
      .height('80%')
      GridRow({
        columns: 1,
        gutter: {x: 5, y: 10},
      }) {
        GridCol({ span: { xs: 1, sm: 2, md: 3, lg: 4 }, offset: 0, order: 0 }){
          Row(){
            Button('画布操作及状态')
              .margin({ top: 10, right: 10 })
              .onClick(() => {
                if (this.xComponentContext) {
                  this.xComponentContext.drawPattern(DrawType.canvasState, this.pMap);
                }
              })
            Button('几何形状绘制')
              .margin({ top: 10, right: 10 })
              .onClick(() => {
                if (this.xComponentContext) {
                  this.xComponentContext.drawPattern(DrawType.shape, this.pMap);
                }
              })
            Button('路径绘制')
              .margin({ top: 10, right: 10 })
              .onClick(() => {
                if (this.xComponentContext) {
                  this.xComponentContext.drawPattern(DrawType.path, this.pMap);
                }
              })
          }
        }
        GridCol({ span: { xs: 1, sm: 2, md: 3, lg: 4 }, offset: 0, order: 0 }){
          Row(){
            Button('图片和字块绘制')
              .margin({ right: 8 })
              .onClick(() => {
                if (this.xComponentContext) {
                  this.xComponentContext.drawPattern(DrawType.picText, this.pMap);
                }
              })
            Button('复杂绘制效果')
              .margin({ right: 8 })
              .onClick(() => {
                if (this.xComponentContext) {
                  this.xComponentContext.drawPattern(DrawType.complex, this.pMap);
                }
              })
          }
        }
      }
      .width('100%')
      .shadow(ShadowStyle.OUTER_DEFAULT_SM)
      .layoutWeight(1)
    }
  }
}
