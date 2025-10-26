/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { VideoData } from '@ohos/MediaService';

import { BasicDataSource } from './BasicDataSource';

export const SOURCES: VideoData[] = [
  {
    video: 'video_sample5.mp4',
    url: 'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/phones/nova-flip/new/video/design-intro-popup.mp4',
    name: $r('app.string.video_name0'),
    description: $r('app.string.video_description0'),
    time: '2024-1-3 14:52',
    auto: true,
    head: $r('app.media.image_thumbnail_1'),
    likeCount: '1234',
    commentCount: '2234',
    shareCount: '4234',
    play: true,
    index: 0
  },
  {
    video: '',
    url: 'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/phones/nova-flip/new/video/design-intro-popup.mp4',
    name: $r('app.string.video_name1'),
    description: $r('app.string.video_description1'),
    time: '2024-1-2 10:52',
    auto: true,
    head: $r('app.media.image_thumbnail_2'),
    likeCount: '7890',
    commentCount: '8890',
    shareCount: '9991',
    play: true,
    index: 1
  },
  {
    video: 'video_sample_product.mp4',
    url: 'https://assets.mixkit.co/videos/4028/4028-720.mp4',
    name: $r('app.string.video_name2'),
    description: $r('app.string.video_description3'),
    time: '2024-8-2 16:03',
    auto: true,
    head: $r('app.media.image_thumbnail_3'),
    likeCount: '4567',
    commentCount: '5567',
    shareCount: '7667',
    play: true,
    index: 2
  },
  {
    video: '',
    url: 'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/phones/nova-flip/new/video/design-intro-popup.mp4',
    name: $r('app.string.video_name3'),
    description: $r('app.string.video_description3'),
    time: '2024-8-22 10:03',
    auto: true,
    head: $r('app.media.image_thumbnail_1'),
    likeCount: '14567',
    commentCount: '25567',
    shareCount: '76672',
    play: true,
    index: 3
  },
  {
    video: '',
    url: 'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/phones/nova-flip/new/video/design-intro-popup.mp4',
    name: $r('app.string.video_name4'),
    description: $r('app.string.video_description4'),
    time: '2024-8-26 16:33',
    auto: true,
    head: $r('app.media.image_thumbnail_2'),
    likeCount: '467',
    commentCount: '567',
    shareCount: '77',
    play: true,
    index: 4
  }
];

// A subclass inheriting from BasicDataSource has overridden the methods.
export class VideoSource extends BasicDataSource {
  public dataArray: VideoData[] = [];

  constructor(element: VideoData[]) {
    super();
    this.dataArray.push(...element);
  }

  // Get the length of the array.
  public totalCount(): number {
    return this.dataArray.length;
  }

  // Retrieve data at the specified index.
  public getData(index: number): VideoData {
    return this.dataArray[index];
  }

  // Change a single piece of data.
  public addData(index: number, data: VideoData): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  // Add data.
  public pushData(data: VideoData): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
}