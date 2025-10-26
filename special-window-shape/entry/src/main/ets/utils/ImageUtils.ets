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
import { resourceManager } from '@kit.LocalizationKit';
import { Context } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';


// [Start image_to_pixel_map]
/**
 * Convert image to PixelMap object
 */
export async function image2PixelMap(Context: Context, icon: string, w: number, h: number): Promise<image.PixelMap> {
  try {
    const rawFileDescriptor: resourceManager.RawFileDescriptor = Context.resourceManager.getRawFdSync(icon);
    const imageSource: image.ImageSource = image.createImageSource(rawFileDescriptor);
    const pixelMap: Promise<PixelMap> = imageSource.createPixelMap({
      editable: false,
      desiredPixelFormat: image.PixelMapFormat.BGRA_8888,
      desiredSize: { width: w, height: h }
    });
    imageSource.release()
    return pixelMap;
  } catch (e) {
    let err = e as BusinessError;
    hilog.error(0x0000, 'Simple', `failed code=${err.code}, message=${err.message}`);
  }
  return new Promise<image.PixelMap>((resolve, reject) => {
    reject('null')
  });
}

// [End image_to_pixel_map]
