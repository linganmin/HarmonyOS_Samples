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

import { MyCustomSpan } from '../model/MyCustomSpan';

/*
 * Emoji map
 */
// [Start emoji_data]
export const EMOJI_DATA: Map<string, Resource> = new Map([
  ["[哈哈]", $r('app.media.smile')]
]);

// [End emoji_data]

// [Start title_link_mock]
export const TitleLinkMock: MyCustomSpan[] = [
  new MyCustomSpan(0, '#摄影 ', 'pages/TitleDetail'),
  new MyCustomSpan(1, '#摄影 ', 'pages/TitleDetail'),
  new MyCustomSpan(2, '#摄影 ', 'pages/TitleDetail'),
  new MyCustomSpan(3,
    '亲近大海，领悟海，体会到了海的心声，海自然与你共鸣，无须刻意强求，也无须去费力搜寻，海，始终都会以潮声与你相亲，'),
  new MyCustomSpan(4, '#摄影 ', 'pages/TitleDetail'),
  new MyCustomSpan(5, '#摄影 ', 'pages/TitleDetail'),
  new MyCustomSpan(6, '#摄影 ', 'pages/TitleDetail'),
  new MyCustomSpan(7, '#摄影 ', 'pages/TitleDetail'),
  new MyCustomSpan(8, '以其海色'),
  new MyCustomSpan(9, '@摄影频道 ', 'pages/UserDetails'),
  new MyCustomSpan(10, '@摄影频道 ', 'pages/UserDetails'),
  new MyCustomSpan(11, '@摄影频道 ', 'pages/UserDetails'),
  new MyCustomSpan(12, '伴你舒适。山腰盘旋的那曲折险峻的实木栈道。')
];

// [End title_link_mock]

export const TitleLinkMock_EN: MyCustomSpan[] = [
  new MyCustomSpan(0, '#photography ', 'pages/TitleDetail'),
  new MyCustomSpan(1, '#photography ', 'pages/TitleDetail'),
  new MyCustomSpan(2, '#photography ', 'pages/TitleDetail'),
  new MyCustomSpan(3,
    'Getting close to the sea, understanding the sea, and experiencing the voice of the sea, the sea naturally resonates with you. There is no need to deliberately force or search for it. The sea will always meet you with the sound of the tide,'),
  new MyCustomSpan(4, '#photography ', 'pages/TitleDetail'),
  new MyCustomSpan(5, '#photography ', 'pages/TitleDetail'),
  new MyCustomSpan(6, '#photography ', 'pages/TitleDetail'),
  new MyCustomSpan(7, '#photography ', 'pages/TitleDetail'),
  new MyCustomSpan(8, 'With its sea color'),
  new MyCustomSpan(9, '@PhotographyChannel ', 'pages/UserDetails'),
  new MyCustomSpan(10, 'Accompany you comfortably. '),
  new MyCustomSpan(11, '@PhotographyChannel ', 'pages/UserDetails'),
  new MyCustomSpan(12, 'The winding and steep solid wood plank road hovering on the mountainside.')
];

// [Start emoji_mock]
export const EmojiMock: MyCustomSpan[] = [
  new MyCustomSpan(1, '[哈哈]'),
  new MyCustomSpan(2, '[哈哈]'),
  new MyCustomSpan(3, '[哈哈]'),
  new MyCustomSpan(4, '[哈哈]'),
  new MyCustomSpan(5, '[哈哈]'),
  new MyCustomSpan(6, '[哈哈]'),
  new MyCustomSpan(7, '[哈哈]'),
  new MyCustomSpan(8, '[哈哈]'),
  new MyCustomSpan(9, '[哈哈]'),
  new MyCustomSpan(10, '[哈哈]'),
  new MyCustomSpan(11, '[哈哈]'),
  new MyCustomSpan(12, '[哈哈]'),
  new MyCustomSpan(13, '[哈哈]'),
  new MyCustomSpan(14, '[哈哈]'),
  new MyCustomSpan(15, '[哈哈]'),
  new MyCustomSpan(16, '[哈哈]'),
  new MyCustomSpan(17, '[哈哈]'),
  new MyCustomSpan(18, '[哈哈]'),
  new MyCustomSpan(19, '[哈哈]'),
  new MyCustomSpan(20, '[哈哈]'),
  new MyCustomSpan(21, '[哈哈]'),
  new MyCustomSpan(22, '[哈哈]'),
  new MyCustomSpan(23, '[哈哈]'),
  new MyCustomSpan(24, '[哈哈]'),
  new MyCustomSpan(25, '[哈哈]'),
  new MyCustomSpan(26, '[哈哈]'),
  new MyCustomSpan(27, '[哈哈]'),
  new MyCustomSpan(28, '[哈哈]'),
  new MyCustomSpan(29, '[哈哈]'),
  new MyCustomSpan(30, '[哈哈]'),
  new MyCustomSpan(31, '[哈哈]'),
  new MyCustomSpan(32, '[哈哈]'),
  new MyCustomSpan(33, '[哈哈]'),
  new MyCustomSpan(34, '[哈哈]'),
  new MyCustomSpan(35, '[哈哈]')
];

// [End emoji_mock]

// [Start video_link_mock]
export const VideoLinkMock: MyCustomSpan[] = [
  new MyCustomSpan(1, '摄影师的视频', 'pages/TitleDetail'),
  new MyCustomSpan(3, '亲近大海，领悟海，体会到了海的心声，'),
  new MyCustomSpan(4, '摄影师的视频', 'pages/TitleDetail'),
  new MyCustomSpan(6, '海自然与你共鸣，无须'),
  new MyCustomSpan(7, '摄影师的视频', 'pages/TitleDetail'),
  new MyCustomSpan(9, '刻意强求，也无须去费力搜寻，'),
  new MyCustomSpan(10, '摄影师的视频', 'pages/TitleDetail'),
  new MyCustomSpan(11, '摄影师的视频', 'pages/TitleDetail'),
  new MyCustomSpan(12, '海，始终都会以潮声与你相亲，以其海色伴你舒适。山腰盘旋的那曲折险峻的实木栈道。')
];

// [End video_link_mock]

export const VideoLinkMock_EN: MyCustomSpan[] = [
  new MyCustomSpan(1, 'PhotographerVideo', 'pages/TitleDetail'),
  new MyCustomSpan(3, 'Getting close to the sea, understanding the sea, and experiencing the voice of the sea,'),
  new MyCustomSpan(4, 'PhotographerVideo', 'pages/TitleDetail'),
  new MyCustomSpan(6, 'The sea resonates with you naturally, there\'s no need for it'),
  new MyCustomSpan(7, 'PhotographerVideo', 'pages/TitleDetail'),
  new MyCustomSpan(9, 'Deliberately demanding, there is no need to search hard,'),
  new MyCustomSpan(10, 'PhotographerVideo', 'pages/TitleDetail'),
  new MyCustomSpan(11,
    'The sea will always greet you with the sound of the tide and accompany you comfortably with its sea color. The winding and steep solid wood plank road hovering on the mountainside.')
];

// [Start image_text_mock]
export const ImageTextMock: MyCustomSpan[] = [
  new MyCustomSpan(0, '今日热点', 'green'),
  new MyCustomSpan(1, ' 亲近大海，领悟海，体会到了海的心声，海自然与你共鸣，无须 '),
  new MyCustomSpan(3, '今日热点', 'green'),
  new MyCustomSpan(4, ' 刻意强求，也无须去费力 '),
  new MyCustomSpan(5, '天气信息资讯', 'red'),
  new MyCustomSpan(6, ' 搜寻，海，始终都会以潮声与你相亲，以其海色伴你舒适。山腰盘旋的那曲折险峻的实木栈道。')
];

// [End image_text_mock]

export const ImageTextMock_EN: MyCustomSpan[] = [
  new MyCustomSpan(0, 'TodayHotTopics', 'green'),
  new MyCustomSpan(1,
    ' Getting close to the sea,understanding the sea,experiencing the voice of the sea,the sea naturally resonates with you,there is no need Deliberately demanding, '),
  new MyCustomSpan(3, 'TodayHotTopics', 'green'),
  new MyCustomSpan(4, ' there is no need to put in effort Search,the sea Search,the sea'),
  new MyCustomSpan(5,
    ' will always greet you with the sound of tide,accompanying you comfortably with its sea color.The winding and steep solid wood plank road hovering on the mountainside. '),
  new MyCustomSpan(6, 'WeatherInformationNews', 'red')
];