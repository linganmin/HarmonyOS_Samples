/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/**
 * Interface of contact.
 */
export interface Contact {
  avatar: Resource | undefined;
  name: string;
};

/**
 * Information of contact.
 */
export const contactList: Array<Contact> = [
  {
    avatar: undefined,
    name: 'A'
  },
  {
    avatar: $r('app.media.avatar_pink'),
    name: 'Amy'
  },
  {
    avatar: $r('app.media.avatar_blue'),
    name: 'Allen'
  },
  {
    avatar: $r('app.media.avatar_purple'),
    name: 'Aiden'
  },
  {
    avatar: undefined,
    name: 'B'
  },
  {
    avatar: $r('app.media.avatar_blue'),
    name: 'Ben'
  },
  {
    avatar: $r('app.media.avatar_pink'),
    name: 'Brook'
  },
  {
    avatar: $r('app.media.avatar_purple'),
    name: 'Bob'
  },
  {
    avatar: $r('app.media.avatar_blue'),
    name: 'Bard'
  },
  {
    avatar: $r('app.media.avatar_purple'),
    name: 'Berger'
  },
  {
    avatar: $r('app.media.avatar_pink'),
    name: 'Bing'
  }
];

/**
 * Index of contact.
 */
export const contactIndex: Array<string> = [
  '#', '★', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U',
  'V', 'W', 'X', 'Y', 'Z'
];
