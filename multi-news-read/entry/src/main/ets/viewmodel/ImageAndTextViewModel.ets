/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Constants from '../common/Constants';

export default class ImageAndTextViewModel {
  private newsList: News[] = [];

  constructor() {
    this.newsList.push(new News(Constants.NEWS_ID_LIST[0],
      $r('app.string.animal_news_highlight'),
      [$r('app.media.list_to_grid_01')],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago')));
    this.newsList.push(new News(Constants.NEWS_ID_LIST[1],
      $r('app.string.seaside_luxury_invitation'),
      [$r('app.media.list_to_grid_02')],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago')));
    this.newsList.push(new News(Constants.NEWS_ID_LIST[2],
      $r('app.string.special_architecture_showcase'),
      [$r('app.media.list_to_grid_05')],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago')));
    this.newsList.push(new News(Constants.NEWS_ID_LIST[3],
      $r('app.string.music_world_tour_start'),
      [$r('app.media.list_to_grid_14')],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago')));
    this.newsList.push(new News(Constants.NEWS_ID_LIST[4],
      $r('app.string.spectacular_waterfall'),
      [$r('app.media.list_to_grid_09')],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago')));
    this.newsList.push(new News(Constants.NEWS_ID_LIST[5],
      $r('app.string.spiritual_nourishment_places'),
      [$r('app.media.list_to_grid_10')],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago')));
    this.newsList.push(new News(Constants.NEWS_ID_LIST[6],
      $r('app.string.dog_raising_regulations'),
      [$r('app.media.list_to_grid_11')],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago')));
    this.newsList.push(new News(Constants.NEWS_ID_LIST[7],
      $r('app.string.new_aircraft_debut'),
      [$r('app.media.list_to_grid_12')],
      $r('app.string.media_news'),
      $r('app.string.news_update_2_hours_ago')));
  }

  public getNewsList(): News[] {
    return this.newsList;
  }

  public getNewsListGroup(group: number) {
    const start = 4 * group;
    const end = 4 * (group + 1);
    return this.newsList.slice(start, end);
  }
}

export class News {
  /**
   * News id
   */
  private id: string = '';
  /**
   * News title
   */
  private title: ResourceStr;
  /**
   * News images
   */
  private image: Resource[] = [];
  /**
   * News brief
   */
  private brief: ResourceStr = '';
  /**
   * News publisher
   */
  private publisher: ResourceStr = '';
  /**
   * News timeToNow
   */
  private timeToNow: ResourceStr = '';
  /**
   * News duration
   */
  private duration: string = '';

  constructor(id: string = '',
    title: Resource,
    image: Resource[],
    publisher: ResourceStr,
    timeToNow: ResourceStr,
    brief: ResourceStr = '',
    duration: string = ''
  ) {
    this.id = id;
    this.title = title;
    this.image = image;
    this.publisher = publisher;
    this.timeToNow = timeToNow;
    this.brief = brief;
    this.duration = duration;
  }

  getNewsID(): string {
    return this.id;
  }

  getTitle(): ResourceStr {
    return this.title;
  }

  getFirstImage(): Resource {
    return this.image[0];
  }

  getImages(): Resource[] {
    return this.image;
  }

  getBrief(): ResourceStr {
    return this.brief;
  }

  getPublisher(): ResourceStr {
    return this.publisher;
  }

  getTimeToNow(): ResourceStr {
    return this.timeToNow;
  }

  getDuration(): string {
    return this.duration;
  }
}