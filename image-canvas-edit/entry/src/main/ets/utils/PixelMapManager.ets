/*
 *
 *  *
 *  *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  *  Licensed under the Apache License, Version 2.0 (the "License");
 *  *  you may not use this file except in compliance with the License.
 *  *  You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  *  Unless required by applicable law or agreed to in writing, software
 *  *  distributed under the License is distributed on an "AS IS" BASIS,
 *  *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  *  See the License for the specific language governing permissions and
 *  *  limitations under the License.
 *  *
 *
 */

import { image } from '@kit.ImageKit';
import { banner, rectangle, square } from './CropUtil';
import { AdjustType, CropType, MirrorType, FilterType } from '../viewModel/OptionViewModel';
import Logger from './LoggerUtil';
import { CommonConstants } from '../common/constant/CommonConstants';
import { effectKit } from '@kit.ArkGraphics2D';
import { MessageEvents, worker } from '@kit.ArkTS';
import { MessageItem } from '../viewModel/MessageItem';
import { WatermarkConfig, WatermarkPosition } from './WatermarkUtil';
import { ContextStorageManager } from './ContextStorageUtil';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'PixelMapManager';

export enum EditType {
  CROP,
  FILTER,
  TRANSLATION,
  SCALE,
  MIRROR,
  ROTATION,
  ADJUST,
  WATER,
}

interface TranslateValue {
  x: number;
  y: number;
}

interface PositionResult {
  x: number;
  y: number;
}

interface SpacingConfig {
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
  private adjustWorker: worker.ThreadWorker = new worker.ThreadWorker(CommonConstants.ADJUST_WORKER_FILE);

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
      hilog.error(0xFF00, TAG, '%{public}s', 'have errors', `${JSON.stringify(err)}`);
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
      case EditType.WATER:
        target = this.startEditPixelMap;

      default:
        target = this.finalEditPixelMap;
        break;
    }
    return this.clonePixelMap(target!);
  }

  /**
   * Calculate watermark position
   */
  private calculateWatermarkPosition(imageWidth: number, imageHeight: number, textWidth: number, textHeight: number,
    position: WatermarkPosition): PositionResult {
    const padding = 20;

    switch (position) {
      case WatermarkPosition.TOP_LEFT:
        return { x: padding, y: padding } as PositionResult;
      case WatermarkPosition.TOP_RIGHT:
        return { x: imageWidth - textWidth - padding, y: padding } as PositionResult;
      case WatermarkPosition.BOTTOM_LEFT:
        return { x: padding, y: imageHeight - textHeight - padding } as PositionResult;
      case WatermarkPosition.BOTTOM_RIGHT:
        return { x: imageWidth - textWidth - padding, y: imageHeight - textHeight - padding } as PositionResult;
      case WatermarkPosition.CENTER:
        return {
          x: (imageWidth - textWidth) / 2,
          y: (imageHeight - textHeight) / 2,
        } as PositionResult;
      default:
        return { x: padding, y: padding } as PositionResult;
    }
  }

  async addTextWatermark(pixelMap: image.PixelMap, config: WatermarkConfig) {
    try {
      const uiContext: UIContext = ContextStorageManager.getInstance().getContext();

      const px = this.getStartEditPixelMap(EditType.WATER);
      const imageInfo = await px.getImageInfo();
      const size = imageInfo.size;
      const imageWidth = uiContext.px2vp(size?.width);
      const imageHeight = uiContext.px2vp(size?.height);

      const offscreenCanvas = new OffscreenCanvas(imageWidth, imageHeight);
      const offscreenCanvasContext = offscreenCanvas.getContext('2d') as OffscreenCanvasRenderingContext2D;

      offscreenCanvasContext.drawImage(pixelMap, 0, 0, imageWidth, imageHeight);

      offscreenCanvasContext.font = `${uiContext.fp2px(config.fontSize)}px sans-serif`;
      offscreenCanvasContext.fillStyle = config.color;
      offscreenCanvasContext.globalAlpha = config.opacity;

      const textMetrics = offscreenCanvasContext.measureText(config.text);
      const textWidth = textMetrics.width;
      const textHeight = config.fontSize;

      const position = this.calculateWatermarkPosition(imageWidth, imageHeight, textWidth, textHeight, config.position);

      if (config.rotation && config.rotation !== 0) {
        offscreenCanvasContext.save();
        offscreenCanvasContext.translate(position.x + textWidth / 2, position.y + textHeight / 2);
        offscreenCanvasContext.rotate((config.rotation * Math.PI) / 180);
        offscreenCanvasContext.fillText(config.text, -textWidth / 2, textHeight / 4);
        offscreenCanvasContext.restore();
      } else {
        offscreenCanvasContext.fillText(config.text, position.x, position.y + textHeight);
      }

      const watermarkedPixelMap = offscreenCanvasContext.getPixelMap(0, 0, imageWidth, imageHeight);
      Logger.info(TAG, 'Watermark added successfully');
      this.notifyPreviewUpdate(watermarkedPixelMap);
      this.finalEditPixelMap = watermarkedPixelMap;
    } catch (error) {
      Logger.error(TAG, `Error adding watermark: ${JSON.stringify(error)}`);
      throw new Error(`Failed to add watermark: ${JSON.stringify(error)}`);
    }
  }

  async addRepeatedWatermark(pixelMap: image.PixelMap, config: WatermarkConfig, spacing?: SpacingConfig) {
    try {
      const uiContext: UIContext = ContextStorageManager.getInstance().getContext();

      const defaultSpacing: SpacingConfig = { x: 200, y: 150 };
      const actualSpacing = spacing || defaultSpacing;

      const px = this.getStartEditPixelMap(EditType.WATER);
      const imageInfo = await px.getImageInfo();
      const imageWidth = uiContext.px2vp(imageInfo.size.width);
      const imageHeight = uiContext.px2vp(imageInfo.size.height);

      const offscreenCanvas = new OffscreenCanvas(imageWidth, imageHeight);
      const context = offscreenCanvas.getContext('2d') as OffscreenCanvasRenderingContext2D;

      context.drawImage(pixelMap, 0, 0, imageWidth, imageHeight);

      context.font = `${uiContext.fp2px(config.fontSize)}px sans-serif`;
      context.fillStyle = config.color;
      context.globalAlpha = config.opacity;

      const textMetrics = context.measureText(config.text);
      const textWidth = textMetrics.width;
      const textHeight = config.fontSize;

      for (let x = 0; x < imageWidth; x += actualSpacing.x) {
        for (let y = 0; y < imageHeight; y += actualSpacing.y) {
          if (config.rotation && config.rotation !== 0) {
            context.save();
            context.translate(x + textWidth / 2, y + textHeight / 2);
            context.rotate((config.rotation * Math.PI) / 180);
            context.fillText(config.text, -textWidth / 2, textHeight / 4);
            context.restore();
          } else {
            context.fillText(config.text, x, y + textHeight);
          }
        }
      }

      const watermarkedPixelMap = context.getPixelMap(0, 0, imageWidth, imageHeight);
      Logger.info(TAG, 'Repeated watermark added successfully');
      this.notifyPreviewUpdate(watermarkedPixelMap);
      this.finalEditPixelMap = watermarkedPixelMap;
    } catch (error) {
      Logger.error(TAG, `Error adding repeated watermark: ${JSON.stringify(error)}`);
      throw new Error(`Failed to add repeated watermark: ${JSON.stringify(error)}`);
    }
  }

  updateTranslationEndPx(pixelMap: image.PixelMap) {
    this.finalEditPixelMap = pixelMap;
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
        square(px, imageWidth, imageHeight);
        this.notifyPreviewUpdate(px);
        break;
      case CropType.BANNER:
        banner(px, imageWidth, imageHeight);
        this.notifyPreviewUpdate(px);
        break;
      case CropType.RECTANGLE:
        rectangle(px, imageWidth, imageHeight);
        this.notifyPreviewUpdate(px);
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
      px.rotateSync(CommonConstants.ANTI_CLOCK);
    } catch (error) {
      Logger.error(TAG, `there is a error in rotate process with ${error?.code}`);
    }
    this.notifyPreviewUpdate(px);
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
      try {
        buffer =
          await this.processAdjustWorker(currentAdjustData[AdjustType.BRIGHTNESS], buffer, AdjustType.BRIGHTNESS);
        px.writeBufferToPixelsSync(buffer);
      } catch (err) {
        hilog.error(0xFF00, TAG, '%{public}s', 'have errors', `${JSON.stringify(err)}`);
      }
    }
    if (currentAdjustData[AdjustType.SATURATION] !== CommonConstants.SLIDER_MAX) {
      try {
        buffer =
          await this.processAdjustWorker(currentAdjustData[AdjustType.SATURATION], buffer, AdjustType.SATURATION);
        px.writeBufferToPixelsSync(buffer);
      } catch (err) {
        hilog.error(0xFF00, TAG, '%{public}s', 'have errors', `${JSON.stringify(err)}`);
      }
    }
    if (currentAdjustData[AdjustType.OPACITY] !== CommonConstants.SLIDER_MAX) {
      const opacity = currentAdjustData[AdjustType.OPACITY] / CommonConstants.SLIDER_MAX;
      try {
        px.opacitySync(opacity);
      } catch (err) {
        hilog.error(0xFF00, TAG, '%{public}s', 'have errors', `${JSON.stringify(err)}`);
      }
    }
    this.finalEditPixelMap = px;
    this.notifyPreviewUpdate(px);
  }

  private processAdjustWorker(value: number, buffer: ArrayBuffer, adjustType: AdjustType): Promise<ArrayBuffer> {
    return new Promise((resolve) => {
      const message = new MessageItem(buffer, CommonConstants.SLIDER_MAX, value, adjustType);
      try {
        this.adjustWorker.postMessage(message);
      } catch (error) {
        hilog.error(0xFF00, TAG, '%{public}s', 'have errors', `${JSON.stringify(error)}`);
      }
      this.adjustWorker.onmessage = (event: MessageEvents) => {
        resolve(event.data);
      };
    });
  }

  async translateImage(moveValue: TranslateValue) {
    const px = this.getStartEditPixelMap(EditType.TRANSLATION);
    await px.translate(moveValue.x, moveValue.y);
    this.finalEditPixelMap = px;
    this.notifyPreviewUpdate(px);
  }

  async editImageScale(scale: number) {
    const px = this.getStartEditPixelMap(EditType.SCALE);
    await px.scale(scale, scale);
    this.notifyPreviewUpdate(px);
  }

  clonePixelMap(pixelMap: PixelMap, desiredPixelFormat?: image.PixelMapFormat): PixelMap {
    try {
      const imageInfo = pixelMap.getImageInfoSync();
      const buffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
      const options: image.InitializationOptions = {
        srcPixelFormat: imageInfo.pixelFormat,
        pixelFormat: desiredPixelFormat ?? imageInfo.pixelFormat,
        size: imageInfo.size,
      };
      pixelMap.readPixelsToBufferSync(buffer);
      return image.createPixelMapSync(buffer, options);
    } catch (err) {
      hilog.error(0xFF00, TAG, '%{public}s', 'have errors', `${JSON.stringify(err)}`);
      return pixelMap;
    }
  }
}
