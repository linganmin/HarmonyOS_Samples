/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { abilityAccessCtrl, Context, Permissions } from '@kit.AbilityKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

class PermissionUtils {
  public showToast(message: ResourceStr, uiContext: UIContext) {
    try {
      uiContext.getPromptAction().showToast({ message });
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'AuthorizationTools', `AuthorizationTools error: ${error.code}  msg:${error.message}`);
    }
  };

  /**
   * Obtain relevant permissions.
   * @param context Application Context.
   * @param permission Required permissions.
   * @param uiContext UI Context.
   * @returns Authorization approval result.
   */
  public async getPermission(context: Context, permission: Permissions, uiContext: UIContext): Promise<boolean> {
    try {
      let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();

      const result = await atManager.requestPermissionsFromUser(context, [permission]);

      if (result.authResults[0] !== -1) {
        this.showToast($r('app.string.authorized'), uiContext);
        return true;
      }

      const resultAgain = await atManager.requestPermissionOnSetting(context, [permission]);
      if (resultAgain[0] === 0) {
        this.showToast($r('app.string.authorization_successful'), uiContext);
        return true;
      }

      this.showToast($r('app.string.reauthorization'), uiContext);
      return false;
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'getPermission', `getPermission error: ${error.code}  msg:${error.message}`);
      return false;
    }
  };

  /**
   * The sandbox path for obtaining images.
   * @param pixelMap PixelMap format image.
   * @param context Application Context.
   * @returns Return to sandbox path.
   */
  async getSandboxPath(pixelMap: PixelMap, context: Context): Promise<string> {
    // Get the application file path
    let filesDir: string = context.cacheDir;
    let picName = '/tempImage' + new Date().getTime() + '.jpg';
    try {
      // Create and open a file
      let file = fs.openSync(filesDir + picName, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      // Create an ImagePacker object for image encoding
      const imagePackerApi = image.createImagePacker();
      // Set the encoding output stream and encoding parameters. Format is the encoding format of the image;
      // Quality refers to the image quality, ranging from 0 to 100, with 100 being the optimal quality
      const options: image.PackingOption = { format: 'image/jpeg', quality: 98 };
      try {
        await imagePackerApi.packToFile(pixelMap, file.fd, options);
      } catch (err) {
        let error = err as BusinessError;
        hilog.error(0x0000, 'AuthorizationTools', `AuthorizationTools error: ${error.code}  msg:${error.message}`);
      }
      return file.path;
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'getSandboxPath', `getSandboxPath error: ${error.code}  msg:${error.message}`);
      return filesDir;
    }
  };
}

export default new PermissionUtils();
