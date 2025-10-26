/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { SongItem } from './SongItem';

const songTitlesArr: Array<string> = [
  'app.string.dream_it_possible',
  'app.string.china_is_promising',
  'app.string.remain_true_to_our_original_aspiration',
  'app.string.i_got_it',
  'app.string.ha_ha_ha',
  'app.string.study_hard',
  'app.string.when_will_the_moon_be_clear_and_bright',
  'app.string.serious',
]
const songSingersArr: Array<string> = [
  'app.string.Delacey',
  'app.string.guitar',
  'app.string.zhang_san',
  'app.string.li_si',
  'app.string.wang_wu',
  'app.string.zhao_liu',
  'app.string.ming_yi',
  'app.string.ming_yi_s',
]

export function getSongListData(context: Context): Array<SongItem> {
  let songTitles: Array<string> = songTitlesArr
  let songSingers: Array<string> = songSingersArr
  return [
    {
      id: '1',
      title: songTitles[0],
      singer: songSingers[0],
      mark: '1',
      label: $r('app.media.ic_dream'),
      src: 'Delacey - Dream It Possible.flac',
      lyric: 'lrcfiles/DreamItPossible.lrc',
      isCollected: false,
    },
    {
      id: '2',
      title: songTitles[1],
      singer: songSingers[1],
      mark: '2',
      label: $r('app.media.cover1'),
      src: 'Delacey - Dream It Possible.flac',
      lyric: 'lrcfiles/DreamItPossible.lrc',
      isCollected: false,
    },
    {
      id: '3',
      title: songTitles[2],
      singer: songSingers[2],
      mark: '1',
      label: $r('app.media.cover2'),
      src: 'power.wav',
      lyric: '',
      isCollected: false,
    },
    {
      id: '4',
      title: songTitles[3],
      singer: songSingers[3],
      mark: '2',
      label: $r('app.media.cover3'),
      src: 'power.wav',
      lyric: '',
      isCollected: false,
    },
    {
      id: '5',
      title: songTitles[4],
      singer: songSingers[4],
      mark: '1',
      label: $r('app.media.cover4'),
      src: 'world.wav',
      lyric: '',
      isCollected: false,
    },
    {
      id: '6',
      title: songTitles[5],
      singer: songSingers[5],
      mark: '2',
      label: $r('app.media.cover5'),
      src: 'boisterous.wav',
      lyric: '',
      isCollected: false,
    },
    {
      id: '7',
      title: songTitles[6],
      singer: songSingers[6],
      mark: '1',
      label: $r('app.media.ic_avatar3'),
      src: 'world.wav',
      lyric: '',
      isCollected: false,
    },
    {
      id: '8',
      title: songTitles[7],
      singer: songSingers[7],
      mark: '2',
      label: $r('app.media.ic_avatar8'),
      src: 'power.wav',
      lyric: '',
      isCollected: false,
    },
  ];
}
