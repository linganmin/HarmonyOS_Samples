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
import { display, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Breakpoint } from 'commons';

interface StatusBarMargin {
  left: number
  right: number
};

@Component
export struct MiniGame {
  // [Start enable_full_screen_mode]
  // products/default/src/main/ets/pages/MiniGame.ets
  context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
  private windowClass = this.context.windowStage.getMainWindowSync();
  // [StartExclude enable_full_screen_mode]
  @StorageProp('breakpoint') breakpoint: Breakpoint = 'sm';
  // [Start cal_side_margins_for_top_corner_buttons]
  // products/default/src/main/ets/pages/MiniGame.ets
  @State statusBarMargin: StatusBarMargin = { left: 0, right: 0 };

  // [StartExclude cal_side_margins_for_top_corner_buttons]
  getDataByBp<T>(data: Record<string, T>): T {
    return data[this.breakpoint];
  }

  onShown(): void {
    this.turnOnImmersive();
    try {
      this.setStatusBarMargin(display.getDefaultDisplaySync().width);
    } catch (exception) {
      hilog.error(0x0000, 'MiniGame', `onShown failed. Code:${exception.code}, message:${exception.message}`);
    }
    this.windowClass.on('windowSizeChange', this.onWindowSizeChange);
  }

  onHidden(): void {
    this.turnOffImmersive();
    this.windowClass.off('windowSizeChange', this.onWindowSizeChange);
  }

  onWindowSizeChange = (size: window.Size) => {
    this.setStatusBarMargin(size.width);
  }

  // [Start get_notch_cutout_dimensions_and_posion]
  // products/default/src/main/ets/pages/MiniGame.ets
  async getCutoutInfo() {
    try {
      const displayClass = display.getDefaultDisplaySync();
      const res = await displayClass.getCutoutInfo();
      return res.boundingRects;
    } catch (exception) {
      hilog.error(0x0000, 'MiniGame', `getCutoutInfo failed. Code:${exception.code}, message:${exception.message}`);
      return [];
    }
  }

  // [End get_notch_cutout_dimensions_and_posion]
  // [EndExclude cal_side_margins_for_top_corner_buttons]

  async setStatusBarMargin(windowWidth: number) {
    const cutoutInfo = await this.getCutoutInfo();
    this.statusBarMargin = this.getStatusBarMargin(cutoutInfo, windowWidth);
  }

  getStatusBarMargin(cutoutInfo: display.Rect[], windowWidth: number): StatusBarMargin {
    if (!cutoutInfo || cutoutInfo.length === 0) {
      return { left: 0, right: 0 };
    }
    const cutoutRect = cutoutInfo[0];
    const cutoutLeftGap = cutoutRect.left;
    const cutoutWidth = cutoutRect.width;
    const cutoutRightGap = windowWidth - cutoutLeftGap - cutoutWidth;
    if (Math.abs(cutoutLeftGap - cutoutRightGap) <= 10) {
      return { left: 0, right: 0 };
    }
    if (cutoutLeftGap < cutoutRightGap) {
      return { left: cutoutLeftGap + cutoutWidth, right: 0 };
    }
    return { left: 0, right: cutoutRightGap + cutoutWidth };
  }

  // [End cal_side_margins_for_top_corner_buttons]
  // [EndExclude enable_full_screen_mode]

  turnOnImmersive() {
    try {
      this.windowClass.setWindowLayoutFullScreen(true);
      this.windowClass.setWindowSystemBarEnable([]);
    } catch (exception) {
      hilog.error(0x0000, 'MiniGame', `turnOnImmersive failed. Code:${exception.code}, message:${exception.message}`);
    }
  }

  // [End enable_full_screen_mode]

  turnOffImmersive() {
    try {
      this.windowClass.setWindowLayoutFullScreen(false);
      this.windowClass.setWindowSystemBarEnable(['status', 'navigation']);
    } catch (exception) {
      hilog.error(0x0000, 'MiniGame', `turnOffImmersive failed. Code:${exception.code}, message:${exception.message}`);
    }
  }

  getBirdImages(count: number) {
    const colors = ['blue', 'green', 'purple', 'red', 'white', 'yellow'];
    return Array.from({ length: count }, (_: undefined, index) => {
      const color = colors[index % colors.length];
      return $r(`app.media.game_bird_${color}`);
    });
  }

  build() {
    NavDestination() {
      Column() {
        // [Start define_horizontal_spacing_for_header_buttons]
        // products/default/src/main/ets/pages/MiniGame.ets
        Row() {
          Image($r('app.media.game_props'))
            .width(80)
            .margin({ left: this.statusBarMargin.left + 'px' })
          Blank()
          Image($r('app.media.game_pause'))
            .width(48)
            .margin({ right: this.statusBarMargin.right + 'px' })
        }
        // [End define_horizontal_spacing_for_header_buttons]
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Column() {
          Grid() {
            ForEach(this.getBirdImages(32), (image: Resource) => {
              GridItem() {
                Image(image)
                  .width('100%')
                  .height('100%')
              }
              .aspectRatio(1)
              .backgroundColor('rgba(13, 89, 247, 0.30)')
              .borderColor('#327AF7')
              .borderWidth(2)
              .borderRadius(4)
              .padding(10)
              .margin(5)
            }, (image: Resource, index) => JSON.stringify(image) + index)
          }
          .scrollBar(BarState.Off)
          .columnsTemplate('1fr '.repeat(this.getDataByBp({ 'sm': 4, 'md': 5 })))
        }
        .layoutWeight(1)

        Row() {
          Image($r('app.media.game_step'))
            .width(100)
          Blank()
          Image($r('app.media.game_target'))
            .width(100)
        }
        .width('100%')
      }
      .height('100%')
      .width('100%')
      .backgroundImage($r('app.media.game_background'))
      .backgroundImageSize(ImageSize.FILL)
      .padding(10)
    }
    .hideTitleBar(true)
    .onShown(() => this.onShown())
    .onHidden(() => this.onHidden())
  }
}