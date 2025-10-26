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

import { VideoItemData } from './VideoInfo';

// [Start video_data]
export const VIDEO_DATA: VideoItemData[] =
  [
    new VideoItemData($r('app.string.info_detail'), 0, '1.mp4', $r(`app.media.preview1`)),
    new VideoItemData($r('app.string.info_detail'), 0, '2.mp4', $r(`app.media.preview2`)),
    new VideoItemData($r('app.string.info_detail'), 0, '3.mp4', $r(`app.media.preview3`)),
    // [StartExclude  video_data]
    new VideoItemData($r('app.string.info_detail'), 0, '4.mp4', $r(`app.media.preview4`)),
    new VideoItemData($r('app.string.info_detail'), 0, '5.mp4', $r(`app.media.preview5`)),
    new VideoItemData($r('app.string.info_detail'), 0, '6.mp4', $r(`app.media.preview6`)),
    new VideoItemData($r('app.string.info_detail'), 0, '1.mp4', $r(`app.media.preview1`)),
    new VideoItemData($r('app.string.info_detail'), 0, '2.mp4', $r(`app.media.preview2`)),
    new VideoItemData($r('app.string.info_detail'), 0, '3.mp4', $r(`app.media.preview3`)),
    new VideoItemData($r('app.string.info_detail'), 0, '4.mp4', $r(`app.media.preview4`)),
    new VideoItemData($r('app.string.info_detail'), 0, '5.mp4', $r(`app.media.preview5`)),
    new VideoItemData($r('app.string.info_detail'), 0, '6.mp4', $r(`app.media.preview6`))
  // [EndExclude  video_data]
  ];

// [End video_data]