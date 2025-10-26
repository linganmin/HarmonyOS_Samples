/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

/*
* FAQ:如何对相册图片进行编辑裁剪
*/

// [Start CropCommon]
// Crop 4:3
class RegionItem {
  /**
   * width coordinate.
   */
  x: number;

  /**
   * height coordinate.
   */
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

export async function cropCommon(pixelMap: PixelMap, cropWidth: number, cropHeight: number, cropPosition: RegionItem) {
  pixelMap.crop({
    size: {
      width: cropWidth,
      height: cropHeight
    },
    x: cropPosition.x,
    y: cropPosition.y
  });
}

// Pass in three parameters: image. PixelMap, image width, and image height. After obtaining the cropped image width and height,
// pass the parameters into the cropCommon method
export async function banner(pixelMap: PixelMap, width: number, height: number) {
  if (width <= height) {
    const cropWidth = width;
    const cropHeight = Math.floor(width * 0.75);
    const cropPosition = new RegionItem(0, Math.floor((height - cropHeight) / 2));
    cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }
  if (width * 0.75 >= height) {
    const cropWidth = Math.floor(height / 0.75);
    const cropHeight = height;
    const cropPosition = new RegionItem(Math.floor((width - cropWidth) / 2), 0);
    cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
    return;
  }
  const cropWidth = width;
  const cropHeight = Math.floor(width * 0.75);
  const cropPosition = new RegionItem(0, Math.floor((height - cropHeight) / 2));
  cropCommon(pixelMap, cropWidth, cropHeight, cropPosition);
}
// [End CropCommon]

