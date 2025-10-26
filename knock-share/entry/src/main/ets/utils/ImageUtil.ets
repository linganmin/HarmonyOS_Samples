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

// [Start save_iamge_to_sandbox]
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { Logger } from './Logger';
import { fileIo } from '@kit.CoreFileKit';

const TAG = 'ImageUtil';

export class ImageUtil {
  /**
   * Save image to sandbox.
   * @param context UIAbility Context.
   */
  public static saveImage(context: common.UIAbilityContext) {
    try {
      [
        [context.resourceManager.getMediaContentSync($r('app.media.video_cover_0').id), '/video_cover_0.png'],
        [context.resourceManager.getMediaContentSync($r('app.media.video_cover_1').id), '/video_cover_1.png'],
        [context.resourceManager.getMediaContentSync($r('app.media.video_cover_2').id), '/video_cover_2.png'],
        [context.resourceManager.getMediaContentSync($r('app.media.video_cover_3').id), '/video_cover_3.png']
      ].forEach(item => {
        let file: fileIo.File | undefined = undefined;
        try {
          file = fileIo.openSync(context.filesDir + item[1], fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
          let writeLen = fileIo.writeSync(file.fd, (item[0] as Uint8Array).buffer);
          Logger.info(TAG, `write data to file succeed and size is: ${writeLen}`);
        } catch (err) {
          Logger.error(TAG, `Failed to save image. code: ${err.code}, message: ${err.message}`);
        } finally {
          fileIo.closeSync(file);
        }
      })
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `saveImage err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
  }
}
// [End save_iamge_to_sandbox]