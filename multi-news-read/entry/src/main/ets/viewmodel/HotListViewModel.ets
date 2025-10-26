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

export default class HotListViewModel {
  private hotList: Resource[] = [];

  constructor() {
    this.hotList.push($r('app.string.wildlife_protection_regulation'));
    this.hotList.push($r('app.string.celebrity_wedding_photos'));
    this.hotList.push($r('app.string.tea_miraculous_effects'));
    this.hotList.push($r('app.string.waterfall_wonder'));
    this.hotList.push($r('app.string.anticipated_tv_series_premiere'));
  }

  public getHotList() {
    return this.hotList;
  }
}