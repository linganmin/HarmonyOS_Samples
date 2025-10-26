/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { image } from '@kit.ImageKit';
import { banner, rectangle, square } from '../utils/CropUtil';
import { AdjustType, CropType, MirrorType, FilterType } from '../viewModel/OptionViewModel';
import Logger from '../utils/LoggerUtil';
import { CommonConstants } from '../common/constant/CommonConstants';
import { effectKit } from '@kit.ArkGraphics2D';
import { MessageEvents, worker } from '@kit.ArkTS';
import { MessageItem } from '../viewModel/MessageItem';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from  '@kit.BasicServicesKit'

const TAG = 'PixelMapManager';

export enum EditType {
  CROP,
  FILTER,
  TRANSLATION,
  SCALE,
  MIRROR,
  ROTATION,
  ADJUST
}

interface TranslateValue {
  x: number;
  y: number;
}

export class PixelMapManager {
  private startEditPixelMap?: PixelMap;
  private finalEditPixelMap?: PixelMap;
  private originPixelMap?: PixelMap;
  private originCropPixelMap?: PixelMap;
  private editMode: EditType = EditType.CROP;
  private notifyPreviewUpdate: (previewPixelMap: PixelMap) => void;
  private adjustWorker: worker.ThreadWorker =
    new worker.ThreadWorker(CommonConstants.ADJUST_WORKER_FILE);

  constructor(pixelMap: PixelMap, notifyPreviewUpdate: (previewPixelMap: PixelMap) => void) {
    this.originPixelMap = pixelMap;
    this.originCropPixelMap = pixelMap;
    this.notifyPreviewUpdate = notifyPreviewUpdate;
    this.updatePreviewPixelMap(pixelMap);
  }

  destroyPixelMapManager() {
    try {
      this.adjustWorker.terminate();
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
    }
  }

  getInitPixelMap() {
    return this.originPixelMap!;
  }

  getInitCropPixelMap() {
    return this.originCropPixelMap!;
  }

  getStartPixelMap() {
    return this.startEditPixelMap!;
  }

  getFinalPixelMap() {
    return this.finalEditPixelMap!;
  }

  updateCropPixelMap(pixelMap: image.PixelMap) {
    this.originCropPixelMap = pixelMap;
    this.notifyPreviewUpdate(this.clonePixelMap(pixelMap));
  }

  updatePreviewPixelMap(pixelMap: image.PixelMap) {
    this.startEditPixelMap = pixelMap;
    this.finalEditPixelMap = pixelMap;
    this.notifyPreviewUpdate(this.clonePixelMap(pixelMap));
  }

  async handleFilter(type: FilterType) {
    let px: PixelMap = this.getStartEditPixelMap(EditType.FILTER);
    let filter = effectKit.createEffect(px);

    switch (type) {
      case FilterType.GRAYSCALE:
        px = await filter.grayscale().getEffectPixelMap();
        break;
      case FilterType.BRIGHTNESS:
        px = await filter.brightness(0.7).getEffectPixelMap();
        break;
      case FilterType.INVERT:
        px = await filter.invert().getEffectPixelMap();
        break;
      case FilterType.BLUR:
        px = await filter.blur(5).getEffectPixelMap();
        break;
      default:
        break;
    }
    this.notifyPreviewUpdate(px);
    this.finalEditPixelMap = px;
  }

  getStartEditPixelMap(mode: EditType): PixelMap {
    if (this.editMode !== mode) {
      this.editMode = mode;
      this.startEditPixelMap = this.finalEditPixelMap;
    }
    let target: PixelMap | undefined;
    switch (mode) {
      case EditType.CROP:
        target = this.startEditPixelMap;
        break;
      case EditType.MIRROR:
        target = this.finalEditPixelMap;
        break;
      case EditType.ROTATION:
        target = this.finalEditPixelMap;
        break;
      case EditType.FILTER:
        target = this.startEditPixelMap;
        break;
      case EditType.ADJUST:
        target = this.startEditPixelMap;
        break;
      case EditType.TRANSLATION:
        target = this.finalEditPixelMap;
        break;
      case EditType.SCALE:
        target = this.startEditPixelMap;
        break;
      default:
        target = this.finalEditPixelMap;
        break;
    }
    return this.clonePixelMap(target!);
  }


  async cropImage(proportion: CropType) {
    let px = this.getStartEditPixelMap(EditType.CROP);
    const imageInfo = await px.getImageInfo();
    const size = imageInfo.size;
    const imageWidth = size?.width;
    const imageHeight = size?.height;

    switch (proportion) {
      case CropType.ORIGINAL_IMAGE:
        px = this.getInitCropPixelMap();
        this.notifyPreviewUpdate(this.getInitCropPixelMap());
        break;
      case CropType.SQUARE:
        square(px, imageWidth, imageHeight).then(() => {
          this.notifyPreviewUpdate(px);
        });
        break;
      case CropType.BANNER:
        banner(px, imageWidth, imageHeight).then(() => {
          this.notifyPreviewUpdate(px);
        });
        break;
      case CropType.RECTANGLE:
        rectangle(px, imageWidth, imageHeight).then(() => {
          this.notifyPreviewUpdate(px);
        });
        break;
      default:
        break;
    }
    this.finalEditPixelMap = px;
  }

  mirrorImage(mirrorType: MirrorType) {
    const px = this.getStartEditPixelMap(EditType.MIRROR);
    if (mirrorType === MirrorType.CLOCKWISE) {
      try {
        px.flipSync(true, false);
      } catch (error) {
        Logger.error(TAG, `there is a error in rotate process with ${error?.code}`);
      }
    }
    this.notifyPreviewUpdate(px);
    this.finalEditPixelMap = px;
  }

  rotateImage() {
    const px = this.getStartEditPixelMap(EditType.ROTATION);
    try {
      px.rotate(CommonConstants.ANTI_CLOCK)
        .then(() => {
          this.notifyPreviewUpdate(px);
        });
    } catch (error) {
      Logger.error(TAG, `there is a error in rotate process with ${error?.code}`);
    }

    this.finalEditPixelMap = px;
  }

  async adjustImage(currentAdjustData: number[]) {
    const px = this.getStartEditPixelMap(EditType.ADJUST);
    let buffer = new ArrayBuffer(px.getPixelBytesNumber());
    px.readPixelsToBuffer(buffer);
    if (!buffer) {
      return;
    }
    if (currentAdjustData[AdjustType.BRIGHTNESS] !== CommonConstants.SLIDER_MAX) {
      buffer = await this.processAdjustWorker(
        currentAdjustData[AdjustType.BRIGHTNESS],
        buffer,
        AdjustType.BRIGHTNESS
      );
      try {
        px.writeBufferToPixelsSync(buffer);
      } catch (err) {
        let error = err as BusinessError;
        hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
      }
    }
    if (currentAdjustData[AdjustType.SATURATION] !== CommonConstants.SLIDER_MAX) {
      try {
        buffer = await this.processAdjustWorker(
          currentAdjustData[AdjustType.SATURATION],
          buffer,
          AdjustType.SATURATION
        );
        px.writeBufferToPixelsSync(buffer);
      } catch (err) {
        let error = err as BusinessError;
        hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
      }
    }
    if (currentAdjustData[AdjustType.OPACITY] !== CommonConstants.SLIDER_MAX) {
      const opacity = currentAdjustData[AdjustType.OPACITY] / CommonConstants.SLIDER_MAX;
      try {
        px.opacitySync(opacity);
      } catch (err) {
        let error = err as BusinessError;
        hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
      }
    }
    this.finalEditPixelMap = px;
    this.notifyPreviewUpdate(px);
  }

  private processAdjustWorker(value: number, buffer: ArrayBuffer, adjustType: AdjustType): Promise<ArrayBuffer> {
    return new Promise((resolve) => {
      const message = new MessageItem(buffer, CommonConstants.SLIDER_MAX, value, adjustType);
      this.adjustWorker.postMessage(message);
      this.adjustWorker.onmessage = (event: MessageEvents) => {
        resolve(event.data);
      };
    });
  }

  async translateImage(moveValue: TranslateValue) {
    const px = this.getStartEditPixelMap(EditType.TRANSLATION);
    await px.translate(moveValue.x, moveValue.y);
    this.finalEditPixelMap = px;
    try {
      this.notifyPreviewUpdate(px);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
    }
  }

  async editImageScale(scale: number) {
    const px = this.getStartEditPixelMap(EditType.SCALE);
    try {
      await px.scale(scale, scale);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
    }
    this.notifyPreviewUpdate(px);
  }

  clonePixelMap(pixelMap: PixelMap, desiredPixelFormat?: image.PixelMapFormat): PixelMap {
    try {
      const imageInfo = pixelMap.getImageInfoSync();
      const buffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
      pixelMap.readPixelsToBufferSync(buffer);
      const options: image.InitializationOptions = {
        srcPixelFormat: imageInfo.pixelFormat,
        pixelFormat: desiredPixelFormat ?? imageInfo.pixelFormat,
        size: imageInfo.size
      };
      return image.createPixelMapSync(buffer, options);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
      return pixelMap;
    }
  }
}