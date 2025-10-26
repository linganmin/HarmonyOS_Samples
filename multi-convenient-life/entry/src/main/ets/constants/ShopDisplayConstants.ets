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

export class ShopDisplayConstants {
  /**
   * Shop name.
   */
  static readonly SHOP_NAME: string = '美味精品餐厅';
  /**
   * Shop rating.
   */
  static readonly SHOP_RATING: number = 4.8;
  /**
   * Shop profile.
   */
  static readonly SHOP_PROFILE: string = this.ResourceToString($r('app.string.shop_profile'));
  /**
   * Shop ranking.
   */
  static readonly SHOP_RANKING: string = '当地素食榜第2名';
  /**
   * Shop announcements.
   */
  static readonly SHOP_ANNOUNCEMENTS: string = '公告：来自南方独有的特质汤粉、炒粉、秘制慢火熬制汤底，欢迎新老顾客品尝.';
  /**
   * Shop tags.
   */
  static readonly SHOP_TAGS: string[] = [this.ResourceToString($r('app.string.shop_tag_one')),
    this.ResourceToString($r('app.string.shop_tag_two')), this.ResourceToString($r('app.string.shop_tag_three'))];
  /**
   * Dish name list.
   */
  static readonly DISH_NAME_LIST: string[] = ['辣椒炒肉', '必点白切香油鸡+饭+配菜', '老师傅美味炒饭', '美味牛排',
    '美味点心大厨精心制作'];
  /**
   * Dish tag list.
   */
  static readonly DISH_TAG_LIST: string[] =
    ['本店销量热销菜系', '本店销量热销菜系', '本店销量热销菜系', '本店销量热销菜系',
      '本店销量热销菜系'];
  /**
   * Dish profile list.
   */
  static readonly DISH_PROFILE_LIST: string[] = ['月售1000+  好评率91%', '月售1000+  好评率91%', '月售1000+  好评率91%',
    '月售1000+  好评率91%', '月售1000+  好评率91%'];
  /**
   * Dish price list.
   */
  static readonly DISH_PRICE_LIST: string[] = ['20.8', '30.8', '59.9', '50.8', '40.8'];
  /**
   * Dish original price list.
   */
  static readonly DISH_ORIGINAL_PRICE_LIST: string[] = ['30', '40', '80', '70', '60'];
  /**
   * Dish original price list.
   */
  static readonly DISH_IMAGE_LIST: Resource[] = [$r('app.media.ShopGoods4'), $r('app.media.ShopGoods6'),
    $r('app.media.ShopGoods5'), $r('app.media.ShopGoods7'), $r('app.media.ShopGoods8')];
  /**
   * Select or add specifications. 0: add; 1: select.
   */
  static readonly DISH_ADD_OR_CHOICE: number[] = [1, 0, 1, 1, 1];

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