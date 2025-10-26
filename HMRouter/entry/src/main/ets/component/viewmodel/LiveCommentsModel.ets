/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { LiveConstants } from '../common/constants/LiveConstants';

export class LiveCommentsModel {
  private liveCommentsList: LiveCommentsProduct[] = [];
  constructor() {
    for (let i = 0; i < LiveConstants.LIVE_COMMENTS_AVATAR.length; i++) {
      this.liveCommentsList.push(new LiveCommentsProduct(LiveConstants.LIVE_COMMENTS_AVATAR[i],
        LiveConstants.LIVE_COMMENTS_USERNAME[i], LiveConstants.LIVE_COMMENTS_CONTENT[i],
        LiveConstants.LIVE_COMMENTS_LIKE_ICON,
        LiveConstants.LIVE_COMMENTS_LIKE_NUM[i]));
    }
  }

  getLiveCommentsList(): LiveCommentsProduct[] {
    return this.liveCommentsList;
  }
}


export class LiveCommentsProduct {
  private avatar: string | Resource;
  private userName: string | Resource;
  private commentContent: string | Resource;
  private likeIcon: string | Resource;
  private likeNum: number;
  constructor(avatar: string | Resource, userName: string, commentContent: string, likeIcon: string | Resource,
    likeNum: number) {
    this.avatar = avatar;
    this.userName = userName;
    this.commentContent = commentContent;
    this.likeIcon = likeIcon;
    this.likeNum = likeNum;
  }

  getAvatar(): string | Resource {
    return this.avatar;
  }

  getUserName(): string | Resource {
    return this.userName;
  }

  getCommentContent(): string | Resource {
    return this.commentContent;
  }

  getLikeIcon(): string | Resource {
    return this.likeIcon;
  }

  getLikeNum(): number {
    return this.likeNum;
  }
}