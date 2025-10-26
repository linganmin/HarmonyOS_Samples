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

import { AsideColumn } from '../modules/AsideColum';
import { Crease } from '../modules/Crease';
import { Folder } from '../modules/Folder';
import { NavigationComponent } from '../modules/NavigationComponent';
import { PinchImage } from '../modules/PinchImage';
import { PinchText } from '../modules/PinchText';
import { PopupExample } from '../modules/PopupComponent';
import { FoldableScreen } from '../modules/Screen2';
import { Movie } from '../modules/Screen';
import { ScrollTest } from '../utils/source_add1';
import { NestedScroll } from '../modules/ScrollParent';
import { Web1 } from '../modules/Web';
import { display } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  // Monitor the change of folding state to obtain the current width and height of the screen
  onPageShow(): void {
    try {
      // [Start foldDisplayModeChange]
      display.on('foldDisplayModeChange', (data: display.FoldDisplayMode) => {
        let displayInfo: display.Display = display.getDefaultDisplaySync();
        if (data === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL) {
          console.info('当前屏幕状态：全屏显示');
          console.info('屏幕宽度： ' + displayInfo.width);
          console.info('屏幕高度： ' + displayInfo.height);
        } else if (data === display.FoldDisplayMode.FOLD_DISPLAY_MODE_MAIN) {
          console.info('当前屏幕状态：主屏幕显示');
          console.info('屏幕宽度： ' + displayInfo.width);
          console.info('屏幕高度： ' + displayInfo.height);
        }
      });
      // [End foldDisplayModeChange]
    } catch (err) {
      console.error(`Failed to monitor the fold display mode. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  judgeDevice() {
    // [Start judgeDevice]
    // 1. The device type is phone, and it supports folding
    try {
      if (deviceInfo.deviceType === 'phone' && display.isFoldable()) {
      }
    } catch (err) {
      console.error(`Failed to obtain the fold status of phone. Cause code: ${err.code}, message: ${err.message}`);
    }
    // 2. Judging whether the current folding state is an expanded state/folded state/semi-folded state
    try {
      if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED) {
      }
    } catch (err) {
      console.error(`Failed to obtain the fold status of phone. Cause code: ${err.code}, message: ${err.message}`);
    }
    // [End judgeDevice]
  }

  onPageHide(): void {
    try {
      display.off('foldDisplayModeChange');
    } catch (err) {
      console.error(`Failed to cancel monitoring the fold display mode. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  build() {
    Column() {
      // Folder() // 悬停
      // Crease() // 折痕区避让
      // ScrollComponent() // 沉浸浏览
      // NavigationComponent() // 分栏
      // PinchImage() // 双指缩放图片
      // PinchText() //双指缩放文本
      // PopupExample() // 跟手弹窗
      // Web1() // 折叠机展开态下文字显式问题
      // AsideColumn() // 侧边面板
      // FoldableScreen() // 横竖屏
      // Movie() // 沉浸观影
    }
    .height('100%')
    .width('100%')
  }
}