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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';

const TAG: string = '[DecodeUtil]';

/**
 * Async get resource fd.
 *
 * @return file fd.
 */
async function getResourceFd(component: UIContext): Promise<number> {
  const context = component.getHostContext()!;
  const resourceMgr = context.resourceManager;
  let res = -1;
  try {
    let imageBuffer = await resourceMgr.getMediaContent($r('app.media.ic_low').id);
    let filePath = context.cacheDir + '/low.jpg';
    let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.writeSync(file.fd, imageBuffer.buffer);
    res = file.fd;
  } catch (err) {
    hilog.error(0x0000, 'DecodeUtil', 'Failed to get resource fd: ', JSON.stringify(err) ?? '');
  }
  return res;
}

/**
 * Async create pixel map.
 *
 * @return pixelMa.
 */
export default async function getPixelMap(component: UIContext): Promise<image.PixelMap | undefined> {
  const fd = await getResourceFd(component);
  const imageSourceApi = image.createImageSource(fd);
  if (!imageSourceApi) {
    hilog.error(0x0000, TAG, '%{public}s', 'imageSourceAPI created failed!');
    return;
  }
  const pixelMap = await imageSourceApi.createPixelMap({
    editable: true
  });
  return pixelMap;
}