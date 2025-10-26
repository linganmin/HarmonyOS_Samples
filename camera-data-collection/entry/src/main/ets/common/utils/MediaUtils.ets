/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import Logger from './Logger';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext?.getHostContext() as common.Context;

interface Result {
  prefix: string,
  suffix: string
}

export default class MediaUtils {
  private tag: string = 'MediaUtils';

  public static getInstance() {
    let instance: MediaUtils = new MediaUtils();
    if (instance === undefined) {
      instance = new MediaUtils();
    }
    return instance;
  }

  async createAndGetUri(mediaType: number) {
    try {
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      Logger.info(this.tag, `createAndGetUri`);
      let photoType: photoAccessHelper.PhotoType = mediaType;
      let info = this.getInfoFromType(mediaType);
      let extension: string = info.suffix;
      // Return the created media resource.
      return await phAccessHelper.createAsset(photoType, extension);
    } catch (e) {
      Logger.error(this.tag, `createAndGetUri error ${JSON.stringify(e)}`);
    }
    return '';
  }

  async getFdPath(uri: string) {
    try {
      let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE);
      let fd = file.fd;
      Logger.info(this.tag, `fd = ${fd}`);
      return fd;
    } catch (e) {
      Logger.error(this.tag, `getFdPath error ${JSON.stringify(e)}`);
    }
    return -1;
  }

  getInfoFromType(mediaType: number) {
    let result: Result = {
      prefix: '',
      suffix: ''
    };
    switch (mediaType) {
      case photoAccessHelper.PhotoType.IMAGE:
        result.prefix = 'IMG_';
        result.suffix = 'jpg';
        break;
      case photoAccessHelper.PhotoType.VIDEO:
        result.prefix = 'VID_';
        result.suffix = 'mp4';
        break;
    }
    return result;
  }
}