/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { RegionItem } from '../viewModel/RegionItem';

/**
 * Crop 1:1.
 *
 * @param pixelMap.
 * @param width.
 * @param height.
 */
export async function square(pixelMap: PixelMap, width: number, height: number): Promise<void> {
  if (width < height) {
    await pixelMap.crop({
      size: {
        width: width,
        height: width
      },
      x: 0,
      y: Math.round((height - width) / 2)
    });
  } else {
    await pixelMap.crop({
      size: {
        width: height,
        height: height
      },
      x: Math.round((width - height) / 2),
      y: 0
    });
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
export async function cropCommon(pixelMap: PixelMap, cropWidth: number, cropHeight: number,
  cropPosition: RegionItem): Promise<void> {
  await pixelMap.crop({
    size: {
      width: cropWidth,
      height: cropHeight
    },
    x: cropPosition.x,
    y: cropPosition.y
  });
}

/**
 * Crop 4:3.
 *
 * @param pixelMap.
 * @param width.
 * @param height.
 */
export async function banner(pixelMap: PixelMap, width: number, height: number): Promise<void> {
  if (width <= height) {
    const cropWidth = width;
    const cropHeight = Math.floor(width * 0.75);
    const cropPosition = new RegionItem(0, Math.floor((height - cropHeight) / 2));
    await cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }
  if (width * 0.75 >= height) {
    const cropWidth = Math.floor(height / 0.75);
    const cropHeight = height;
    const cropPosition = new RegionItem(Math.floor((width - cropWidth) / 2), 0);
    await cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }

  const cropWidth = width;
  const cropHeight = Math.floor(width * 0.75);
  const cropPosition = new RegionItem(0, Math.floor((height - cropHeight) / 2));
  await cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
}

/**
 * Crop 16:9.
 *
 * @param pixelMap.
 * @param width.
 * @param height.
 */
export async function rectangle(pixelMap: PixelMap, width: number, height: number): Promise<void> {
  if (width <= height) {
    const cropWidth = width;
    const cropHeight = Math.floor(width * (9 / 16));
    const cropPosition = new RegionItem(0, Math.floor((height - cropHeight) / 2));
    await cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }
  if (width * (9 / 16) >= height) {
    const cropWidth = Math.floor(height / (9 / 16));
    const cropHeight = height;
    const cropPosition = new RegionItem(Math.floor((width - cropWidth) / 2), 0);
    await cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }

  const cropWidth = width;
  const cropHeight = Math.floor(width * (9 / 16));
  const cropPosition = new RegionItem(0, Math.floor((height - cropHeight) / 2));
  await cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
}