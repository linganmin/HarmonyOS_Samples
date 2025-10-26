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

export enum ItemType {
  IMAGE, VIDEO
}

export default class MediaItem {
  id: number = 0;
  type: number = ItemType.IMAGE;
  videoCover: Resource = $rawfile('covers/video_sample1.png');
  videoUri: Resource = $rawfile('video_sample1.mp4');
  imageUri: Resource = $rawfile('sections/0.jpg');

  constructor(id: number, type: ItemType, cover: Resource, videoUri: Resource, imageUri: Resource) {
    this.id = id;
    this.type = type;
    this.videoCover = cover;
    this.videoUri = videoUri;
    this.imageUri = imageUri;
  }
}