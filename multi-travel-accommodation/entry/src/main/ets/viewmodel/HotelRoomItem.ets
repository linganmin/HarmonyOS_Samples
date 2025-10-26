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

export class HotelRoomItem {
  /**
   * The image of th room.
   */
  private image: Resource;

  /**
   * The title of th room.
   */
  private title: string | Resource;

  /**
   * The standings of th room
   */
  private standings: number;

  /**
   * The configureOne of th room
   */
  private configureOne: string | Resource;

  /**
   * The breakfastNumber of th room
   */
  private breakfastNumber: number;

  /**
   * The configureTwo of th room
   */
  private configureTwo: string | Resource;

  /**
   * The originalPrice of th room
   */
  private originalPrice: string;

  /**
   * The discountedPrice of th room
   */
  private discountedPrice: string;

  /**
   * The remain of th room
   */
  private remain: boolean;

  /**
   * constructor method.
   */
  constructor(image: Resource, title: string | Resource, standings: number, configureOne: string | Resource,
    breakfastNumber: number, configureTwo: string | Resource, originalPrice: string, discountedPrice: string,
    remain: boolean) {
    this.image = image;
    this.title = title;
    this.standings = standings;
    this.configureOne = configureOne;
    this.breakfastNumber = breakfastNumber;
    this.configureTwo = configureTwo;
    this.originalPrice = originalPrice;
    this.discountedPrice = discountedPrice;
    this.remain = remain;
  }

  /**
   * The getter of image.
   */
  getImage() {
    return this.image;
  }

  /**
   * The getter of title.
   */
  getTitle() {
    return this.title;
  }

  /**
   * The getter of standings.
   */
  getStandings() {
    return this.standings;
  }

  /**
   * The getter of configureOne.
   */
  getConfigureOne() {
    return this.configureOne;
  }

  /**
   * The getter of breakfastNumber.
   */
  getBreakfastNumber() {
    return this.breakfastNumber;
  }

  /**
   * The getter of configureTwo.
   */
  getConfigureTwo() {
    return this.configureTwo;
  }

  /**
   * The getter of originalPrice.
   */
  getOriginalPrice() {
    return this.originalPrice;
  }

  /**
   * The getter of discountedPrice.
   */
  getDiscountedPrice() {
    return this.discountedPrice;
  }

  /**
   * The getter of remain.
   */
  getRemain() {
    return this.remain;
  }
}