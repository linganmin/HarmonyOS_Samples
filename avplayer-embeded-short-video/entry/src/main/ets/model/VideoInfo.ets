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

import { image } from '@kit.ImageKit';

// [Start video_info]
export interface VideoInfo {
  id?: string;
  src?: string;
  stopTime?: number;
  preview?: Resource;
  surfaceID?: string;
  xController?: XComponentController;
  pixelMap?: image.PixelMap;
  detail: Resource;
  duration: number;
}

// [End video_info]
// [Start video_data]
export class VideoItemData implements VideoInfo {
  detail: Resource;
  src?: string;
  preview?: Resource;
  duration: number;

  constructor(detail: Resource, duration: number, src?: string, preview?: Resource) {
    this.detail = detail;
    this.src = src;
    this.duration = duration;
    this.preview = preview;
  }
}

// [End video_data]