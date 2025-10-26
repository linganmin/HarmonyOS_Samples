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

import Constants from '../common/Constants';
import { News } from './ImageAndTextViewModel';

export default class VideoListViewModel {
  private videoList: News[] = [];

  constructor() {
    this.videoList.push(new News(Constants.NEWS_ID_LIST[0],
      $r('app.string.movable_house_travel'),
      [$r("app.media.video_preview_image_01")],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago'),
      Constants.EMPTY_STRING,
      Constants.VIDEO_DURATION
    ));
    this.videoList.push(new News(Constants.NEWS_ID_LIST[1],
      $r('app.string.panda_climbing_tree'),
      [$r("app.media.video_preview_image_02")],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago'),
      Constants.EMPTY_STRING,
      Constants.VIDEO_DURATION
    ));
  }


  public getVideoList(): News[] {
    return this.videoList;
  }
}