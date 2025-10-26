/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

/*
* 最佳实践: 一多窗口适配开发实践
*/

// [Start onWindowStageCreate]
import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import hilog from '@ohos.hilog';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage) {
    // [StartExclude onWindowStageCreate]
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
    // [EndExclude onWindowStageCreate]
    let windowClass: window.Window | null = null;
    windowStage.getMainWindow()
      .then((data: window.Window) => {
        windowClass = data;
        if (deviceInfo.deviceType !== '2in1') {
          windowClass.setWindowLayoutFullScreen(true)
            .catch((err: BusinessError) => {
              hilog.error(0x000, 'testTag',
                `setWindowLayoutFullScreen failed, code: ${err.code}, message: ${err.message}`)
            })
        }
      })
      .catch((err: BusinessError) => {
        hilog.error(0x000, 'testTag', `getMainWindow failed, code: ${err.code}, message: ${err.message}`)
      })
  }
}

// [End onWindowStageCreate]