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

import { CardItem } from './CardItem';
import { ClassifyModel } from './ClassifyModel';

export class ClassifyViewModel {
  public getTopData(): Array<CardItem> {
    let data: Array<CardItem> = [
      new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.check_in')),
      new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.refund')),
      new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.food')),
      new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.ticket')),
      new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.Travel')),
      new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.itinerary')),
      new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.order'))
    ];
    return data;
  }

  public getClassifyModelList(): Array<ClassifyModel> {
    let classifyList: Array<ClassifyModel> = [];
    classifyList.push(
      new ClassifyModel(1, $r('app.string.trip'), [
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.reservation')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.itinerary')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.order')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.Retrofit')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.purchase')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.light')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.lounge')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.running')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.gift')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.fund')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.invoice')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.pass')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.Baggage')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.feed'))
      ])
    );
    classifyList.push(
      new ClassifyModel(2, $r('app.string.Tourism'), [
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.Subway')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.transfer')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.tourism'))
      ])
    );
    classifyList.push(
      new ClassifyModel(3, $r('app.string.entertainment'), [
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.family')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.redemption')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.complement')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.paradise')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.Points')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.calculator'))
      ])
    );
    classifyList.push(
      new ClassifyModel(4, $r('app.string.assistant'), [
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.network')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.Corporate')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.guide')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.ride')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.more')),
        new CardItem($r('app.media.ic_gallery_discover'), $r('app.string.account'))
      ])
    );
    return classifyList;
  }
}