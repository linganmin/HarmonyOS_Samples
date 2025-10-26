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

export interface Comment {
  avatar: Resource;
  username: string;
  content: Resource;
  sendTime: string;
}

export const COMMENT_LIST_DADA: Comment[] = [
  {
    avatar: $r('app.media.icon_user1'),
    username: 'm******',
    content: $r('app.string.comment_content1'),
    sendTime: '07-27'
  },
  {
    avatar: $r('app.media.icon_user2'),
    username: 'H******',
    content: $r('app.string.comment_content2'),
    sendTime: '07-27'
  },
  {
    avatar: $r('app.media.icon_user3'),
    username: 'K******',
    content: $r('app.string.comment_content3'),
    sendTime: '07-27'
  }
];