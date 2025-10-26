/*
 * Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
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
import { BusinessError } from '@kit.BasicServicesKit'
import { ImageCropConstants } from '../constants/ImageCropConstants';

/**
 * Save pixelMap and return path.
 */
export async function savePixelMap(context: Context, pm: PixelMap): Promise<string> {
  if (pm === null) {
    return '';
  }
  const imagePackerApi: image.ImagePacker = image.createImagePacker();
  const packOpts: image.PackingOption =
    { format: 'image/jpeg', quality: ImageCropConstants.PACKING_QUALITY_PERCENT_THIRTY };
  try {
    packToFile(context, pm);
    const data: ArrayBuffer = await imagePackerApi.packToData(pm, packOpts);
    return await saveFile(context, data);
  } catch (err) {
    return '';
  }
}

async function packToFile(context: Context, pixelMap: PixelMap): Promise<void> {
  try {
    const fPath: string = context.cacheDir + '/' + getTimeStr() + ImageCropConstants.IMAGE_FORMAT;
    const writeFd: fileIo.File = await fileIo.open(fPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);

    const opts: image.PackingOption =
      { format: ImageCropConstants.PACKING_FORMAT, quality: ImageCropConstants.PACKING_QUALITY_FULL };
    const imagePacker = image.createImagePacker();
    await imagePacker.packToFile(pixelMap, writeFd.fd, opts);
    fileIo.closeSync(writeFd.fd);
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'testTag', `packToFile fail. code = ${err.code}, message = ${err.message}`);
  }
}

async function saveFile(context: Context, data: ArrayBuffer): Promise<string> {
  let uri: string = context.filesDir + '/' + getTimeStr() + ImageCropConstants.IMAGE_FORMAT;

  try {
    const file: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.writeSync(file.fd, data);
    fileIo.closeSync(file);
    uri = ImageCropConstants.URI_HEAD + uri;
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'testTag', `file write fail. code = ${err.code}, message = ${err.message}`);
  }

  return uri;
}

function getTimeStr(): string {
  const now: Date = new Date();
  const year: number = now.getFullYear();
  const month: number = now.getMonth() + 1;
  const day: number = now.getDate();
  const hours: number = now.getHours();
  const minutes: number = now.getMinutes();
  const seconds: number = now.getSeconds();
  return `${year}${month}${day}_${hours}${minutes}${seconds}`;
}