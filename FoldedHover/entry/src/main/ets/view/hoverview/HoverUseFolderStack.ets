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

import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AVPlayerUtil } from '../../common/utils/AVPlayerUtil';
import { WindowUtil } from '../../common/utils/WindowUtil';
import { VideoControlView } from '../basicview/VideoControlView';
import { VideoPlayView } from '../basicview/VideoPlayView';
import { BackTitleView } from '../basicview/BackTitleView';
import { CommonConstants as Const } from '../../common/CommonConstants';

const TAG: string = 'FolderStack';

@Component
export struct HoveringUsingFolderStack {
  @StorageLink('progress') progress: number = 0;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = Const.BREAKPOINT_LG;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: string = Const.BREAKPOINT_LG;
  @StorageLink('pageID') pageID: number = 1;
  private windowUtil?: WindowUtil;
  private avPlayerUtil?: AVPlayerUtil;

  aboutToAppear() {
    this.avPlayerUtil = AVPlayerUtil.getInstance();
    this.windowUtil = WindowUtil.getInstance();
  }

  build() {
    NavDestination() {
      // [Start folder_stack]
      FolderStack({ upperItems: ['upper'] }) {
        VideoPlayView({ avPlayerUtil: this.avPlayerUtil })
          .id('upper')

        VideoControlView({ avPlayerUtil: this.avPlayerUtil })

        BackTitleView({
          title: Const.PAGE_TITLES[0]
        })
      }
      // [End folder_stack]
      .alignContent(Alignment.Center)
      .backgroundColor(Color.Black)
      .height('100%')
      .width('100%')
    }
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .onAppear(() => {
      this.pageID = 1;
      if (this.windowUtil === undefined) {
        return;
      }
      this.windowUtil.disableWindowSystemBar();
      if (this.currentHeightBreakpoint === 'md' && this.currentWidthBreakpoint === 'md') {
        this.windowUtil.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
      } else {
        this.windowUtil.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED);
      }
    })
    .onShown(() => {
      this.avPlayerUtil?.playerStateControl();
    })
    .onHidden(() => {
      this.avPlayerUtil?.pauseAVPlayer();
    })
    .onWillDisappear(() => {
      if (this.windowUtil !== undefined) {
        this.windowUtil.enableWindowSystemBar();
        if (this.currentHeightBreakpoint !== 'md' || this.currentWidthBreakpoint !== 'md') {
          this.windowUtil.setMainWindowOrientation(window.Orientation.PORTRAIT);
        } else {
          this.windowUtil.setMainWindowOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED);
        }
      } else {
        hilog.info(0x0000, TAG, `Normal return in portrait mode`);
      }
      this.pageID = 0;
      this.avPlayerUtil?.resetAVPlayer();
      this.progress = 0;
    })
  }
}