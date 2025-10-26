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
import { resourceManager } from '@kit.LocalizationKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit'
import { ColorHsv, ColorRgb, ColorUtils } from './ColorUtils';
import CommonConstants from '../constants/CommonContants';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const resourceMgs: resourceManager.ResourceManager = uiContext!.getHostContext()!.resourceManager;

/**
 * Convert image to PixelMap object
 */
export async function image2PixelMap(icon: string): Promise<image.PixelMap> {
  let pixelMap: Promise<PixelMap>;
  try {
    const rawFileDescriptor: resourceManager.RawFileDescriptor = resourceMgs.getRawFdSync(icon);
    const imageSource: image.ImageSource = image.createImageSource(rawFileDescriptor);
    pixelMap = imageSource.createPixelMap({
      editable: false,
      desiredPixelFormat: image.PixelMapFormat.BGRA_8888,
      desiredSize: { width: CommonConstants.PIXEL_MAP_SIZE_WIDTH, height: CommonConstants.PIXEL_MAP_SIZE_HEIGHT }
    })
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'testTag', `create PixelMap fail. code = ${err.code}, message = ${err.message}`);
  }

  return pixelMap!;
}

/**
 * Find the most frequent pixel in an array
 */
export function findMaxPixel(allPixels: number[]): number {
  const map: Map<number, number> = new Map();
  allPixels.forEach((pixel: number) => {
    if (map.has(pixel)) {
      map.set(pixel, map.get(pixel)! + 1);
    } else {
      map.set(pixel, 1);
    }
  })
  let maxPixel: number = 0;
  let maxTimes: number = 0;
  map.forEach((value: number, key: number) => {
    if (value >= maxTimes) {
      maxTimes = value;
      maxPixel = key;
    }
  })
  return maxPixel;
}

/**
 * To modify the color value in HSV format, you can modify the values of S and V according to business needs or
 * UI design. Here are only examples.
 */
export function modifySVValue(color: ColorHsv): void {
  if (color.hue > 0 && color.hue <= CommonConstants.MODIFY_SV_COLOR_HUE_60) {
    color.saturation = CommonConstants.MODIFY_SV_COLOR_SATURATION_12;
    color.value = CommonConstants.MODIFY_SV_COLOR_VALUE_93;
  } else if (color.hue > CommonConstants.MODIFY_SV_COLOR_HUE_60 &&
    color.hue <= CommonConstants.MODIFY_SV_COLOR_HUE_190) {
    color.saturation = CommonConstants.MODIFY_SV_COLOR_SATURATION_8;
    color.value = CommonConstants.MODIFY_SV_COLOR_VALUE_91;
  } else if (color.hue > CommonConstants.MODIFY_SV_COLOR_HUE_190 &&
    color.hue <= CommonConstants.MODIFY_SV_COLOR_HUE_270) {
    color.saturation = CommonConstants.MODIFY_SV_COLOR_SATURATION_10;
    color.value = CommonConstants.MODIFY_SV_COLOR_VALUE_93;
  } else {
    color.saturation = CommonConstants.MODIFY_SV_COLOR_SATURATION_8;
    color.value = CommonConstants.MODIFY_SV_COLOR_VALUE_93;
  }
}

/**
 * Iterate through all pixels and put them into an array
 */
export async function traverseAllPixel(pixelMap: image.PixelMap): Promise<number[]> {
  // The PixelMap object uses the BGRA_8888 format, with 4 bytes representing one pixel, and the width and height
  // are both set to 40, so the length of the ArrayBuffer here is 40*40*4
  const pixelArrayBuffer: ArrayBuffer =
    new ArrayBuffer(CommonConstants.RGB_WIDTH * CommonConstants.RGB_HEIGHT * CommonConstants.RGB_BIT_ONE_PIXEL);
  await pixelMap.readPixelsToBuffer(pixelArrayBuffer);
  const allPixels: number[] = [];
  const unit8Pixels: Uint8Array = new Uint8Array(pixelArrayBuffer);
  for (let i = 0; i < unit8Pixels.length; i += CommonConstants.RGB_BIT_ONE_PIXEL) {
    if (unit8Pixels[i] === 0 && unit8Pixels[i+1] === 0 && unit8Pixels[i+2] === 0 && unit8Pixels[i+3] === 0) {
      continue;
    }
    const rgb: ColorRgb = {
      red: unit8Pixels[i+2],
      green: unit8Pixels[i+1],
      blue: unit8Pixels[i],
      alpha: unit8Pixels[i+3]
    }
    allPixels.push(ColorUtils.rgbToNumber(rgb));
  }
  return allPixels;
}