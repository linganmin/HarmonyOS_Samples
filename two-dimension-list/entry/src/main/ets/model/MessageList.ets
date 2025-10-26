/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

export interface MessageItem {
  id: number;
  name: string;
  price: string;
  type: Resource;
  param: string;
  icon: Resource;
}

export const GoodsName: string[] = [
  'XXXXXX\nXXXX\nMate60Pro',
  'XXXXXX\nMateBook\nX Pro',
  'XXXXXX\nMatePad\nPro13.2',
  'XXXX\nWATCH\nUltimate',
  'XXXX\nnova 11 SE',
  'XXXXXX\nFreeBuds\nPro 3'
]

export const MessageList: MessageItem[] = [
  {
    id: 1,
    name: 'XXXXXX\nXXXX\nMate60Pro',
    price: '￥6499',
    type: $r('app.string.type_phone'),
    param: 'XXXXX',
    icon: $r('app.media.pic1')
  },
  {
    id: 2,
    name: 'XXXXXX\nMateBook\nX Pro',
    price: '￥12999',
    type: $r('app.string.type_computer'),
    param: 'XXXXX',
    icon: $r('app.media.pic2')
  },
  {
    id: 3,
    name: 'XXXXXX\nMatePad\nPro13.2',
    price: '￥5699',
    type: $r('app.string.type_computer'),
    param: 'XXXXX',
    icon: $r('app.media.pic3')
  },
  {
    id: 4,
    name: 'XXXX\nWATCH\nUltimate',
    price: '￥6999',
    type: $r('app.string.type_watch'),
    param: 'XXXXX',
    icon: $r('app.media.pic4')
  },
  {
    id: 5,
    name: 'XXXX\nnova 11 SE',
    price: '￥3699',
    type: $r('app.string.type_phone'),
    param: 'XXXXX',
    icon: $r('app.media.pic5')
  },
  {
    id: 6,
    name: 'XXXXXX\nFreeBuds\nPro 3',
    price: '￥1999',
    type: $r('app.string.type_earphone'),
    param: 'XXXXX',
    icon: $r('app.media.pic6')
  }
]