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

export interface VideoData {
  url: string;
  name: string;
  description:string;
  head: string;
  index: number;
}

export const VIDEO_SOURCES: VideoData[] = [
  {
    url: 'kv-popup.mp4',
    name: 'pura-x publicize video',
    description: 'pura-x publicize video description',
    head: 'video_cover_0.png',
    index: 0
  },
  {
    url: 'brand-ambassador-video.mp4',
    name: 'mate-xt publicize video',
    description: 'mate-xt publicize video description',
    head: 'video_cover_1.png',
    index: 1
  },
  {
    url: 'kv-intro-pop.mp4',
    name: 'pura publicize video',
    head: 'video_cover_2.png',
    description: 'pura publicize video description',
    index: 2
  },
  {
    url: 'camera-intro-popup.mp4',
    name: 'nova publicize video',
    head: 'video_cover_3.png',
    description: 'nova publicize video description',
    index: 3
  },
];