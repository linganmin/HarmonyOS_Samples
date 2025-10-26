/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { ListManager } from '@hadss/scroll_components';

@Observed
export class TabsCeilingViewModel {
  @Track dataList: ItemData[] = [];
  myListManager: ListManager;

  constructor(myListManager: ListManager) {
    this.myListManager = myListManager;
  }

  loadData() {
    let dataList: ItemData[] = [];
    let count = 30;
    for (let i = 1; i <= count; i++) {
      dataList.push(generateRandomItemData());
    }
    this.dataList = dataList;
    this.myListManager.setDataSource(dataList);
  }
}

const itemDataArray: ItemData[] = [{
  imgUrl: $r('app.media.pic1'),
  id: 1,
  title: $r('app.string.foundation'),
  content: $r('app.string.manager_content')
}, {
  imgUrl: $r('app.media.pic2'),
  id: 2,
  title: $r('app.string.insurance'),
  content: $r('app.string.manager_content')
}, {
  imgUrl: $r('app.media.pic3'),
  id: 3,
  title: $r('app.string.futures_trading'),
  content: $r('app.string.manager_content')
}, {
  imgUrl: $r('app.media.pic4'),
  id: 4,
  title: $r('app.string.security'),
  content: $r('app.string.manager_content')
}, {
  imgUrl: $r('app.media.pic5'),
  id: 5,
  title: $r('app.string.foundation'),
  content: $r('app.string.manager_content')
}, {
  imgUrl: $r('app.media.pic1'),
  id: 6,
  title: $r('app.string.foundation'),
  content: $r('app.string.manager_content')
}, {
  imgUrl: $r('app.media.pic2'),
  id: 7,
  title: $r('app.string.insurance'),
  content: $r('app.string.manager_content')
}, {
  imgUrl: $r('app.media.pic3'),
  id: 8,
  title: $r('app.string.futures_trading'),
  content: $r('app.string.manager_content')
}, {
  imgUrl: $r('app.media.pic4'),
  id: 9,
  title: $r('app.string.security'),
  content: $r('app.string.manager_content')
}, {
  imgUrl: $r('app.media.pic5'),
  id: 10,
  title: $r('app.string.foundation'),
  content: $r('app.string.manager_content')
},];

export interface ParamsItemData {
  itemData: ItemData;
}

@Observed
export class ItemData {
  id: number = -1;
  title: string | ResourceStr = '';
  content: string | ResourceStr = '';
  imgUrl: string | ResourceStr = '';
}

const getRandomNumber = (min: number, max: number): number => {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function generateRandomItemData(): ItemData {
  const count = getRandomNumber(0, itemDataArray.length - 1);
  return itemDataArray[count];
}