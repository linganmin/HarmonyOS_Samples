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

import { AVPlayerConstants, NetConstants, ViewConstants } from '../common/CommonConstants';
import { CustomConfigs } from '../common/CustomConfigs';
import { NetInfoModel } from '../model/NetInfoModel';
import { VideoInfoModel } from '../model/VideoInfoModel';
import { AVPlayerController } from '../viewmodel/AVPlayerController';
import { NetInfoViewModel } from '../viewmodel/NetInfoViewModel';

@Extend(Text) function infoStyle () {
  .fontSize($r('app.float.info_font_size'))
  .fontWeight(FontWeight.Normal)
  .height($r('app.float.info_single_height'))
}

@Component
export struct VideoPlayInfo {
  @ObjectLink hlsPlayerController: AVPlayerController;
  @ObjectLink netInfoViewModel: NetInfoViewModel;
  @State showPopup: boolean = false;

  @Builder
  customPopupBuilder() {
    Scroll() {
      Column() {
        VideoInfo({ videoInfo: this.hlsPlayerController.videoInfo })
        ForEach(this.netInfoViewModel.netInfoList, (item: NetInfoModel) => {
          if (CustomConfigs.SELECTABLE_NET_PATH.find((value) => value === item.pathType) !== undefined) {
            NetInfo({ netInfo: item })
          }
        }, (item: NetInfoModel) => NetConstants.NET_PATH_TYPES[item.pathType])
      }
      .alignItems(HorizontalAlign.Start)
      .margin({
        right: $r('app.float.information_margin')
      })
    }
    .scrollBar(BarState.Auto)
    .align(Alignment.Start)
    .margin({
      top: $r('app.float.information_margin'),
      bottom: $r('app.float.information_margin'),
      left: $r('app.float.information_margin'),
      right: $r('app.float.information_margin')
    })
    .width('auto')
    .height($r('app.float.info_height'))
  }

  build() {
    Row() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .fillColor(Color.White)
          .width($r('app.float.arrow_icon_width'))
          .height($r('app.float.arrow_icon_height'))
          .margin({
            top: $r('app.float.arrow_icon_margin'),
            bottom: $r('app.float.arrow_icon_margin'),
            left: $r('app.float.arrow_icon_margin'),
            right: $r('app.float.arrow_icon_margin')
          })

        Text($r('app.string.full_screen_playback'))
          .fontColor(Color.White)
          .fontSize($r('app.float.full_screen_playback_font_size'))
          .fontWeight(FontWeight.Bold)
          .margin({
            left: $r('app.float.full_screen_font_margin_left')
          })
      }

      Image($r('app.media.net_icon'))
        .width($r('app.float.info_icon_width'))
        .height($r('app.float.info_icon_height'))
        .onClick(() => {
          this.showPopup = !this.showPopup;
        })
        .bindPopup(this.showPopup, {
          builder: this.customPopupBuilder(),
          placement: Placement.Bottom,
          autoCancel: false,
          mask: false
        })
    }
    .width(ViewConstants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Component
struct VideoInfo {
  @ObjectLink videoInfo: VideoInfoModel;

  build() {
    Column() {
      Text($r('app.string.video_buffer_info_type',
        `: ${AVPlayerConstants.BUFFER_INFO_TYPES[this.videoInfo.currentBufferInfoType - 1]}`)).infoStyle()
      Text($r('app.string.video_buffer_info_value', `: ${this.videoInfo.currentBufferInfoValue}`)).infoStyle()
      Text($r('app.string.video_avg_down_rate', `: ${this.videoInfo.averageDownloadRate} bps`)).infoStyle()
      Text($r('app.string.video_down_rate', `: ${this.videoInfo.downloadRate} bps`)).infoStyle()
    }
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
struct NetInfo {
  @ObjectLink netInfo: NetInfoModel;

  build() {
    Column() {
      Text($r('app.string.path_type', `: ${NetConstants.NET_PATH_TYPES[this.netInfo.pathType]}`)).infoStyle()
      Text($r('app.string.down_band_width', `: ${this.netInfo.qosDownBandWidth} bps`)).infoStyle()
      Text($r('app.string.down_rate', `: ${this.netInfo.qosDownRate} bps`)).infoStyle()
      Text($r('app.string.rtt_ms', `: ${this.netInfo.qosRttMs} ms`)).infoStyle()
      Text($r('app.string.scene', `: ${this.netInfo.scene}`)).infoStyle()
      Text($r('app.string.recommended_action', `: ${this.netInfo.recommendedAction}`)).infoStyle()
    }
    .alignItems(HorizontalAlign.Start)
  }
}