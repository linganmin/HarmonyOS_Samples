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

import { TabItem, BottomTabModel, ClassifyModel } from './TabItem';

export function initTabData(): TabItem[] {
  let tabDataArray: TabItem[] = [];
  TabItemData.forEach((item: TabItem) => {
    tabDataArray.push(new TabItem(item.id, item.name));
  })
  return tabDataArray;
}

export function initTabTuData(): BottomTabModel[] {
  let tabTuDataArray: BottomTabModel[] = [];
  TabTuItemData.forEach((item: BottomTabModel) => {
    tabTuDataArray.push(new BottomTabModel(item.defaultImage, item.selectImage, item.title, item.middleMode));
  })
  return tabTuDataArray;
}

export function initSideData(): ClassifyModel[] {
  let tabDataArray: ClassifyModel[] = [];
  ClassifyData.forEach((item: ClassifyModel) => {
    tabDataArray.push(new ClassifyModel(item.classifyId, item.classifyName));
  })
  return tabDataArray;
}

const TabItemData: TabItem[] = [
  new TabItem(0, $r('app.string.follow')),
  new TabItem(1, $r('app.string.recommended')),
  new TabItem(2, $r('app.string.book')),
  new TabItem(3, $r('app.string.novel')),
  new TabItem(4, $r('app.string.caricature')),
  new TabItem(5, $r('app.string.listen_book')),
  new TabItem(6, $r('app.string.making_friends')),
  new TabItem(7, $r('app.string.live_broadcast')),
  new TabItem(8, $r('app.string.video'))
];

const TabTuItemData: BottomTabModel[] = [
  new BottomTabModel($r('app.media.home'), $r('app.media.activeHome'), $r('app.string.tab_homepage')),
  new BottomTabModel($r('app.media.star'), $r('app.media.activeStar'), $r('app.string.activity')),
  new BottomTabModel($r('app.media.activePlus'), $r('app.media.activePlus'), '', true),
  new BottomTabModel($r('app.media.message'), $r('app.media.activeMessage'), $r('app.string.message')),
  new BottomTabModel($r('app.media.people'), $r('app.media.activePeople'),$r('app.string.tab_mine'))
];

const ClassifyData: ClassifyModel[] = [
  new ClassifyModel(0, $r('app.string.popular_course')),
  new ClassifyModel(1, $r('app.string.latest_courses')),
  new ClassifyModel(2, 'HarmonyOS',),
  new ClassifyModel(3, $r('app.string.wonderful_activity')),
  new ClassifyModel(4, $r('app.string.developer_said')),
  new ClassifyModel(5, $r('app.string.back_end_development')),
  new ClassifyModel(6, $r('app.string.front_end_development'))
];