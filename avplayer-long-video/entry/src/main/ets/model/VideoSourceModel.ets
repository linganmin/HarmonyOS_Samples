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

import { VideoData } from '../model/VideoData';
import { VideoDataType } from '../common/constants/CommonConstants';

export const SOURCES: VideoData[] = [
  {
    type: VideoDataType.RAW_FILE,
    videoSrc: 'video_sample_product.mp4',
    name: 'rain',
    description: $r('app.string.video_description3'),
    head: $r('app.media.preview1'),
    caption: 'captions.srt',
    index: 0
  },
  {
    type: VideoDataType.RAW_FILE,
    videoSrc: 'video_sample3.mp4',
    name: 'mountain',
    description: $r('app.string.video_description0'),
    head: $r('app.media.preview6'),
    caption: 'captions.srt',
    index: 1
  },
  {
    type: VideoDataType.RAW_FILE,
    videoSrc: 'video_sample2.mp4',
    name: 'climber',
    description: $r('app.string.video_description1'),
    head: $r('app.media.preview4'),
    caption: 'captions.srt',
    index: 2
  }
];
