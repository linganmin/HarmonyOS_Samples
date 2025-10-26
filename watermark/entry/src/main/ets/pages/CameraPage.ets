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
import { fileIo } from '@kit.CoreFileKit';
import { addWatermark, getResourceString, ImagePixelMap, imageSource2PixelMap, saveToFile } from '../constants/Utils';
import { NavBar } from '../component/NavBar';
import { Constants } from '../constants/Constants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'CameraPage';

@Entry
@Component
struct CameraPage {
  private fileUri: string = (this.getUIContext().getRouter().getParams() as Record<string, string>).fileUri;
  @State addedWatermarkPixelMap: image.PixelMap | null = null;

  showSuccess() {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: $r('app.string.message_save_success'),
        duration: Constants.TOAST_DURATION
      });
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, TAG, `showToast failed code=${err.code}, message=${err.message}`);
    }
  }

  getWatermarkText() {
    return getResourceString($r('app.string.watermark_text'), this.getUIContext().getHostContext() as common.UIAbilityContext)
  }

  async getImagePixelMap(fileUri: string): Promise<ImagePixelMap | undefined> {
    let result: ImagePixelMap | undefined = undefined;
    try {
      const file = fileIo.openSync(fileUri);
      const imageSource: image.ImageSource = image.createImageSource(file.fd);
      fileIo.closeSync(file);
      result = await imageSource2PixelMap(imageSource);
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, TAG, `failed code=${err.code}, message=${err.message}`);
    }
    return result;
  }

  build() {
    Column() {
      NavBar()
      Scroll() {
        Image(this.addedWatermarkPixelMap || this.fileUri)
          .width('100%')
      }
      .layoutWeight(1)
      .margin({ bottom: 10 })
      Row() {
        if (!this.addedWatermarkPixelMap) {
          Button($r('app.string.button_text_add_watermark'))
            .height(40)
            .width('100%')
            .onClick(async () => {
              const imagePixelMap = await this.getImagePixelMap(this.fileUri);
              this.addedWatermarkPixelMap = addWatermark(imagePixelMap!, this.getWatermarkText());
            })
        } else {
          SaveButton()
            .height(40)
            .width('100%')
            .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
              if (result === SaveButtonOnClickResult.SUCCESS) {
                try {
                  await saveToFile(this.addedWatermarkPixelMap!, this.getUIContext().getHostContext() as common.UIAbilityContext)
                  this.showSuccess();
                } catch (err) {
                  hilog.error(0x0000, TAG, 'createAsset failed, error:', err);
                }
              } else {
                hilog.error(0x0000, TAG, 'SaveButtonOnClickResult createAsset failed');
              }
            })
        }
      }
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
