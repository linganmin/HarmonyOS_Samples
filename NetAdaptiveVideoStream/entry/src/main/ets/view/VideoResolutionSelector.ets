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

import { LengthMetrics } from '@kit.ArkUI';
import { ViewConstants } from '../common/CommonConstants';
import { CustomConfigs } from '../common/CustomConfigs';
import { customToast } from '../common/utils/CommonUtils';
import { AVPlayerController } from '../viewmodel/AVPlayerController';

@Component
export struct VideoResolutionSelector {
  @ObjectLink hlsPlayerController: AVPlayerController;

  /**
   * Get resolution name according to custom config
   * @param index
   * @returns custom resolution name if custom name list is longer than bitrate list, or bitrate if not
   */
  private getResolutionName(index: number) {
    if (this.hlsPlayerController.bitrateList.length > CustomConfigs.SELECTABLE_RESOLUTIONS.size) {
      return this.hlsPlayerController.bitrateList[index].toString();
    } else {
      return Array.from(CustomConfigs.SELECTABLE_RESOLUTIONS.values())[index];
    }
  }

  @Builder
  ResolutionMenu() {
    Menu() {
      ForEach(this.hlsPlayerController.bitrateList, (item: number, index: number) => {
        MenuItem({ content: this.getResolutionName(index) })
          .contentFont({
            size: $r('app.float.resolution_font_size'),
            weight: FontWeight.Medium
          })
          .width($r('app.float.resolution_item_width'))
          .height($r('app.float.resolution_item_height'))
          .onClick(() => {
            this.hlsPlayerController.setBitrate(item);
            customToast($r('app.string.manual_bitrate'), ViewConstants.TOAST_TIME_MS);
          })
      }, (item: number) => item.toString())
    }
    .menuItemDivider({
      strokeWidth: new LengthMetrics(ViewConstants.DIVIDER_STROKE_WIDTH),
      color: $r('app.color.divider_color'),
      startMargin: new LengthMetrics(0),
      endMargin: new LengthMetrics(0)
    })
  }

  build() {
    Text(this.hlsPlayerController.currentResolutionIndex === undefined ?
      $r('app.string.auto_resolution') : this.getResolutionName(this.hlsPlayerController.currentResolutionIndex) )
      .fontColor(Color.White)
      .fontSize($r("app.float.resolution_selector_size"))
      .bindMenu(this.ResolutionMenu())
  }
}