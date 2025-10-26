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

import { VideoDataModel } from '../model/VideoDataModel';

export class VideoViewModel {
  private videoMap: VideoDataModel;

  constructor() {
    let videoMap: Map<number, Resource> = new Map();
    videoMap.set(0, $r('app.media.ic_video_1'));
    videoMap.set(1, $r('app.media.ic_video_2'));
    videoMap.set(2, $r('app.media.ic_video_3'));
    videoMap.set(3, $r('app.media.ic_video_4'));
    this.videoMap = new VideoDataModel(videoMap);
  }

  getVideo(index: number): Resource {
    return this.videoMap.getVideo(index);
  }
}