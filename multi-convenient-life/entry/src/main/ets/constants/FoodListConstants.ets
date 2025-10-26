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
import { hilog } from "@kit.PerformanceAnalysisKit";

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext!.getHostContext()!;

export class FoodListConstants {
  /**
   * Filter list.
   */
  static readonly TABS_LIST: string[] =
    [this.ResourceToString($r('app.string.tab_one')), this.ResourceToString($r('app.string.tab_two')),
      this.ResourceToString($r('app.string.tab_three')), this.ResourceToString($r('app.string.tab_four')),
      this.ResourceToString($r('app.string.tab_five')), this.ResourceToString($r('app.string.tab_six')),
      this.ResourceToString($r('app.string.tab_seven')), this.ResourceToString($r('app.string.tab_eight'))];
  /**
   * Food pictures.
   */
  static readonly FOOD_ITEM_IMAGE: Resource[] = [$r('app.media.ShopGoods1'), $r('app.media.ShopGoods2'),
    $r('app.media.ShopGoods3'), $r('app.media.ShopGoods4'), $r('app.media.ShopGoods5')
  ];
  /**
   * Food pictures.
   */
  static readonly FOOD_ITEM_NAME: string[] =
    ['美味精品餐厅', '家常菜', '烘焙蛋糕店•甜点', '素食餐厅', '老师傅美味炒饭'];
  /**
   * Support reservation.
   */
  static readonly FOOD_ITEM_RESERVATION: boolean[] = [false, false, true, true, true];
  /**
   * Food rating.
   */
  static readonly FOOD_ITEM_RATING: number[] = [4.0, 5.0, 4.0, 4.0, 4.0];
  /**
   * Price per person.
   */
  static readonly FOOD_ITEM_PRICE_PERSON: number[] = [60, 45, 130, 130, 130];
  /**
   * Location Label.
   */
  static readonly FOOD_ITEM_LOCATION_LABEL: string[] = ['汉堡', '湘菜馆', '甜点/蛋糕', '粤菜馆', '粤菜馆'];
  /**
   * The distance from.
   */
  static readonly FOOD_ITEM_DISTANCE: string[] = ['3.3km', '<500m', '1.3km', '3.3km'];
  /**
   * Food region rankings.
   */
  static readonly FOOD_ITEM_RAKING: string[][] =
    [['当地西餐榜第3名', '当地炸鸡榜第5名'], ['当地湘菜榜第5名', '新中式风格'],
      ['当地甜点榜第2名'], ['当地粤菜榜第6名'], ['当地粤菜榜第6名']
    ];
  /**
   * Current price of food.
   */
  static readonly FOOD_ITEM_PRICE: number[] = [78, 78, 68, 78, 78];
  /**
   * Original price of food.
   */
  static readonly FOOD_ITEM_ORIGINAL_PRICE: number[] = [90, 90, 80, 90, 90];
  /**
   * Recommended Offers.
   */
  static readonly FOOD_ITEM_RECOMMENDED: string[] =
    ['【牛肉汉堡】双人套餐含可乐+薯条', '【进店必吃】辣椒炒肉3人份套餐（不含米饭）',
      '送男友、女友，情侣暴富女神蛋糕，6英寸，3公里内免费配送', '美味专属双人套餐', '经典美味套餐，饱肚子'];

  static ResourceToString(resource: Resource): string {
    if (context) {
      try {
        return context.resourceManager.getStringSync(resource.id);
      } catch (e) {
        hilog.error(0x0000, 'multi-convenient-life', `getStringSync error. Cause: ${JSON.stringify(e)}`);
      }
    }
    return ''

  }
}