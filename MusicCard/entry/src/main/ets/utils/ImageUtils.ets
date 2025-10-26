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
import { effectKit } from '@kit.ArkGraphics2D';
import { Logger } from './Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'ImageUtils';

export class ImageDealData {
  imageColor: string = 'rgba(0, 0, 2, 1.00)';
  imageColorHex: string = '';
  blurPixelMap: PixelMap | undefined = undefined;
  blurPixelMapForCard: PixelMap | undefined = undefined;
}

/**
 * Color conversion processing class.
 */
// [Start image_utils]
// [Start music_control_card_color_card]
class ImageUtils {
  // [StartExclude music_control_card_color_card]
  // [End image_utils]
  /**
   * Generate an immersive background color for the image.
   * @param rRGB
   * @param gRGB
   * @param bRGB
   * @returns
   */
  public dealColor(rRGB: number, gRGB: number, bRGB: number) {
    let max = Math.max(Math.max(rRGB, gRGB), bRGB);
    let min = Math.min(Math.min(rRGB, gRGB), bRGB);
    let sHSB = max === 0 ? 0 : (max - min) / max;
    let bHSB = max / 255;
    let hHSB = 0;
    if (max === rRGB && gRGB >= bRGB) {
      hHSB = (60 * (gRGB - bRGB)) / (max - min) + 0;
    }
    if (max === rRGB && gRGB < bRGB) {
      hHSB = (60 * (gRGB - bRGB)) / (max - min) + 360;
    }
    if (max === gRGB) {
      hHSB = (60 * (bRGB - rRGB)) / (max - min) + 120;
    }
    if (max === bRGB) {
      hHSB = (60 * (rRGB - gRGB)) / (max - min) + 240;
    }

    if (bHSB >= 0.4) {
      bHSB = 0.3;
    } else if (bHSB >= 0.2) {
      bHSB -= 0.1;
    } else {
      bHSB = bHSB + 0.2;
    }

    let i: number = Math.floor((hHSB / 60) % 6);
    let f = hHSB / 60 - i;
    let p = bHSB * (1 - sHSB);
    let q = bHSB * (1 - f * sHSB);
    let t = bHSB * (1 - (1 - f) * sHSB);
    switch (i) {
      case 0:
        rRGB = bHSB;
        gRGB = t;
        bRGB = p;
        break;
      case 1:
        rRGB = q;
        gRGB = bHSB;
        bRGB = p;
        break;
      case 2:
        rRGB = p;
        gRGB = bHSB;
        bRGB = t;
        break;
      case 3:
        rRGB = p;
        gRGB = q;
        bRGB = bHSB;
        break;
      case 4:
        rRGB = t;
        gRGB = p;
        bRGB = bHSB;
        break;
      case 5:
        rRGB = bHSB;
        gRGB = p;
        bRGB = q;
        break;
      default:
        break;
    }
    return [Math.floor(rRGB * 255.0), Math.floor(gRGB * 255.0), Math.floor(bRGB * 255.0)];
  }

  public async getBlurPixelMap(pixelMap: PixelMap, blur: number): Promise<PixelMap> {
    let filter = effectKit.createEffect(pixelMap);
    filter.blur(blur);
    let blurPixelMap: PixelMap = await filter.getEffectPixelMap();
    return blurPixelMap;
  }
  // [EndExclude music_control_card_color_card]
  // [Start image_utils]
  public getImageDealData(context: Context, imgRes: Resource): Promise<ImageDealData> {
    return new Promise(async (resolve, reject) => {
      try {
        let value = context.resourceManager.getMediaContentSync(imgRes.id);
        let imageData = await this.getImageDealDataByArr(value.buffer as ArrayBuffer);
        resolve(imageData);
      } catch (err) {
        Logger.info(TAG, `getImageDealData err :${JSON.stringify(err)}`);
        reject(err);
      }
    });
  }
  // [End image_utils]

  // [StartExclude music_control_card_color_card]
  public async compressImage(sourcePixelMap: image.PixelMap, maxCompressedImageSize: number): Promise<PixelMap> {
    Logger.info(TAG, 'compressImage');
    let compressedImageData: ArrayBuffer = await this.packing(sourcePixelMap);
    if (compressedImageData.byteLength <= maxCompressedImageSize * 1024) {
      Logger.info(TAG, 'compressImage first');
      return sourcePixelMap;
    }
    let imageScale = 1;
    while (compressedImageData.byteLength > maxCompressedImageSize * 1024) {
      if (imageScale > 0) {
        imageScale = imageScale - 0.05;
        await sourcePixelMap.scale(imageScale, imageScale);
        compressedImageData = await this.packing(sourcePixelMap);
      } else {
        break;
      }
    }
    let afterCompressionSize = (compressedImageData.byteLength / 1024).toFixed(1);
    Logger.info(TAG, `compressImage afterCompressionSize:` + afterCompressionSize);
    if (compressedImageData.byteLength > maxCompressedImageSize * 1024) {
      Logger.info(TAG, 'compress iamge failed');
    }
    return sourcePixelMap;
  }

  async packing(sourcePixelMap: image.PixelMap): Promise<ArrayBuffer> {
    const imagePackerApi = image.createImagePacker();
    const packOpts: image.PackingOption = { format: 'image/' + 'jpeg', quality: 100 };
    let data: ArrayBuffer = new ArrayBuffer(1024);
    try {
      data = await imagePackerApi.packToData(sourcePixelMap, packOpts);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `onAddForm err, code: ${error.code}, mesage: ${error.message}`);
    }
    return data;
  }
  // [EndExclude music_control_card_color_card]
  // [Start image_utils]
  public getImageDealDataByArr(buffer: ArrayBuffer): Promise<ImageDealData> {
    return new Promise(async (resolve, reject) => {
      try {
        let pixelMap = image.createImageSource(buffer).createPixelMapSync();
        if (buffer.byteLength > 2048 * 1024) {
          pixelMap = await this.compressImage(pixelMap, 2048);
        }
        let imageData = new ImageDealData();
        let colorPicker = await effectKit.createColorPicker(pixelMap);
        let mainColor = colorPicker.getMainColorSync();
        let colorArr = this.dealColor(mainColor.red, mainColor.green, mainColor.blue);
        let imageColor = `rgba(${colorArr[0]}, ${colorArr[1]}, ${colorArr[2]}, 1)`;
        let imageColorHex = `${colorArr[0].toString(16)}${colorArr[1].toString(16)}${colorArr[2].toString(16)}`;
        // [StartExclude image_utils]
        // [StartExclude music_control_card_color_card]
        Logger.info(TAG, `getImageDealDataByArr imageColor :${imageColor}`);
        Logger.info(TAG, `getImageDealDataByArr imageColorHex :${imageColorHex}`);
        imageData.imageColor = imageColor;
        // [EndExclude image_utils]
        // [EndExclude music_control_card_color_card]
        imageData.imageColorHex = imageColorHex;
        // [StartExclude image_utils]
        // [StartExclude music_control_card_color_card]
        imageData.blurPixelMap = await this.getBlurPixelMap(pixelMap, 15);
        imageData.blurPixelMapForCard = await this.getBlurPixelMap(pixelMap, 100);
        Logger.info(TAG, `getImageDealDataByArr success`);
        // [EndExclude image_utils]
        // [EndExclude music_control_card_color_card]
        resolve(imageData);
      } catch (err) {
        Logger.info(TAG, `getImageDealDataByArr err :${JSON.stringify(err)}`);
        reject(err);
      }
    });
  }
}
// [End image_utils]
// [End music_control_card_color_card]

export default new ImageUtils();
