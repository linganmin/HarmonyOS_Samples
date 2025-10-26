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

import { SongItem } from './SongData';
import { audio } from '@kit.AudioKit';

const SONG_LIST: SongItem[] = [
  {
    id: 1,
    title: 'Dream It Possible',
    src: 'Delacey - Dream It Possible.pcm',
    singer: 'Delacey',
    label: $r('app.media.ic_dream'),
    index: 0,
    type: audio.StreamUsage.STREAM_USAGE_MUSIC
  },
  {
    id: 2,
    title: 'VoIP语音通话',
    src: 'call.pcm',
    index: 1,
    type: audio.StreamUsage.STREAM_USAGE_VOICE_COMMUNICATION,
    start: 22,
    end: 32
  },
  {
    id: 3,
    title: '语音播报',
    src: 'world.pcm',
    index: 2,
    type: audio.StreamUsage.STREAM_USAGE_VOICE_ASSISTANT
  },
  {
    id: 4,
    title: '语音消息',
    src: 'power.pcm',
    index: 3,
    type: audio.StreamUsage.STREAM_USAGE_VOICE_MESSAGE
  },
  {
    id: 5,
    title: '铃声',
    src: 'Delacey - Dream It Possible.pcm',
    index: 4,
    type: audio.StreamUsage.STREAM_USAGE_RINGTONE
  },
  {
    id: 6,
    title: '通知',
    src: 'boisterous.pcm',
    index: 5,
    type: audio.StreamUsage.STREAM_USAGE_NOTIFICATION
  },
  {
    id: 7,
    title: '无障碍',
    src: 'boisterous.pcm',
    index: 6,
    type: audio.StreamUsage.STREAM_USAGE_ACCESSIBILITY
  },
  {
    id: 8,
    title: '电影或视频',
    src: 'boisterous.pcm',
    index: 7,
    type: audio.StreamUsage.STREAM_USAGE_MOVIE
  },
  {
    id: 9,
    title: '游戏',
    src: 'boisterous.pcm',
    index: 8,
    type: audio.StreamUsage.STREAM_USAGE_GAME
  },
  {
    id: 10,
    title: '有声读物（包括听书、相声、评书）、听新闻、播客等',
    src: 'boisterous.pcm',
    index: 9,
    type: audio.StreamUsage.STREAM_USAGE_AUDIOBOOK
  },
  {
    id: 11,
    title: '导航',
    src: 'nav.pcm',
    index: 10,
    type: audio.StreamUsage.STREAM_USAGE_NAVIGATION,
    start: 3,
    end: 7,
  },
  {
    id: 12,
    title: 'VoIP视频通话',
    src: 'boisterous.pcm',
    index: 11,
    type: audio.StreamUsage.STREAM_USAGE_VIDEO_COMMUNICATION
  },
  {
    id: 13,
    title: '闹钟',
    src: 'power.pcm',
    index: 12,
    type: audio.StreamUsage.STREAM_USAGE_ALARM
  }
];

export { SONG_LIST };