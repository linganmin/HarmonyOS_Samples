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

import { CustomButton } from '../components/CustomButton';
import { abilityAccessCtrl, Permissions, common, Want } from '@kit.AbilityKit';
import Logger from '../commonutils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'indexPage';

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();
  context: common.UIAbilityContext = AppStorage.get('entryAbilityContext') as common.UIAbilityContext;

  aboutToAppear() {
    const array: Permissions[] = ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE'];
    const atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(AppStorage.get<common.UIAbilityContext>('entryAbilityContext'), array);
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: 12 }) {
        CustomButton({
          buttonName: $r('app.string.Video_file_scene'),
          buttonOnClick: () => {
            let wantInfo: Want = {
              deviceId: '',
              bundleName: 'com.sample.video_watermark',
              moduleName: 'entry',
              abilityName: 'VideoFileAbility'
            };

            this.context.startAbility(wantInfo).then(() => {
              Logger.info(TAG, 'start videoFileAbility success.');
            }).catch((error: BusinessError) => {
              Logger.info(TAG, `start videoFileAbility failed. error message is ${error.message}`);
            });
          }
        })

        CustomButton({
          buttonName: $r('app.string.Camera_record_scene'),
          buttonOnClick: () => {
            let wantInfo: Want = {
              deviceId: '',
              bundleName: 'com.sample.video_watermark',
              moduleName: 'entry',
              abilityName: 'CameraAbility'
            };

            this.context.startAbility(wantInfo).then(() => {
              Logger.info(TAG, 'start cameraAbility success.');
            }).catch((error: BusinessError) => {
              Logger.info(TAG, `start cameraAbility failed. error message is ${error.message}`);
            });
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
      .justifyContent(FlexAlign.End)
    }
    .title($r('app.string.Demo_tile'))
  }
}
