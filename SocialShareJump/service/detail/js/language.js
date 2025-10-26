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

class Article {
  constructor(aid, title, content, avatar, author) {
    this.aId = aid;
    this.title = title;
    this.content = content;
    this.avatar = avatar;
    this.author = author;
  }
}

const DETAIL_CONTENT_EN =
  'As terminal device forms become increasingly diversified, during the application design, you should ensure that a user interface (UI) can adapt to different screen sizes, screen orientations, and device types. In addition, the multi-device experience continuity needs to be maintained, the multi-device independent design needs to be improved, and the workload and maintenance costs of developers need to be reduced as much as possible. HarmonyOS provides a multi-device-oriented design guide, allowing designers to use a scientific method to minimize the design workload and ensure design consistency. In addition, HarmonyOS provides corresponding technical capabilities to help developers quickly design multi-device applications.';

const DETAIL_CONTENT_ZH =
  '随着终端设备形态日益多样化，应用设计需要考虑界面能适配不同的屏幕尺寸、屏幕方向和设备类型。同时还需要保持多设备体验的连续性，改善多端独立的设计、尽可能降低开发者的工作量和维护成本。基于此 Harmony OS为设计师提供了面向多设备的设计指南，让设计师在进行多端设计时有一套科学的方法，最大程度减少设计的工作量，保障多端设计在一定程度的一致性。同时 Harmony OS也提供了对应的技术能力，帮助开发者快速地进行多端应用设计。';

const ARTICLE_LIST_DATA_EN = [
  new Article('a001', 'Festive travel', DETAIL_CONTENT_EN, './imgs/avatar1.jpg', 'Jack'),
  new Article('a002', 'Look at the scenery', DETAIL_CONTENT_EN, './imgs/avatar2.jpg', 'Lucy'),
  new Article('a003', 'Life hacks', DETAIL_CONTENT_EN, './imgs/avatar3.jpg', 'Lee'),
  new Article('a004', 'Travel planning', DETAIL_CONTENT_EN, './imgs/avatar4.jpg', 'Bill'),
  new Article('a005', 'HarmonyOS learning', DETAIL_CONTENT_EN, './imgs/avatar4.jpg', 'Bill'),
  new Article('a006', 'From beginner to proficient', DETAIL_CONTENT_EN, './imgs/avatar4.jpg', 'Bill')
];

const ARTICLE_LIST_DATA_ZH = [
  new Article('a001', '节日出行', DETAIL_CONTENT_ZH, './imgs/avatar1.jpg', 'Jack'),
  new Article('a002', '看风景', DETAIL_CONTENT_ZH, './imgs/avatar2.jpg', 'Lucy'),
  new Article('a003', '生活小技巧', DETAIL_CONTENT_ZH, './imgs/avatar3.jpg', 'Lee'),
  new Article('a004', '旅行计划', DETAIL_CONTENT_ZH, './imgs/avatar4.jpg', 'Bill'),
  new Article('a005', 'HarmonyOS学习', DETAIL_CONTENT_ZH, './imgs/avatar4.jpg', 'Bill'),
  new Article('a006', '从入门到精通', DETAIL_CONTENT_ZH, './imgs/avatar4.jpg', 'Bill')
];


let dataEn = new Object();
dataEn.articeList = ARTICLE_LIST_DATA_EN;
dataEn.follow = 'Follow';
dataEn.skip = 'Skip';
dataEn.appName = 'App name';
dataEn.appDesc = 'App description';

let dataZh = new Object();
dataZh.articeList = ARTICLE_LIST_DATA_ZH;
dataZh.follow = '关注';
dataZh.skip = '打开';
dataZh.appName = '应用名称';
dataZh.appDesc = '应用介绍';