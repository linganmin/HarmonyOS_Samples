/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
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

export class Article {
  public aId: string;
  public title: Resource;
  public cover: Resource;
  public avatar: Resource;
  public favoriteNum: number;
  public author: string;

  constructor(aid: string, title: Resource, cover: Resource, avatar: Resource, favoriteNum: number, author: string) {
    this.aId = aid;
    this.title = title;
    this.cover = cover;
    this.avatar = avatar;
    this.favoriteNum = favoriteNum;
    this.author = author;
  }
}

export const ARTICLE_LIST_DATA: Article[] = [
  new Article('a001', $r('app.string.article_title1'), $r("app.media.cover1"), $r('app.media.avatar1'), 100, 'Jack'),
  new Article('a002', $r('app.string.article_title2'), $r('app.media.cover2'), $r('app.media.avatar2'), 88, 'Lucy'),
  new Article('a003', $r('app.string.article_title3'), $r("app.media.cover3"), $r('app.media.avatar3'), 68, 'Lee'),
  new Article('a004', $r('app.string.article_title4'), $r('app.media.cover4'), $r('app.media.avatar4'), 1314, 'Bill'),
  new Article('a005', $r('app.string.article_title5'), $r('app.media.cover5'), $r('app.media.avatar4'), 30, 'Bill'),
  new Article('a006', $r('app.string.article_title6'), $r("app.media.cover6"), $r('app.media.avatar4'), 36, 'Bill')
];

export function getArticleById(aid: string): Article | undefined {
  return ARTICLE_LIST_DATA.find((item: Article) => (item.aId === aid));
}