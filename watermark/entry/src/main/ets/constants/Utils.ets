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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { display } from '@kit.ArkUI';
import { Context } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'Utils';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let fd: number | null = null;
// [Start save_file]
export async function saveToFile(pixelMap: image.PixelMap, context: Context): Promise<void> {
  try {
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    const filePath = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
    const imagePacker = image.createImagePacker();
    const imageBuffer = await imagePacker.packToData(pixelMap, {
      format: 'image/png',
      quality: 100
    });
    const mode = fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE;
    fd = (await fileIo.open(filePath, mode)).fd;
    await fileIo.truncate(fd);
    await fileIo.write(fd, imageBuffer);
  } catch (err) {
    hilog.error(0x0000, TAG, 'saveToFile error：', JSON.stringify(err) ?? '');
  } finally {
    try {
      if (fd) {
        fileIo.close(fd);
      }
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, TAG, `close failed code=${err.code}, message=${err.message}`);
    }
  }
}
// [End save_file]
export interface ImagePixelMap {
  pixelMap: image.PixelMap
  width: number
  height: number
}
// [Start image_Source]
export async function imageSource2PixelMap(imageSource: image.ImageSource): Promise<ImagePixelMap> {
  const imageInfo: image.ImageInfo = await imageSource.getImageInfo();
  const height = imageInfo.size.height;
  const width = imageInfo.size.width;
  const options: image.DecodingOptions = {
    editable: true,
    desiredSize: { height, width }
  };
  const pixelMap: PixelMap = await imageSource.createPixelMap(options);
  const result: ImagePixelMap = { pixelMap, width, height };
  return result;
}
// [End image_Source]
// [Start add_water_mark]
export function addWatermark(
  imagePixelMap: ImagePixelMap,
  text: string = 'watermark',
  drawWatermark?: (OffscreenContext: OffscreenCanvasRenderingContext2D) => void
): image.PixelMap {
  const height = uiContext?.px2vp(imagePixelMap.height) as number;
  const width = uiContext?.px2vp(imagePixelMap.width) as number;
  const offScreenCanvas = new OffscreenCanvas(width, height);
  const offScreenContext = offScreenCanvas.getContext('2d');
  offScreenContext.drawImage(imagePixelMap.pixelMap, 0, 0, width, height);
  if (drawWatermark) {
    drawWatermark(offScreenContext);
  } else {
    let displayWidth: number = 0;
    try {
      displayWidth = display.getDefaultDisplaySync().width;
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, TAG, `failed code=${err.code}, message=${err.message}`);
    }
    const vpWidth = uiContext?.px2vp(displayWidth) ?? displayWidth;
    const imageScale = width / vpWidth;
    offScreenContext.textAlign = 'right';
    offScreenContext.fillStyle = '#A2FFFFFF';
    offScreenContext.font = 12 * imageScale + 'vp';
    const padding = 5 * imageScale;
    offScreenContext.fillText(text, width - padding, height - padding);
  }
  return offScreenContext.getPixelMap(0, 0, width, height);
}
// [End add_water_mark]
export function getResourceString(resource: Resource, context: Context): string {
  let result: string = '';
  try {
    result = context.resourceManager.getStringSync(resource.id);
  } catch (e) {
    hilog.error(0x0000, TAG, `[getResourceString]getStringSync failed, error:${JSON.stringify(e)}.`);
  }
  return result;
}

