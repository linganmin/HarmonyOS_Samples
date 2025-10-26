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

import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;
const TAG = 'UserDetails';

@Entry
@Component
struct UserDetails {
  context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
  private windowClass = this.context.windowStage;

  aboutToAppear(): void {
    try {
      this.windowClass.getMainWindowSync()
        .setWindowLayoutFullScreen(true)
        .then(() => {
          this.windowClass.getMainWindowSync().setWindowSystemBarEnable([]).catch((error: BusinessError) => {
            hilog.error(DOMAIN, TAG, `setWindowSystemBarEnable error code:${error.code},message:${error.message}`);
          });
        })
        .catch((error: BusinessError) => {
          hilog.error(DOMAIN, TAG, `setWindowLayoutFullScreen error code:${error.code},message:${error.message}`);
        });

    } catch (error) {
      let err = error as BusinessError;
      hilog.error(DOMAIN, TAG, `aboutToAppear Failed,code:${err.code};message:${err.message}`);
    }
  }

  aboutToDisappear(): void {
    try {
      this.windowClass.getMainWindowSync()
        .setWindowLayoutFullScreen(false)
        .then(() => {
          this.windowClass.getMainWindowSync()
            .setWindowSystemBarEnable(['status', 'navigation'])
            .catch((error: BusinessError) => {
              hilog.error(DOMAIN, TAG, `setWindowSystemBarEnable error code:${error.code},message:${error.message}`);
            });
        })
        .catch((error: BusinessError) => {
          hilog.error(DOMAIN, TAG, `setWindowLayoutFullScreen error code:${error.code},message:${error.message}`);
        });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(DOMAIN, TAG, `aboutToDisappear Failed,code:${err.code};message:${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.user_info'))
          .width('100%')
          .height('100%')
      }
      .height('100%')
      .width('100%')
    }
  }
}