/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { util } from '@kit.ArkTS';
import { PlayerData, TranslateOption } from '@hadss/swipeplayer';
import { CommonConstant } from '../constant/CommonConstant';

export class LiveCommentsData {
  private avatar: ResourceStr;
  private userName: ResourceStr;
  private commentContent: ResourceStr;
  private likeIcon: ResourceStr;
  private likeNum: number;
  private date: ResourceStr;
  private from: ResourceStr;
  private reply: ResourceStr;

  constructor(avatar: ResourceStr, userName: ResourceStr, commentContent: ResourceStr, likeIcon: ResourceStr,
    likeNum: number, date: ResourceStr, from: ResourceStr, reply: ResourceStr) {
    this.avatar = avatar;
    this.userName = userName;
    this.commentContent = commentContent;
    this.likeIcon = likeIcon;
    this.likeNum = likeNum;
    this.date = date;
    this.from = from;
    this.reply = reply;
  }

  getAvatar(): ResourceStr {
    return this.avatar;
  }

  getUserName(): ResourceStr {
    return this.userName;
  }

  getCommentContent(): ResourceStr {
    return this.commentContent;
  }

  getLikeIcon(): ResourceStr {
    return this.likeIcon;
  }

  getLikeNum(): number {
    return this.likeNum;
  }

  getDate(): ResourceStr {
    return this.date;
  }

  getFrom(): ResourceStr {
    return this.from;
  }

  getReply(): ResourceStr {
    return this.reply;
  }
}

export class LiveCommentsModel {
  private liveCommentsList: LiveCommentsData[] = [];

  constructor() {
    CommonConstant.LIVE_COMMENTS_AVATAR.forEach((_item: Resource, index: number) => {
      this.liveCommentsList.push(new LiveCommentsData(CommonConstant.LIVE_COMMENTS_AVATAR[index],
        CommonConstant.LIVE_COMMENTS_USERNAME[index], CommonConstant.LIVE_COMMENTS_CONTENT[index],
        CommonConstant.LIVE_COMMENTS_LIKE_ICON,
        CommonConstant.LIVE_COMMENTS_LIKE_NUM[index], CommonConstant.LIVE_COMMENTS_DATE[index],
        CommonConstant.LIVE_COMMENTS_FROM[index], CommonConstant.LIVE_COMMENTS_REPLY[index]));
    });
  }

  getLiveCommentsList(): LiveCommentsData[] {
    return this.liveCommentsList;
  }
}

export interface PlayerSpeed {
  text: number;
  playbackSpeed: number;
}

export class VideoData implements PlayerData {
  likesNum: number = 0;
  commentsNum: number = 0;
  shareNum: number = 0;
  url: string = '';
  cover: string = '';
  publisherImage: ResourceStr = '';
  publisherName: Resource = $r('app.string.PUBLISHER_NAME_1');
  mediaIntro: Resource = $r('app.string.MEDIA_INFO_1');
  isLike: boolean = false;
  id: string = util.generateRandomUUID(true);

  getId(): string {
    return this.id;
  }

  getSource(): string {
    return this.url;
  }

  getCover(): ResourceStr | undefined {
    return undefined;
  }

  getType(): string {
    if (this.url) {
      return 'video';
    } else {
      return 'ad';
    }
  }
}

@Observed
export class VerticalScreenData {
  isShow: boolean = true;
  likesNum: number = 0;
  commentsNum: number = 0;
  shareNum: number = 0;
  isLikes: boolean = false;
  pubIcon: Resource;
  pubName: Resource;
  videoInfo: Resource;

  constructor(likesNum: number, commentsNum: number, shareNum: number, isLikes: boolean, pubIcon: Resource,
    pubName: Resource, videoInfo: Resource) {
    this.likesNum = likesNum;
    this.commentsNum = commentsNum;
    this.shareNum = shareNum;
    this.isLikes = isLikes;
    this.pubIcon = pubIcon;
    this.pubName = pubName;
    this.videoInfo = videoInfo;
  }
}

@Observed
export class CommentsData extends TranslateOption {
  x: number | string = 0;
  y: number | string = 0;
}


export interface MediaData {
  likesNum: number,
  commentsNum: number,
  shareNum: number,
  url: string;
  publisherImage: Resource;
  publisherName: Resource;
  mediaIntro: Resource;
  isLike: boolean;
}

@Observed
export class fullScreenData {
  constructor() {

  }
}