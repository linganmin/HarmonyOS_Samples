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

export class DishDetailConstants {
  /**
   * Dish details column.
   */
  static readonly DISH_DETAILS_COLUMN: string[] = ['商品描述', '原料', '分量', '荤素', '制作方法'];
  /**
   * Dish details column value.
   */
  static readonly DISH_DETAILS_COLUMN_VALUE: string[] =
    ['口感微辣，现烤现卖，让您品尝到美味的炸鸡', '鸡肉', '1人份', '荤素',
      '烤'];
  /**
   * Picture of the recommended pairing list.
   */
  static readonly RECOMMENDED_PAIRING_IMAGE: Resource[][] = [
    [$r('app.media.recommended1'), $r('app.media.recommended2'), $r('app.media.recommended3')],
    [$r('app.media.recommended1'), $r('app.media.recommended4'), $r('app.media.recommended5')],
    [$r('app.media.recommended1'), $r('app.media.recommended2'), $r('app.media.recommended3')]
  ];
  /**
   * Name of the recommended pairing list.
   */
  static readonly RECOMMENDED_PAIRING_NAME: string[][] = [
    ['美味炸鸡', '沙拉健康饮食', '糕点'], ['美味炸鸡', '曲奇饼干', '小点心糕点'], ['美味炸鸡', '沙拉健康饮食', '糕点'],
  ];
  /**
   * Price of the recommended pairing list.
   */
  static readonly RECOMMENDED_PAIRING_PRICE: number[][] = [
    [45.98, 12, 20], [45.98, 12, 30], [45.98, 12, 20]
  ];
  /**
   * Combination price of the recommended combination list.
   */
  static readonly RECOMMENDED_PAIRING_COMBINATION_PRICE: number[] = [60, 70, 60];
  /**
   * Original price of combinations in the recommended combination list.
   */
  static readonly RECOMMENDED_PAIRING_COMBINATION_ORIGINAL_PRICE: number[] = [77.98, 87.98, 77.98];
  /**
   * Comment avatar list.
   */
  static readonly COMMENT_AVATAR_IMAGE: Resource[] = [$r('app.media.commentAvatar1'), $r('app.media.commentAvatar2'),
    $r('app.media.commentAvatar3'), $r('app.media.commentAvatar4')
  ];
  /**
   * Comment name list.
   */
  static readonly COMMENT_NAME_LIST: string[] = ['Sanger', '北冰洋', '蓝莓小子', '会飞的鱼儿'];
  /**
   * Comment value list.
   */
  static readonly COMMENT_VALUE_LIST: string[] =
    ['包装很不错，打开里面看到的体积比一般的烤鸡大，咬下去第一口有汁水，很棒！',
      '味道很不错！值得一吃.', '肉质绝了，一个人吃它满足了.', '大吉大利，今晚吃鸡.'];
  /**
   * Comment date list.
   */
  static readonly COMMENT_DATE_LIST: string[] = ['2023.12.05', '2023.12.01', '2023.12.01', '2023.12.01'];
  /**
   * Comment filtering list.
   */
  static readonly COMMENT_FILTERING_LIST: string[] = ['有图/视频', '好评', '差评', '其他'];
  /**
   * Product tag list.
   */
  static readonly PRODUCT_TAG_LIST: string[] = ['美味回味无穷', '5位回头客推荐', '近期500+人下单', '其他'];
}
