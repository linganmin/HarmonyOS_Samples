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

// [Start onwindowstagecreate1]
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
    windowStage.getMainWindow().then((data: window.Window) => {
      let deviceTypeInfo: string = deviceInfo.deviceType;
      if (deviceTypeInfo === '2in1') {
        try {
          // Set the title bar of the 2in1 device to be invisible after the loadContent() call takes effect.
          data.setWindowDecorVisible(false);
          // When the title bar is invisible, set the height of the title bar and control the height of the three buttons (full screen/restore, maximize, and close) in the upper right corner.
          data.setWindowDecorHeight(64);
        } catch (error) {
          let err = error as BusinessError;
          hilog.warn(0x000, 'testTag', `set windowDecor size failed, code=${err.code}, message=${err.message}`);
        }
      }
    }).catch((err: BusinessError) => {
      hilog.error(0x000, 'testTag', `setWindowLayoutFullScreen failed, code=${err.code}, message=${err.message}`)
    })
  }
}

// [End onwindowstagecreate1]