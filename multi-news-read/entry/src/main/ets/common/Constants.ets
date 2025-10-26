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

export default class Constants {
  /**
   * Full Screen width
   */
  static readonly FULL_WIDTH: string = "100%";
  /**
   * Full Screen width
   */
  static readonly HALF_HEIGHT: string = "50%";
  /**
   * One-third width
   */
  static readonly ONE_THIRD_WIDTH: string = "33%";
  /**
   * Full Screen height
   */
  static readonly FULL_HEIGHT: string = "100%";
  /**
   * Content width
   */
  static readonly CONTENT_WIDTH: string = "90%";
  /**
   * List gutter
   */
  static readonly LIST_GUTTER: string = '5vp';
  /**
   * Grid medium columns
   */
  static readonly GRID_MD_COLUMNS: number = 2;
  /**
   * Scrollbar width
   */
  static readonly SCROLLBAR_WIDTH: number = 10;
  /**
   * Grid all columns
   */
  static readonly GRID_ALL_COLUMNS: number = 4;
  /**
   * Grid row columns
   */
  static readonly GRID_ROW_COLUMNS: number[] = [1, 2, 4];
  /**
   * Grid column span
   */
  static readonly GRID_COLUMN_SPAN: number[] = [1, 2, 4];
  /**
   * The space occupied by the grid layout
   */
  static readonly GRID_COL_SPAN: number[] = [1, 2, 3, 4, 6, 12];
  /**
   * Element space
   */
  static readonly ELEMENT_SPACE: number = 20;
  /**
   * Grid horizontal gutter
   */
  static readonly GRID_HORIZONTAL_GUTTER: string[] = ["24vp", "32vp"];
  /**
   * Grid vertical gutter
   */
  static readonly GRID_VERTICAL_GUTTER: string[] = ["4vp", "16vp"];
  /**
   * Font weight array
   */
  static readonly FONT_WEIGHT: number[] = [400, 500, 700];
  /**
   * Layout weight
   */
  static readonly LAYOUT_WEIGHT: number = 1;
  /**
   * Opacity array
   */
  static readonly OPACITY: number[] = [0.4, 0.6, 0.9, 0.2];
  /**
   * Maximum lines
   */
  static readonly MAX_LINES: number = 2;
  /**
   * Aspect ratio for image
   */
  static readonly ASPECT_RATIO: number = 1.33;
  /**
   * Letter space
   */
  static readonly LETTER_SPACE: number = 0;
  /**
   * Hot list background colors
   */
  static readonly HOT_LIST_BACKGROUND_COLORS: string[] = [
    "#E84026", "#E84026", "#E84026",
    "#969696", "#969696", "#969696"
  ];
  /**
   * Routes
   */
  static readonly ROUTES: Route[] = [
    {
      text: $r('app.string.repeated_layout_1'), to: "MediaNews"
    },
    {
      text: $r('app.string.repeated_layout_2'), to: "NewsChannel"
    },
    {
      text: $r('app.string.list_to_grid'), to: "NewsListPage"
    }
  ];
  /**
   * News titles
   */
  static readonly NEWS_TITLE: string[] = [
    "重磅！这只动物又摊上大事了！或面临更多网友的投喂",
    "来自海边风光的奢华之邀，一起体验面朝大海优雅时光",
    "特别的建筑，你见过的有哪些？一起来看看吧",
    "音乐全球巡回演出｜第一站开始",
    "这究竟是一条怎样的瀑布，如此之壮观",
    "这片美丽的花海，这些宝藏打卡地点千万别错过！",
    "如何成就更多心灵滋养地",
    "涉及养犬规定！专家最新表态：细化管理，健全环境",
    "新款飞机即将亮相航空展",
    "音乐：专注地聆听音乐，感受动听的旋律",
    "绿水青山，花团锦簇：明媚的春天景象沁人心脾",
    "太阳一到秋天，就把它的光辉洒向麦田，麦子在风中摇摆着",
    "兔年说兔：兔子在古代为什么老是出现在神话中",
    "人工智能在教育事业中有哪些应用呢？老师会被AI取代吗？",
    "带着房屋去旅行,真正意义上的“搬家”，说走就走的旅行",
    "大熊猫解锁爬树新姿势，网友直呼萌翻了"
  ];
  /**
   * News briefs
   */
  static readonly NEWS_BRIEF: string[] = [
    "为了保护整个生态系统的稳定和人类自身的利益，需要重点投入力、经费、设施才能交出了一份亮眼的答卷。而",
    "在不文明养犬引发众多问题的背景下，犬只伤人事件再次受到关注。广大网友对养犬管理问题进行了讨论，到底",
    "习惯了城市生活的我们，或许去海边进行一趟旅行，可以缓解疲劳的心情，邀三五好友一起去感受一下海边的阳",
    "飞机作为二十世纪的重大发明，日益成为现代出行不可缺少的工具，同时飞机制造领域涉及的专业也越来越多"
  ];
  /**
   * News publishers
   */
  static readonly NEWS_PUBLISHER: string[] = ["新闻频道", "媒体新闻"];
  /**
   * News time to now
   */
  static readonly NEWS_TIME_TO_NOW: string[] = ["2小时前", "1小时前"];
  /**
   * News ID List
   */
  static readonly NEWS_ID_LIST: string[] = ["001", "002", "003", "004", "005", "006", "007", "008"];
  /**
   * Hot List
   */
  static readonly HOT_LIST: string[] = [
    "野生动物保护: 规范管理",
    "明星婚礼现场照曝光",
    "茶叶的神奇功效，青山枝叶绿",
    "校招高颜值HR火爆出圈",
    "壮丽的瀑布奇观",
    "期待已久的电视剧开播了"
  ];
  /**
   * Video duration
   */
  static readonly VIDEO_DURATION: string = "00:45";
  /**
   * Empty string
   */
  static readonly EMPTY_STRING: string = "";
  /**
   * All breakpoints
   */
  static readonly BREAKPOINTS: string[] = ['sm', 'md', 'lg'];
}


/**
 * Route type define
 */
export interface Route {
  text: Resource,
  to: string
}
