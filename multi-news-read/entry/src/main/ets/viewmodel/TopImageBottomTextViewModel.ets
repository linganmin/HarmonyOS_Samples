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

export default class TopImageBottomTextViewModel {
  private newsList: News[] = [];

  constructor() {
    this.newsList.push(new News(Constants.NEWS_ID_LIST[0],
      $r('app.string.autumn_sun_wheat_field'),
      [$r("app.media.top_image_bottom_text_3")],
      $r('app.string.media_news'),
      $r('app.string.news_update_1_hour_ago')
    ));
    this.newsList.push(new News(Constants.NEWS_ID_LIST[1],
      $r('app.string.rabbit_in_mythology'),
      [$r("app.media.top_image_bottom_text_1")],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago')
    ));
    this.newsList.push(new News(Constants.NEWS_ID_LIST[2],
      $r('app.string.ai_in_education'),
      [$r("app.media.top_image_bottom_text_2")],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago')
    ));
  }

  getNewsList() {
    return this.newsList;
  }
}