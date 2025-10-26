/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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
import { Breakpoint } from 'commons';

@Component
export struct VideoPlayer {
  // [Start control_system_ui_visibility]
  // products/default/src/main/ets/pages/VideoPlayer.ets
  context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
  private windowClass = this.context.windowStage.getMainWindowSync();
  // [StartExclude control_system_ui_visibility]
  @StorageProp('breakpoint') breakpoint: Breakpoint = 'sm';

  getDataByBp<T>(data: Record<string, T>): T {
    return data[this.breakpoint];
  }

  // [EndExclude control_system_ui_visibility]

  onShown() {
    try {
      this.windowClass.setWindowLayoutFullScreen(true);
      this.windowClass.setWindowSystemBarEnable([]);
    } catch (exception) {
      hilog.error(0x0000, 'VideoPlayer', `onShown failed. Code:${exception.code}, message:${exception.message}`);
    }
  }

  onHidden() {
    try {
      this.windowClass.setWindowLayoutFullScreen(false);
      this.windowClass.setWindowSystemBarEnable(['status', 'navigation']);
    } catch (exception) {
      hilog.error(0x0000, 'VideoPlayer', `onHidden failed. Code:${exception.code}, message:${exception.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Video({ src: $rawfile('video.mp4') })
        // [StartExclude control_system_ui_visibility]
          .height('100%')
          .width('100%')
          .autoPlay(true)
          .objectFit(this.getDataByBp({ 'sm': ImageFit.Cover, 'md': ImageFit.Contain }))
          .controls(false)
        // [EndExclude control_system_ui_visibility]
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
    .onShown(() => this.onShown())
    .onHidden(() => this.onHidden())
  }

  // [End control_system_ui_visibility]
}