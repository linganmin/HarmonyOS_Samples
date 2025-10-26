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

import { fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import Logger from './LoggerUtil';
import { CommonConstants } from '../common/constant/CommonConstants';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'imageEdit_Decode';

/**
 * Async get resource fd.
 *
 * @return file fd.
 */
export async function getResourceFd(uiContext: UIContext, uri: string = '') {
  try {
    const context = uiContext.getHostContext() as common.UIAbilityContext;
    const resourceMgr = context.resourceManager;

    let filePath: string;
    let file: fs.File;

    if (uri === '') {
      let imageBuffer = await resourceMgr.getMediaContent($r('app.media.ic_low').id);

      filePath = context.cacheDir + '/' + CommonConstants.RAW_FILE_NAME;
      file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, imageBuffer.buffer);
    } else {
      file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    }
    return file.fd;
  } catch (err) {
    hilog.error(0xFF00, TAG, '%{public}s', 'have errors', `${JSON.stringify(err)}`);
    return;
  }
}

/**
 * Async create pixel map.
 *
 * @return pixelMa.
 */
export async function decodePixelMapFromImageSource(imageSource: image.ImageSource) {
  if (!imageSource) {
    Logger.error(TAG, 'imageSourceAPI created failed!');
    return;
  }
  let decodingOptions: image.DecodingOptions = {
    editable: true,
    desiredPixelFormat: 3,
    //Setting to AUTO will decode based on the image resource format. If the image resource is an HDR resource, it will be decoded as an HDR pixel map
    desiredDynamicRange: image.DecodingDynamicRange.AUTO,
  };
  const pixelMap = await imageSource.createPixelMap(decodingOptions);

  return pixelMap;
}
