/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { encode } from '../utils/EncodeUtil';
import { SavePicker } from '../dialog/SavePicker';
import { PixelMapManager } from '../utils/PixelMapManager';

const DOMAIN: number = 0XFF;
const TAG: string = 'TitleComponent';

@Component
export struct TitleComponent {
  uiContext: UIContext = this.getUIContext();
  @Link isShow: boolean;
  @Link canvasOffsetX: number;
  @Link canvasOffsetY: number;
  @Consume pixelMap: image.PixelMap;
  @Consume filterCurrIndex: number;
  @Consume filterPixelMap: image.PixelMap;
  @Consume previewPixelMap: image.PixelMap;
  @Consume savePixelMap: image.PixelMap;
  @Consume pixelMapManager?: PixelMapManager;
  pixelInit: () => void = () => {
  };
  dialogSaveController: CustomDialogController | null = new CustomDialogController({
    builder: SavePicker({
      cancel: () => {
        this.CancelSave();
      },
      confirm: () => {
        this.dialogSave();
        this.dialogSaveController?.close();
      }
    })
  });

  CancelSave() {
    this.dialogSaveController?.close();
  }

  async dialogSave() {
    if (this.pixelMapManager?.getFinalPixelMap()) {
      encode(this.savePixelMap, this.uiContext);
    }
  }

  async createTranslatedPixelMap(): Promise<image.PixelMap | undefined> {
    if (!this.pixelMap || (this.canvasOffsetX === 0 && this.canvasOffsetY === 0)) {
      const imageToSave = (this.filterCurrIndex > 0 && this.filterPixelMap) ? this.filterPixelMap : this.pixelMap;
      return imageToSave;
    }

    try {
      const imageInfo = await this.previewPixelMap.getImageInfo();
      const imageWidth = imageInfo.size.width;
      const imageHeight = imageInfo.size.height;

      const srcBuffer = new ArrayBuffer(imageWidth * imageHeight * 4);
      await this.previewPixelMap.readPixelsToBuffer(srcBuffer);
      const srcData = new Uint8Array(srcBuffer);

      const destBuffer = new ArrayBuffer(imageWidth * imageHeight * 4);
      const destData = new Uint8Array(destBuffer);

      for (let y = 0; y < imageHeight; y++) {
        for (let x = 0; x < imageWidth; x++) {
          const srcX = x - this.canvasOffsetX;
          const srcY = y - this.canvasOffsetY;

          const destIndex = (y * imageWidth + x) * 4;

          if (srcX >= 0 && srcX < imageWidth && srcY >= 0 && srcY < imageHeight) {
            const srcIndex = (srcY * imageWidth + srcX) * 4;
            destData[destIndex] = srcData[srcIndex];
            destData[destIndex + 1] = srcData[srcIndex + 1];
            destData[destIndex + 2] = srcData[srcIndex + 2];
            destData[destIndex + 3] = srcData[srcIndex + 3];
          } else {
            destData[destIndex] = 0;
            destData[destIndex + 1] = 0;
            destData[destIndex + 2] = 0;
            destData[destIndex + 3] = 0;
          }
        }
      }

      const translatedPixelMap = await image.createPixelMap(destBuffer, {
        size: { width: imageWidth, height: imageHeight },
        pixelFormat: image.PixelMapFormat.RGBA_8888
      });

      return translatedPixelMap;
    } catch (error) {
      hilog.error(DOMAIN, TAG, '%{public}s, %{public}s', 'Failed to create translated pixelMap:',
        JSON.stringify(error));
      const imageToSave = (this.filterCurrIndex > 0 && this.filterPixelMap) ? this.filterPixelMap : this.pixelMap;
      return imageToSave;
    }
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Text($r('app.string.image_edit'))
          .fontColor('rgba(255,255,255,0.9)')
          .fontSize(26)
          .fontWeight(700)
      }
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .height(56)

      Row() {
        Button() {
          Image($r('app.media.ic_reset'))
            .width(22)
            .height(22)
        }
        .padding(9)
        .borderRadius('50%')
        .type(ButtonType.Normal)
        .aspectRatio(1)
        .backgroundColor('rgba(255,255,255,0.1)')
        .onClick(() => {
          this.pixelInit();
        })

        Text() {
          SymbolSpan($r('sys.symbol.info_circle'))
            .fontColor([Color.White, Color.White, Color.White])
            .fontWeight(FontWeight.Normal)
            .fontSize(22)
        }
        .margin({ left: 8 })
        .padding(9)
        .borderRadius('50%')
        .backgroundColor('rgba(255,255,255,0.1)')
        .onClick(() => {
          this.isShow = true;
        })

        Text() {
          SymbolSpan($r('sys.symbol.save'))
            .fontColor([Color.White, Color.White, Color.White])
            .fontWeight(FontWeight.Normal)
            .fontSize(22)
        }
        .margin({ left: 8 })
        .padding(9)
        .borderRadius('50%')
        .backgroundColor($r('sys.color.container_modal_button_hover_baseboard'))
        .onClick(() => {
          this.dialogSaveController?.open();
        })
      }
      .padding({ right: 16 })
      .height(56)
    }
    .width('100%')
  }
}