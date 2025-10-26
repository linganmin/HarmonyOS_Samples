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

/**
 *  最佳实践：点击响应优化
 */
import { CHAT_AVATARS, CHAT_NICK_NAMES, CHAT_SNIPPETS, CHAT_TIMES } from '../common/constants/ChatConstants';

export default class ClassifyModel {
  id: number;
  hasBadge: boolean;
  name: string;
  snippet: string;
  time: string;
  hasMute: boolean;
  avatar: Resource;
  url: string = "";

  constructor(id: number) {
    this.id = id


    let rand = Math.floor(Math.random() * 2)
    if (rand == 0) {
      this.hasBadge = false
    } else {
      this.hasBadge = true
    }

    rand = Math.floor(Math.random() * 2)
    if (rand == 0) {
      this.hasMute = false
    } else {
      this.hasMute = true
    }

    rand = Math.floor(Math.random() * CHAT_NICK_NAMES.length)
    this.name = CHAT_NICK_NAMES[rand]


    rand = Math.floor(Math.random() * CHAT_SNIPPETS.length)
    this.snippet = CHAT_SNIPPETS[rand]

    this.time = CHAT_TIMES[id%CHAT_TIMES.length]

    rand = Math.floor(Math.random() * CHAT_AVATARS.length)
    this.avatar = CHAT_AVATARS[rand]

  }
}