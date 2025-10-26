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
import { window } from '@kit.ArkUI';
import { CommonConstants } from '../common/CommonConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';
import { DataUtils } from './DataUtils';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

export class UIUtils {
  public static readonly tag: string = 'UIUtils';

  static setWindowBackGroundColor(context: Context, color: string) {
    window.getLastWindow(context).then(windowStage => {
      windowStage.setWindowBackgroundColor(color);
    });
  }

  static setWindowFullScreen(context: Context, isFull: boolean) {
    window.getLastWindow(context).then(windowStage => {
      windowStage.setWindowLayoutFullScreen(isFull);
    });
  }

  static setWindowSystemBarVisible(context: Context, names: string[]) {
    window.getLastWindow(context).then(windowStage => {
      windowStage.setWindowSystemBarEnable(names as ('status' | 'navigation')[]);
    });
  }

  /**
   * show system picker view
   *
   * @param uiContext
   * @param selectedNum
   * @param callback
   */
  static showPickerView(uiContext: UIContext, selectedNum: number, callback: Function) {
    if (selectedNum >= CommonConstants.LIMIT_PICKER_NUM) {
      uiContext.getPromptAction().showToast({
        message: $r('app.string.toast_picker_limit'),
        duration: DataUtils.fromResToNumber($r('app.float.show_DELAY_TIME')),
      });
      return;
    }
    // [Start photo_select_options]
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = CommonConstants.LIMIT_PICKER_NUM - selectedNum;
    // [End photo_select_options]
    // [Start photo_view_picker]
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    // [End photo_view_picker]
    // [Start select]
    photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      let uriArr = photoSelectResult.photoUris;
      callback(uriArr);
    }).catch((err: BusinessError) => {
      Logger.error(UIUtils.tag,
        `Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
    });
    // [End select]
  }
}