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

import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { JSON } from '@kit.ArkTS';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

// [Start handle_parameters]
export default class EntryAbility extends UIAbility {
  handleParameters(want: Want) {
    let uri = want.uri;
    if (uri) {
      hilog.info(0x0000, 'Sample', '%{public}s', uri); // Print "https://appgallery.huawei.com/app/detail?id=com.huawei.hmsapp.books"
      const urlObject = url.URL.parseURL(uri); // Parse the urlObject from the uri for convenient parameter acquisition.
      const params = urlObject.params; // Obtain parameters from the urlObject.
      const id = params.get('id'); // Obtain the parameter id in the uri. After execution, the id is com.huawei.hmsapp.books.
      hilog.info(0x0000, 'Sample', '%{public}s', id) // Print "com.huawei.hmsapp.books"
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handleParameters(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handleParameters(want);
  }
// [End handle_parameters]

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    let sysBarProps: window.SystemBarProperties = {
      statusBarColor: '#FFFFFF',
      navigationBarColor: '#F1F3F5',
      statusBarContentColor: '#FF000000',
      navigationBarContentColor: '#FF000000'
    };

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
// [Start handle_parameters]
}
// [End handle_parameters]