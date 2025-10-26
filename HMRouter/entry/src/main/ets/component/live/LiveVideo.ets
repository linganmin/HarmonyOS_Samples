/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { HMRouterMgr } from '@hadss/hmrouter';
import { CommonConstants } from '../common/constants/CommonConstants';
import { LiveHomeLifecycle, VideoSrc } from './LiveHome';

@Component
export struct LiveVideo {
  @StorageLink('changeVideoHeight') videoHeight: string | number = CommonConstants.FULL_PERCENT;
  @State VideoSrc: VideoSrc = (HMRouterMgr.getCurrentLifecycleOwner()?.getLifecycle() as LiveHomeLifecycle).videoSrc;
  @State curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X;
  controller: VideoController = new VideoController();

  build() {
    Column() {
      Video({
        src: this.VideoSrc.src,
        currentProgressRate: this.curRate,
        controller: this.controller
      })
        .width('100%')
        .height(this.videoHeight)
        .animation({duration: 500})
        .objectFit(ImageFit.Contain)
        .autoPlay(true)
        .controls(false)
        .loop(true);
    }
    .margin({top: 50})
    .width('100%')
    .height('100%');
  }
}