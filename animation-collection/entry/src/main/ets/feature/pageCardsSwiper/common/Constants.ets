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

import { CardInfo } from '../model/CardModel';

export default class Constants {
  /**
   * Unit length of the card, which is used to set the card proportion.
   */
  static readonly CARD_UNIT_LENGTH: number = 120;

  /**
   * Card list test case.
   */
  static readonly CARD_TEST_CASE: CardInfo[] = [
    { src: $r('app.media.img1'), width: 2 * this.CARD_UNIT_LENGTH, height: this.CARD_UNIT_LENGTH },
    { src: $r('app.media.img2'), width: 1.8* this.CARD_UNIT_LENGTH, height: 2 * this.CARD_UNIT_LENGTH },
    { src: $r('app.media.img3'), width: 2 * this.CARD_UNIT_LENGTH, height: 1.2 * this.CARD_UNIT_LENGTH },
    { src: $r('app.media.img4'), width: 1.5 * this.CARD_UNIT_LENGTH, height: 2 * this.CARD_UNIT_LENGTH }
  ];

  /**
   * Swiper's offset.
   */
  static readonly SWIPER_MARGIN: number = 25;

  /**
   * Picture animation transparency value.
   */
  static readonly OPACITY: number = 0.99;

  /**
   * Picture animation duration.
   */
  static readonly DURATION: number = 280;

  /**
   * Device size.
   */
  static readonly DEVICE_SIZE: number = 600;

  /**
   * Card width.
   */
  static readonly CARD_WIDTH: number = 0.9;
}