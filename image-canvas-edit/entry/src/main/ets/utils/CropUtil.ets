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

import { RegionItem } from '../viewModel/RegionItem';
import { CommonConstants } from '../common/constant/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * Crop 1:1.
 *
 * @param pixelMap.
 * @param width.
 * @param height.
 */
export function square(pixelMap: PixelMap, width: number, height: number) {
  if (width < height) {
    try {
      pixelMap.cropSync({
        size: {
          width: width,
          height: width,
        },
        x: 0,
        y: Math.round((height - width) / CommonConstants.AVERAGE_WEIGHT_WIDTH),
      });
    } catch (err) {
      hilog.error(0xFF00, 'error', '%{public}s', 'have errors', `${JSON.stringify(err)}`);
    }
  } else {
    try {
      pixelMap.cropSync({
        size: {
          width: height,
          height: height,
        },
        x: Math.round((width - height) / CommonConstants.AVERAGE_WEIGHT_WIDTH),
        y: 0,
      });
    } catch (err) {
      hilog.error(0xFF00, 'error', '%{public}s', 'have errors', `${JSON.stringify(err)}`);
    }
  }
}

/**
 * Common crop function.
 *
 * @param pixelMap.
 * @param cropWidth.
 * @param cropHeight.
 * @param cropPosition.
 */
export function cropCommon(pixelMap: PixelMap, cropWidth: number, cropHeight: number, cropPosition: RegionItem) {
  try {
    pixelMap.cropSync({
      size: {
        width: cropWidth,
        height: cropHeight,
      },
      x: cropPosition.x,
      y: cropPosition.y,
    });
  } catch (err) {
    hilog.error(0xFF00, 'error', '%{public}s', 'have errors', `${JSON.stringify(err)}`);
  }
}

/**
 * Crop 4:3.
 *
 * @param pixelMap.
 * @param width.
 * @param height.
 */
export function banner(pixelMap: PixelMap, width: number, height: number) {
  if (width <= height) {
    const cropWidth = width;
    const cropHeight = Math.floor(width * CommonConstants.CROP_RATE_4_3);
    const cropPosition = new RegionItem(0, Math.floor((height - cropHeight) / CommonConstants.AVERAGE_WEIGHT_WIDTH));
    cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }
  if (width * CommonConstants.CROP_RATE_4_3 >= height) {
    const cropWidth = Math.floor(height / CommonConstants.CROP_RATE_4_3);
    const cropHeight = height;
    const cropPosition = new RegionItem(Math.floor((width - cropWidth) / CommonConstants.AVERAGE_WEIGHT_WIDTH), 0);
    cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }

  const cropWidth = width;
  const cropHeight = Math.floor(width * CommonConstants.CROP_RATE_4_3);
  const cropPosition = new RegionItem(0, Math.floor((height - cropHeight) / CommonConstants.AVERAGE_WEIGHT_WIDTH));
  cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
}

/**
 * Crop 16:9.
 *
 * @param pixelMap.
 * @param width.
 * @param height.
 */
export function rectangle(pixelMap: PixelMap, width: number, height: number) {
  if (width <= height) {
    const cropWidth = width;
    const cropHeight = Math.floor(width * CommonConstants.CROP_RATE_9_16);
    const cropPosition = new RegionItem(0, Math.floor((height - cropHeight) / CommonConstants.AVERAGE_WEIGHT_WIDTH));
    cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }
  if (width * CommonConstants.CROP_RATE_9_16 >= height) {
    const cropWidth = Math.floor(height / CommonConstants.CROP_RATE_9_16);
    const cropHeight = height;
    const cropPosition = new RegionItem(Math.floor((width - cropWidth) / CommonConstants.AVERAGE_WEIGHT_WIDTH), 0);
    cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }

  const cropWidth = width;
  const cropHeight = Math.floor(width * CommonConstants.CROP_RATE_9_16);
  const cropPosition = new RegionItem(0, Math.floor((height - cropHeight) / CommonConstants.AVERAGE_WEIGHT_WIDTH));
  cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
}
