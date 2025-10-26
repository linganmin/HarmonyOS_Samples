/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { genResourceArray } from "commons";

export const TIP_TEXTS = genResourceArray(3, 'home_tip_text');

export const NAV_BAR_TEXTS = genResourceArray(4, 'home_nav_bar_text');

export const CATEGORY_TITLES = genResourceArray(10, 'home_category_title');

export const CATEGORY_IMAGES = genResourceArray(10, 'categories', 'media');

export const BANNER_IMAGES = genResourceArray(4, 'recommended_product', 'media');

export const BANNER_LIVING = [true, false, true, false];

export const WELFARE_PRICES = ['1299', '899', '599', '2499', '6988', '1799', '988', '6999'];

export const WELFARE_IMAGES = genResourceArray(4, 'welfare_product', 'media');

export const RECOMMEND_IMAGES: Resource[] = genResourceArray(4, 'section_product', 'media');

export const RECOMMEND_TITLES: Resource[] = genResourceArray(5, 'home_recommend_title');

export const RECOMMEND_INFOS: Resource[] = genResourceArray(5, 'home_recommend_info');

export const RECOMMEND_PRICES: string[] = ['￥10999', '￥4999', '￥2499', '￥2599', '￥8399'];

export const RECOMMEND_FEATURES: Resource[] = genResourceArray(5, 'home_recommend_feature');

export const RECOMMEND_COMMENT: Resource = $r('app.string.home_recommend_comment');
