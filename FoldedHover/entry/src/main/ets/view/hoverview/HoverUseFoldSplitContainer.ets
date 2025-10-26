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

import { ExpandedRegionLayoutOptions, FoldSplitContainer } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AVPlayerUtil } from '../../common/utils/AVPlayerUtil';
import { WindowUtil } from '../../common/utils/WindowUtil';
import { VideoPlayView } from '../basicview/VideoPlayView';
import { OperationView } from '../basicview/OperationView';
import { CommonConstants as Const } from '../../common/CommonConstants';

const TAG: string = 'FoldSplitContainer';

@Component
export struct HoveringUsingFoldSplitContainer {
  @StorageLink('progress') progress: number = 0;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = Const.BREAKPOINT_LG;
  @StorageLink('currentHeightBreakpoint') currentHeightBreakpoint: string = Const.BREAKPOINT_LG;
  @StorageLink('pageID') pageID: number = 2;
  @StorageLink('reOnFoldStatusChange') reOnFoldStatusChange: boolean = AppStorage.get<boolean>('reOnFoldStatusChange')!;
  @State expandRegionLayoutOptions: ExpandedRegionLayoutOptions = {};
  private windowUtil?: WindowUtil;
  private avPlayerUtil?: AVPlayerUtil;

  aboutToAppear() {
    this.avPlayerUtil = AVPlayerUtil.getInstance();
    this.windowUtil = WindowUtil.getInstance();
  }

  aboutToDisappear(): void {
    this.reOnFoldStatusChange = !this.reOnFoldStatusChange;
  }

  @Builder
  primaryArea() {
    VideoPlayView({ avPlayerUtil: this.avPlayerUtil })
  }

  @Builder
  secondaryArea() {
    OperationView()
  }

  build() {
    NavDestination() {
      // [Start fold_split_container]
      FoldSplitContainer({
        primary: () => {
          this.primaryArea();
        },
        secondary: () => {
          this.secondaryArea();
        }
      })
        // [End fold_split_container]
        .backgroundColor(Color.Black)
        .height('100%')
        .width('100%')
    }
    .hideTitleBar(true)
    .onAppear(() => {
      this.pageID = 2;
      if (this.windowUtil === undefined) {
        return;
      }
      this.windowUtil.disableWindowSystemBar();
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
      } else {
        hilog.info(0x0000, TAG, `Normal return in portrait mode`);
      }
      this.pageID = 0;
      this.avPlayerUtil?.resetAVPlayer();
      this.progress = 0;
    })
  }
}