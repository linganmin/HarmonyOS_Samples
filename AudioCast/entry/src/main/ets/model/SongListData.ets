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

import { SongItem, ToneQuality } from './SongData';

const songList: SongItem[] = [
  {
    title: 'Dream It Possible',
    singer: 'Delacey',
    label: $r('app.media.image_cover1'),
    src: 'Delacey - Dream It Possible.flac',
    pcmSrc: 'Delacey - Dream It Possible.pcm',
    lyric: 'lrcfiles/DreamItPossible.lrc',
    albumCoverUri: 'https://www-file.huawei.com/admin/asset/v1/pro/view/23eb4b8c0571484fb9bce7889aed4413.jpg',
    toneQualityList: [ToneQuality.SQ, ToneQuality.SPATIAL_AUDIO, ToneQuality.MASTER]
  },
  {
    title: 'Boisterous',
    singer: 'Jack',
    label: $r('app.media.image_cover2'),
    src: 'boisterous.wav',
    pcmSrc: 'boisterous.pcm',
    lyric: '',
    albumCoverUri: 'https://www-file.huawei.com/admin/asset/v1/pro/view/9240a42357da4644834897262b183b8d.jpg',
    toneQualityList: [ToneQuality.SQ, ToneQuality.SPATIAL_AUDIO, ToneQuality.MASTER]
  },
]

export { songList }