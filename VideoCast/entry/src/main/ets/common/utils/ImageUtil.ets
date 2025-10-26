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

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
/**
 * Converts a media resource into a PixelMap object.
 * @param resource The media resource containing bundle, module and ID references.
 * @returns Promise<image.PixelMap> with RGBA_8888 format.
 */
export async function getPixmapFromMedia(resource: Resource) {
  let unit8Array = await uiContext?.getHostContext()?.resourceManager?.getMediaContent({
    bundleName: resource.bundleName,
    moduleName: resource.moduleName,
    id: resource.id
  });
  let imageSource = image.createImageSource(unit8Array?.buffer.slice(0, unit8Array?.buffer.byteLength));
  let pixelMap: image.PixelMap = await imageSource.createPixelMap({
    desiredPixelFormat: image.PixelMapFormat.RGBA_8888
  });
  await imageSource.release();
  return pixelMap;
}
