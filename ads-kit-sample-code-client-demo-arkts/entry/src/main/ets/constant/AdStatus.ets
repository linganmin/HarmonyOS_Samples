/*
 * Copyright 2023. Huawei Technologies Co., Ltd. All rights reserved.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

export enum AdStatus {
  AD_OPEN = 'onAdOpen',
  AD_CLOSED = 'onAdClose',
  AD_CLICKED = 'onAdClick',
  AD_LOAD = 'onAdLoad',
  AD_FAIL = 'onAdFail',
  AD_REWARDED = 'onAdReward',
  VIDEO_PLAY_BEGIN = 'onVideoPlayBegin',
  VIDEO_PLAY_END = 'onVideoPlayEnd',
  MEDIA_PROGRESS = 'onMediaProgress',
  MEDIA_START = 'onMediaStart',
  MEDIA_PAUSE = 'onMediaPause',
  MEDIA_STOP = 'onMediaStop',
  MEDIA_COMPLETE = 'onMediaComplete',
  MEDIA_ERROR = 'onMediaError',
  MEDIA_COUNTDOWN = 'onMediaCountdown',
  LANDSCAPE = 'onLandscape',
  PORTRAIT = 'onPortrait',
  BACK_CLICKED = 'onBackClicked',
}