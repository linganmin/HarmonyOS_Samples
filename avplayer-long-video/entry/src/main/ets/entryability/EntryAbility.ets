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

import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { WindowUtil } from '../common/utils/WindowUtil';

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    AppStorage.setOrCreate('context', this.context);
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      WindowUtil.getInstance().setWindowStage(windowStage);
      AppStorage.setOrCreate('windowStage', windowStage);
      windowClass.setWindowLayoutFullScreen(true).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', `createAVSession failed, code is ${err.code}, message is ${err.message}`);
      });
      windowClass.setWindowSystemBarProperties({
        statusBarContentColor: '#e6ffffff'
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', `createAVSession failed, code is ${err.code}, message is ${err.message}`);
      });
      windowStage.loadContent('pages/IndexPage', (err: BusinessError) => {
        AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
        if (err.code) {
          hilog.error(0x0000, 'testTag', `Failed to load the content. code is ${err.code}, message is ${err.message}`);
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      });
    } catch (exception) {
      hilog.error(0x0000, 'testTag',
        `onWindowStageCreate failed, Code:${exception.code}, message:${exception.message}`);
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
