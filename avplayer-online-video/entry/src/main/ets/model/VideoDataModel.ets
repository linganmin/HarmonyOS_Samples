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
import { VideoData } from './VideoData';

export class VideoDataModel implements VideoData {
  type: VideoDataType = VideoDataType.RAW_FILE;
  videoSrc: string = '';
  name?: string | Resource | undefined;
  description?: ResourceStr | undefined;
  head?: Resource | undefined;
  caption?: string | undefined;
  index?: number | undefined;
  seekTime?: number | undefined;
  isMuted?: boolean | undefined;
  navDesName: string = '';

  static getVideoDataList(): VideoDataModel[] {
    return [{
      name: $r('app.string.video_name_1'),
      type: VideoDataType.URL,
      videoSrc: 'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/phones/nova-flip/new/video/design-intro-popup.mp4',
      description: '',
      caption: 'captions.srt',
      index: 0,
      head: $r('app.media.mp4'),
      navDesName: 'UrlPlayer'
    },
      {
        name: $r('app.string.video_name_2'),
        type: VideoDataType.URL,
        videoSrc: 'http://192.168.84.211:8888/video/test.m3u8',
        description: '',
        caption: 'captions.srt',
        index: 0,
        head: $r('app.media.m3u8'),
        navDesName: 'UrlPlayer'
      },
      {
        name: $r('app.string.video_name_3'),
        type: VideoDataType.RAW_FILE,
        videoSrc: 'test1.mp4',
        description: '',
        caption: 'captions.srt',
        index: 0,
        navDesName: 'UrlPlayer'
      },
      {
        name: $r('app.string.video_name_4'),
        type: VideoDataType.RAW_M3U8_FILE,
        videoSrc: 'test.m3u8',
        description: '',
        caption: 'captions.srt',
        index: 0,
        head: $r('app.media.m3u8'),
        navDesName: 'UrlPlayer'
      },
      {
        name: $r('app.string.video_name_5'),
        type: VideoDataType.URL,
        videoSrc: 'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/phones/nova-flip/new/video/design-intro-popup.mp4',
        description: '',
        caption: 'captions.srt',
        index: 0,
        head: $r('app.media.mp4'),
        navDesName: 'BufferBarPlayer'
      }
    ];
  }
}
