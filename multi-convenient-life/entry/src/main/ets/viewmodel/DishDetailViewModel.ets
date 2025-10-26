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

import { DishDetailConstants } from '../constants/DishDetailConstants';

export class DishDetailList {
  private dishDetailList: DishDetail[] = []

  constructor() {
    DishDetailConstants.DISH_DETAILS_COLUMN.forEach((item, index) => {
      this.dishDetailList.push(new DishDetail(item, DishDetailConstants.DISH_DETAILS_COLUMN_VALUE[index]))
    })
  }

  getDishDetailList() {
    return this.dishDetailList
  }
}

export class DishDetail {
  private key: string;
  private value: string;

  constructor(key: string, value: string) {
    this.key = key
    this.value = value
  }

  getKey() {
    return this.key
  }

  getValue() {
    return this.value
  }
}

export class RecommendedCombinationList {
  private recommendedCombinationList: RecommendedCombination[] = []

  constructor() {
    DishDetailConstants.RECOMMENDED_PAIRING_COMBINATION_PRICE.forEach((item, combinationIndex) => {
      let tmpRecommendedDishes: RecommendedDishes[] = []
      DishDetailConstants.RECOMMENDED_PAIRING_NAME[combinationIndex].forEach((item, index) => {
        tmpRecommendedDishes.push(new RecommendedDishes(
          DishDetailConstants.RECOMMENDED_PAIRING_IMAGE[combinationIndex][index],
          DishDetailConstants.RECOMMENDED_PAIRING_NAME[combinationIndex][index],
          DishDetailConstants.RECOMMENDED_PAIRING_PRICE[combinationIndex][index]))
      })
      this.recommendedCombinationList.push(new RecommendedCombination(tmpRecommendedDishes,
        DishDetailConstants.RECOMMENDED_PAIRING_COMBINATION_PRICE[combinationIndex],
        DishDetailConstants.RECOMMENDED_PAIRING_COMBINATION_ORIGINAL_PRICE[combinationIndex]))
    })
  }

  getRecommendedCombinationList() {
    return this.recommendedCombinationList
  }
}

export class RecommendedCombination {
  private recommendedDishes: RecommendedDishes[];
  private price: number
  private originalPrice: number;

  constructor(recommendedDishes: RecommendedDishes[], price: number, originalPrice: number) {
    this.recommendedDishes = recommendedDishes
    this.originalPrice = originalPrice
    this.price = price
  }

  getRecommendedDishes() {
    return this.recommendedDishes
  }

  getPrice() {
    return this.price
  }

  getOriginalPrice() {
    return this.originalPrice
  }
}

export class RecommendedDishes {
  private image: Resource;
  private name: string;
  private price: number;

  constructor(image: Resource, name: string, price: number) {
    this.image = image
    this.name = name
    this.price = price
  }

  getImage() {
    return this.image
  }

  getName() {
    return this.name
  }

  getPrice() {
    return this.price
  }
}

export class CommentsDataList {
  private commentsDataList: CommentsData[] = []
  private commentsDataNumber: number = 16

  constructor() {
    for (let index = 0; index < this.commentsDataNumber; index++) {
      let i = index % 4;
      this.commentsDataList.push(new CommentsData(DishDetailConstants.COMMENT_AVATAR_IMAGE[i],
        DishDetailConstants.COMMENT_NAME_LIST[i], DishDetailConstants.COMMENT_VALUE_LIST[i],
        DishDetailConstants.COMMENT_DATE_LIST[i]))
    }
  }

  getCommentsDataList() {
    return this.commentsDataList
  }
}

export class CommentsData {
  private avatar: Resource;
  private name: string;
  private value: string;
  private date: string;

  constructor(avatar: Resource, name: string, value: string, date: string) {
    this.avatar = avatar
    this.name = name
    this.value = value
    this.date = date
  }

  getAvatar() {
    return this.avatar
  }

  getName() {
    return this.name
  }

  getValue() {
    return this.value
  }

  getDate() {
    return this.date
  }
}