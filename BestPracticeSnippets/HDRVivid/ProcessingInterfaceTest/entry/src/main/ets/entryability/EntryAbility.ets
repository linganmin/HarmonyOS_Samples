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

import { abilityAccessCtrl, AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalContext } from '../utils/GlobalContext';
import Logger from '../utils/Logger';
import { WindowUtil } from '../utils/WindowUtil';

export default class EntryAbility extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        GlobalContext.getContext().setObject('context', this.context)
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    }

    onDestroy(): void {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    }

    onWindowStageCreate(windowStage: window.WindowStage): void {
        // Main window is created, set main page for this ability
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
        try {
            let atManager = abilityAccessCtrl.createAtManager();
            atManager.requestPermissionsFromUser(this.context, ['ohos.permission.WRITE_MEDIA','ohos.permission.READ_MEDIA'])
                .then((data) => {
                    Logger.info('Entry', 'requestPre() data: ' + JSON.stringify(data));
                }).catch((err: BusinessError) => {
                Logger.info('Entry', 'requestPre() data: ' + JSON.stringify(err));
            })
        } catch (err) {
            Logger.error('Entry', 'requestPre() data: ' + JSON.stringify(err));
        }
        let windowUtil: WindowUtil | undefined = WindowUtil.getInstance();
        if (windowUtil !== undefined) {
            windowUtil.setWindowStage(windowStage);
            windowUtil.setMainWindowPortrait();
        }

        windowStage.loadContent('pages/Index', (err) => {
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
};
