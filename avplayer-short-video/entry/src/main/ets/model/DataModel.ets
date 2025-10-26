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

import { VideoDataType } from '../common/constants/CommonConstants';
import { VideoData } from '../model/VideoData';

export const SOURCES: VideoData[] = [
  {
    type: VideoDataType.RAW_FILE,
    index: 0,
    videoSrc: '1.mp4',
    caption: 'cn_captions1.srt'
  },
  {
    type: VideoDataType.RAW_FILE,
    index: 1,
    videoSrc: '2.mp4',
    caption: 'cn_captions2.srt'
  },
  {
    type: VideoDataType.RAW_FILE,
    index: 2,
    videoSrc: '3.mp4',
    caption: 'cn_captions2.srt'
  },
  {
    type: VideoDataType.RAW_FILE,
    index: 3,
    videoSrc: '4.mp4',
    caption: 'cn_captions2.srt'
  },
  {
    type: VideoDataType.RAW_FILE,
    index: 4,
    videoSrc: '5.mp4',
    caption: 'cn_captions2.srt'
  },
  {
    type: VideoDataType.RAW_FILE,
    index: 5,
    videoSrc: '6.mp4',
    caption: 'cn_captions2.srt'
  }
]