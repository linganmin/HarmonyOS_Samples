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

export default class MultiImageViewModelForMediaNews {
  private newsList: News[] = [];

  constructor() {
    this.newsList.push(new News(Constants.NEWS_ID_LIST[0],
      $r('app.string.music_listening_experience'), [
        $r("app.media.multi_image_group_01_1"),
        $r("app.media.multi_image_group_01_2"),
        $r("app.media.multi_image_group_01_3")
      ],
      $r("app.string.media_news"),
      $r("app.string.news_update_1_hour_ago")
    ));
    this.newsList.push(new News(Constants.NEWS_ID_LIST[1],
      $r('app.string.spring_scenery'), [
        $r("app.media.multi_image_group_02_1"),
        $r("app.media.multi_image_group_02_2"),
        $r("app.media.multi_image_group_02_3")
      ],
      $r("app.string.media_news"),
      $r("app.string.news_update_1_hour_ago")
    ));
  }

  public getNewsListByBreakpoint(bp: string = 'sm'): News[] {
    if (bp == 'xs' || bp == 'sm' || bp == 'md') {
      return [this.newsList[0]];
    }
    return this.newsList;

  }

  public getMultiImageList(): News[] {
    return this.newsList;
  }
}