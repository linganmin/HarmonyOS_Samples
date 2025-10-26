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
export struct MusicPlayer {
  // products/default/src/main/ets/pages/MusicPlayer.ets
  context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
  private windowClass = this.context.windowStage.getMainWindowSync();
  // [StartExclude set_status_bar_content_color]
  @StorageProp('breakpoint') breakpoint: Breakpoint = 'sm';
  @State isDarkMode: boolean = false;

  getBackGroundImage() {
    return $r(`app.media.music_bg_${this.breakpoint}`);
  }

  // [EndExclude set_status_bar_content_color]
  // [Start set_status_bar_content_color]
  onShown() {
    try {
      this.windowClass.setWindowSystemBarProperties({
        statusBarContentColor: '#FFFFFF'
      });
    } catch (exception) {
      hilog.error(0x0000, 'MusicPlayer', `onShown failed. Code:${exception.code}, message:${exception.message}`);
    }
  }

  onHidden() {
    try {
      this.windowClass.setWindowSystemBarProperties({
        statusBarContentColor: '#000000'
      });
    } catch (exception) {
      hilog.error(0x0000, 'MusicPlayer', `onHidden failed. Code:${exception.code}, message:${exception.message}`);
    }
  }

  build() {
    NavDestination() {
      // [Start extend_background_image_to_safe_area_edges]
      Column() {
        // products/default/src/main/ets/pages/MusicPlayer.ets
        Image(this.getBackGroundImage())
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .objectFit(ImageFit.Fill)
      }
      .height('100%')
      .width('100%')

      // [End extend_background_image_to_safe_area_edges]
    }
    .hideTitleBar(true)
    .onShown(() => this.onShown())
    .onHidden(() => this.onHidden())
  }

  // [End set_status_bar_content_color]
}