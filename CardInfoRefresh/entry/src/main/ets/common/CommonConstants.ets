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

import { CardListItemData } from './CommonData';

export class CommonConstants {
  static readonly CARD_LIST_DATA_FIRST: Array<CardListItemData> = [
    {
      id: 0,
      title: $r('app.string.title1'),
      content: $r('app.string.content1'),
      icon: $r('app.media.item1'),
      favour: false,
      bgImage: $r('app.media.ic_picture1')
    },
    {
      id: 1,
      title: $r('app.string.title2'),
      content: $r('app.string.content2'),
      icon: $r('app.media.item2'),
      favour: false,
      bgImage: $r('app.media.ic_picture2')
    },
    {
      id: 2,
      title: $r('app.string.title3'),
      content: $r('app.string.content3'),
      icon: $r('app.media.item3'),
      favour: false,
      bgImage: $r('app.media.ic_picture3')
    },
    {
      id: 3,
      title: $r('app.string.title4'),
      content: $r('app.string.content4'),
      icon: $r('app.media.item4'),
      favour: false,
      bgImage: $r('app.media.ic_picture4')
    }
  ];

  static readonly CARD_LIST_DATA_SECOND: Array<CardListItemData> = [
    {
      id: 4,
      title: $r('app.string.title5'),
      content: $r('app.string.content5'),
      icon: $r('app.media.item5'),
      favour: false,
      bgImage: $r('app.media.ic_picture5')
    },
    {
      id: 5,
      title: $r('app.string.title6'),
      content: $r('app.string.content6'),
      icon: $r('app.media.item6'),
      favour: false,
      bgImage: $r('app.media.ic_picture6')
    },
    {
      id: 6,
      title: $r('app.string.title7'),
      content: $r('app.string.content7'),
      icon: $r('app.media.item7'),
      favour: false,
      bgImage: $r('app.media.ic_picture7')
    },
    {
      id: 7,
      title: $r('app.string.title8'),
      content: $r('app.string.content8'),
      icon: $r('app.media.item8'),
      favour: false,
      bgImage: $r('app.media.ic_picture8')
    }
  ];

  static readonly CARD_LIST_DATA_THIRD: Array<CardListItemData> = [
    {
      id: 8,
      title: $r('app.string.title9'),
      content: $r('app.string.content9'),
      icon: $r('app.media.item9'),
      favour: false,
      bgImage: $r('app.media.ic_picture9')
    },
    {
      id: 9,
      title: $r('app.string.title10'),
      content: $r('app.string.content10'),
      icon: $r('app.media.item10'),
      favour: false,
      bgImage: $r('app.media.ic_picture10')
    },
    {
      id: 10,
      title: $r('app.string.title11'),
      content: $r('app.string.content11'),
      icon: $r('app.media.item11'),
      favour: false,
      bgImage: $r('app.media.ic_picture11')
    },
    {
      id: 11,
      title: $r('app.string.title12'),
      content: $r('app.string.content12'),
      icon: $r('app.media.item12'),
      favour: false,
      bgImage: $r('app.media.ic_picture12')
    }
  ];

  static readonly DATA_INDEX: string = 'data_index';
}