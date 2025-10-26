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
import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'UTILS';

/**
 * Copy the source image into sandbox.
 * @param src - source image path
 * @param path - sandbox path
 * @returns Promise<string>
 */
export async function copyImg2Sandbox(src: string, path: string): Promise<string> {
  try {
    let srcImage = fs.openSync(src, fs.OpenMode.READ_ONLY);
    let destImage = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.copyFileSync(srcImage.fd, destImage.fd);
    fs.closeSync(srcImage);
    fs.closeSync(destImage);
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'copyImg2Sandbox', `copyImg2Sandbox failed, error code=${err.code}, message=${err.message}`);
  }
  return path;
}

/**
 * Save the pixel map into image file.
 * @param pixelMap - pixel map
 * @param path - file path
 * @returns Promise<void>
 */
export async function pixelMap2File(pixelMap: image.PixelMap | undefined, path: string): Promise<void> {
  try {
    const imagePacker = image.createImagePacker();
    let file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    let packOpts: image.PackingOption = { format: 'image/jpeg', quality: 98 };
    imagePacker.packToFile(pixelMap, file.fd, packOpts).then(() => {
      hilog.info(0x0000, TAG, 'packToFile succeed!');
      fs.closeSync(file.fd);
    }).catch((error: BusinessError) => {
      hilog.error(0x0000, TAG, 'packToFile failed, error: ' + JSON.stringify(error));
    });
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'pixelMap2File', `pixelMap2File failed, error code=${err.code}, message=${err.message}`);
  }
}