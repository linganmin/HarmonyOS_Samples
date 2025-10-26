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

import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/Logger';
import { window } from '@kit.ArkUI';

@Builder
export function Question8CorrectBuilder() {
  Question8Correct()
}

const TAG='Question8CorrectLogTag';

// [Start Question8_correct]
@Component
export struct Question8Correct {
  private windowClass: window.Window | undefined = undefined;

  aboutToAppear(): void {
    try {
      this.windowClass=(this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync();
      this.windowClass.enableLandscapeMultiWindow().catch((error:BusinessError) => {
        Logger.error(TAG, `enableLandscapeMultiWindow err, code: ${error.code}, mesage: ${error.message}`);
      });
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `aboutToAppear err, code: ${error.code}, mesage: ${error.message}`);
    }


  }

  aboutToDisappear(): void {
    this.windowClass?.disableLandscapeMultiWindow().catch((error:BusinessError) => {
      Logger.error(TAG, `disableLandscapeMultiWindow err, code: ${error.code}, mesage: ${error.message}`);
    });
  }

  build() {
    // [StartExclude Question8_correct]
    NavDestination() {
      Column() {
        Video({ src: $rawfile('testVideo1.mp4') })
          .height('100%')
          .width('100%')
          .autoPlay(true)
          .objectFit(ImageFit.Contain)
          .controls(false)
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
    // [EndExclude Question8_correct]
  }
}
// [End Question8_correct]