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

import { getResourceString } from 'commons';
import { BANNER_IMAGES, BANNER_LIVING, CATEGORY_IMAGES, CATEGORY_TITLES,
  RECOMMEND_COMMENT,
  RECOMMEND_FEATURES,
  RECOMMEND_IMAGES,
  RECOMMEND_INFOS,
  RECOMMEND_PRICES,
  RECOMMEND_TITLES,
  WELFARE_IMAGES,
  WELFARE_PRICES } from '../constants/Home';

export interface Category {
  title: ResourceStr
  image: ResourceStr
}

export function getCategories(): Category[] {
  return CATEGORY_TITLES.map((title, index) => {
    const category: Category = {
      title,
      image: CATEGORY_IMAGES[index]
    };
    return category
  });
}

export interface Product {
  title?: ResourceStr
  image?: ResourceStr
  isLive?: boolean
  price?: string
  info?: ResourceStr
  feature?: ResourceStr
  comment?: ResourceStr
}

export function getBannerData(): Product[] {
  return BANNER_IMAGES.map((image, index) => {
    const product: Product = {
      image,
      isLive: BANNER_LIVING[index]
    };
    return product;
  });
}

export function getWelfareData(context: UIContext): Product[] {

  return WELFARE_IMAGES.map((image, index) => {
    const product: Product = {
      image,
      price: `￥${WELFARE_PRICES[index]}${getResourceString($r('app.string.price_start'), context)}`
    };
    return product;
  });
}

export function getRecommendData(): Product[] {
  return RECOMMEND_IMAGES.map((image, index) => {
    const product: Product = {
      image,
      price: RECOMMEND_PRICES[index],
      title: RECOMMEND_TITLES[index],
      feature: RECOMMEND_FEATURES[index],
      info: RECOMMEND_INFOS[index],
      comment: RECOMMEND_COMMENT
    };
    return product;
  });
}