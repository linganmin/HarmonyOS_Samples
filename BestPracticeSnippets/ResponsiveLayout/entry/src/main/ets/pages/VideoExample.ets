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

import { display, window } from '@kit.ArkUI';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { KeyCode } from '@kit.InputKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { WindowUtil } from '../utils/WindowUtil';
import { AvPlayerUtil } from '../utils/AvPlayerUtil'
import { BreakpointType } from '../utils/BreakpointType';
import { BreakpointConstants } from '../constants/BreakpointConstants'

@Component
export struct VideoExample {
  @State scrollHeight: number = 0;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'lg';
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: string = 'lg';
  @StorageLink('isFullScreen') isFullScreen: boolean = false;
  @StorageLink('isHalfFolded') isHalfFolded: boolean = false;
  private mainWindowClass?: window.Window;
  private windowUtil?: WindowUtil = WindowUtil.getInstance();
  private avPlayerUtil?: AvPlayerUtil;
  private xComponentController: XComponentController = new XComponentController();

  aboutToAppear(): void {
    // [Start dd_judgment_of]
    // Judgment of the horizontal window. (The actual application may need to be combined with other conditions, for example, determine the horizontal breakpoint)
    if (this.currentHeightBreakpoint === 'sm' && this.currentWidthBreakpoint === 'md') {
      // Horizontal window page layout.
    }
    // Judgment of the square window. (The actual use may need to be combined with other conditions, such as determining horizontal breakpoints)
    if (this.currentHeightBreakpoint === 'md' && this.currentWidthBreakpoint === 'sm') {
      // Square-like window page layout.
    }
    // [End dd_judgment_of]

    // [Start dd_set_preferred_orientation]
    let currentHeightBreakpoint: string | undefined = AppStorage.get('currentHeightBreakpoint');
    if (currentHeightBreakpoint === 'md') {
      this.mainWindowClass?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED).catch((error: BusinessError) => {
        hilog.error(0x0000, 'VideoExample',
          `setPreferredOrientation failed. code=${error.code}, message = ${error.message}`);
      });
    }
    // [End dd_set_preferred_orientation]
    // [Start dd_isfullscreen]
    if (this.isFullScreen) {
      if (deviceInfo.deviceType !== '2in1') {
        this.windowUtil!.disableWindowSystemBar();
      }
      try {
        if ((!display.isFoldable() && deviceInfo.deviceType === 'phone') ||
          display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED) {
          this.windowUtil!.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE);
        }
        if (display.isFoldable()) {
          if (this.isHalfFolded) {
            this.windowUtil!.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE);
          }
        }
      } catch (error) {
        let err = error as BusinessError
        hilog.error(0x0000, 'VideoExample',
          `setMainWindowOrientation failed. code=${err.code}, message = ${err.message}`);
      }
    }
    // [End dd_isfullscreen]
  }

  build() {
    Column() {
      // [Start dd_break_point_type_getValue]
      Text('Test')
        .fontSize(new BreakpointType('14fp', '16fp', '18fp').getValue(this.currentWidthBreakpoint))
      // [End dd_break_point_type_getValue]

      // [Start jh_xcomponent]
      XComponent({ id: '', type: 'surface', controller: this.xComponentController })
        .onKeyEvent((event?: KeyEvent) => {
          // If the button type is pressed, the subsequent code will not be executed; the specific button logic will be executed upon release.
          if (!event || event.type !== KeyType.Down) {
            return;
          }
          // Space key controls pause/play
          if (event.keyCode === KeyCode.KEYCODE_SPACE) {
            this.avPlayerUtil!.playerStateControl();
          }
          // ESC key exits full screen
          if (event.keyCode === KeyCode.KEYCODE_ESCAPE) {
            this.windowUtil!.recover();
          }
          // Right-click to fast forward
          if (event.keyCode === KeyCode.KEYCODE_DPAD_RIGHT) {
            this.avPlayerUtil!.fastForward();
          }
          // Left-click to rewind
          if (event.keyCode === KeyCode.KEYCODE_DPAD_LEFT) {
            this.avPlayerUtil!.rewind();
          }
        })
      // [End jh_xcomponent]
    }
  }

  // [Start on_full_screen_change]
  // [Start dd_on_full_screen_change]
  // entry/src/main/ets/page/VideoExample.ets
  private onFullScreenChange(): void {
    // Large folding screen (X series) in unfolded state and tablet state, supporting rotation && large folding screen (X series) in hover state requires landscape display and does not support rotation.
    if (((this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_MD && this.currentHeightBreakpoint !==
    BreakpointConstants.BREAKPOINT_SM) || this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_LG) &&
      !this.isHalfFolded) {
      this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
    }
    // Phone and large folding screen (X series) in portrait mode.
    else if (this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_SM && this.currentHeightBreakpoint ===
    BreakpointConstants.BREAKPOINT_LG) {
      // In full-screen mode, the layout is displayed in landscape mode. Otherwise, the layout is displayed in portrait mode.
      if (this.isFullScreen) {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
      } else {
        this.windowUtil?.setMainWindowOrientation(window.Orientation.PORTRAIT);
      }
    }
    // When the mobile phone and large folding screen (X series) are folded in landscape mode and the playback is not in full screen mode, the vertical display layout is displayed.
    else if (this.currentWidthBreakpoint === BreakpointConstants.BREAKPOINT_MD && this.currentHeightBreakpoint ===
    BreakpointConstants.BREAKPOINT_SM && !this.isFullScreen) {
      this.windowUtil?.setMainWindowOrientation(window.Orientation.PORTRAIT);
    }
    // The navigation bar is not hidden on a 2in1 device.
    if (deviceInfo.deviceType !== '2in1') {
      // The navigation bar is hidden in full-screen playback. Otherwise, the navigation bar is displayed.
      if (this.isFullScreen) {
        this.windowUtil!.disableWindowSystemBar();
      } else {
        this.windowUtil!.enableWindowSystemBar();
      }
    }
  }
}

// [End dd_on_full_screen_change]
// [End on_full_screen_change]