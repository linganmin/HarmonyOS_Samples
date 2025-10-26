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
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@ohos.base';
import { Logger } from './LogUtil';

export class ImageUtil {
  private static IMAGE_MAX_SIZE: number = 1024 * 30;
  /**
   * load network URL image
   */
  public static async getNetworkPicture(url: string, defaultPath: string): Promise<image.PixelMap | string> {
    if (url) {
      let httpRequest = http.createHttp();
      try {
        const data = await httpRequest.request(url);
        const buffer = data.result as ArrayBuffer;
        const imageSourceApi: image.ImageSource = image.createImageSource(buffer);
        let imgPixelMap = await imageSourceApi.createPixelMap();
        if (imgPixelMap.getPixelBytesNumber() <= ImageUtil.IMAGE_MAX_SIZE) {
          return imgPixelMap;
        }
        return await ImageUtil.compressImage(imgPixelMap);
      } catch (error) {
        const err = error as BusinessError;
        Logger.error(`Invoke downloadFile failed, code is ${err.code}, message is ${err.message}`);
        return defaultPath;
      } finally {
        httpRequest.destroy()
      }
    } else{
      return defaultPath;
    }
  }

  /**
   * 压缩图片，等比例缩放图片的长宽
   */
  public static async compressImage(sourcePixelMap: PixelMap): Promise<image.PixelMap> {
    let imageScale = 1;
    const reduceScale = 0.2;
    const imagePackerApi = image.createImagePacker();
    const packerOption: image.PackingOption = { format: 'image/jpeg', quality: 100 };
    let compressedImageBuffer = await imagePackerApi.packToData(sourcePixelMap, packerOption);
    while (sourcePixelMap.getPixelBytesNumber() > ImageUtil.IMAGE_MAX_SIZE) {
      if (imageScale <= 0) {
        break;
      }
      imageScale = imageScale - reduceScale;
      sourcePixelMap.scaleSync(imageScale, imageScale, image.AntiAliasingLevel.MEDIUM);
      compressedImageBuffer = await imagePackerApi.packToData(sourcePixelMap, packerOption);
    }
    return await image.createImageSource(compressedImageBuffer).createPixelMap();
  }
}