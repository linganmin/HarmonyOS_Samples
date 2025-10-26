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

import { NavDestinationItem } from '../viewmodel/NavDestinationItem';

export default class Constants {
  /**
   * One hundred percent.
   */
  static readonly ONE_HUNDRED_PERCENT: string = '100%';

  /**
   * Ninety percent.
   */
  static readonly NINETY_PERCENT: string = '90%';

  /**
   * Eighty percent.
   */
  static readonly EIGHTY_PERCENT: string = '80%';

  /**
   * Eighty-five percent.
   */
  static readonly EIGHTY_FIVE_PERCENT: string = '85%';

  /**
   * Rotate angle.
   */
  static readonly ANGLE: number = 45;

  /**
   * Change value.
   */
  static readonly CHANGE_VALUE: number = 77;

  /**
   * Zero.
   */
  static readonly ZERO: number = 0;

  /**
   * Eight hundred.
   */
  static readonly EIGHT_HUNDRED: number = 800;

  /**
   * Two thousand.
   */
  static readonly TWO_THOUSAND: number = 2000;

  /**
   * Three thousand.
   */
  static readonly THREE_THOUSAND: number = 3000;

  /**
   * One hundred.
   */
  static readonly ONE_HUNDRED: number = 100;

  /**
   * Iteration.
   */
  static readonly ITERATION: number = -1;

  /**
   * Negative two.
   */
  static readonly NEGATIVE_TWO: number = -2;

  /**
   * Negative one hundred ninety-seven.
   */
  static readonly ONE_HUNDRED_NINETY_SEVEN: number = -197;

  /**
   * Negative one hundred and fourteen.
   */
  static readonly ONE_HUNDRED_FOURTEEN: number = -114;

  /**
   * Negative one hundred twenty.
   */
  static readonly NEGATIVE_ONE_HUNDRED_TWENTY: number = -120;

  /**
   * Coefficient of movement.
   */
  static readonly COEFFICIENT: number = 2.83;

  /**
   * Twenty.
   */
  static readonly TWENTY: number = 20;

  /**
   * Negative twenty.
   */
  static readonly NEGATIVE_TWENTY: number = -20;

  /**
   * Thirty.
   */
  static readonly THIRTY: number = 30;

  /**
   * One hundred and twenty.
   */
  static readonly ONE_HUNDRED_AND_TWENTY: number = 120;

  /**
   * Three hundred and forty.
   */
  static readonly THREE_HUNDRED_AND_FORTY: number = 340;

    /**
   * Total width.
   */
  static readonly TOTAL_WIDTH: number = 345;

  /**
   * One text width.
   */
  static readonly ONE_TEXT_WIDTH: number = 50;

  /**
   * All text count.
   */
  static readonly ALL_TEXT_COUNT: number = 6;

  /**
   * All margin count.
   */
  static readonly ALL_MARGIN_COUNT: number = 5;

  /**
   * Ninety.
   */
  static readonly NINETY: number = 90;

  /**
   * Ninety five.
   */
  static readonly NINETY_FIVE: number = 95;

  /**
   * Two.
   */
  static readonly TWO: number = 2;

  /**
   * Three.
   */
  static readonly THREE: number = 3;

  /**
   * Four.
   */
  static readonly FOUR: number = 4;

  /**
   * Line move.
   */
  static readonly LINE_MOVE: number = 14;

  /**
   * Line height.
   */
  static readonly LINE_HEIGHT: number = 1;

  /**
   * Line width.
   */
  static readonly LINE_WIDTH: number = 48;

  /**
   * Item divider.
   */
  static readonly ITEM_DIVIDER: number = 5;

  /**
   * Fifty-eight point five.
   */
  static readonly FIFTY_EIGHT_POINT_FIVE: number = 58.5;

  /**
   * Fifty-nine.
   */
  static readonly FIFTY_NINE: number = 59;

  /**
   * Sixty.
   */
  static readonly SIXTY: number = 60;

  /**
   * Negative sixty.
   */
  static readonly NEGATIVE_SIXTY: number = -60;

  /**
   * Forty.
   */
  static readonly FORTY: number = 40;

  /**
   * One hundred forty.
   */
  static readonly ONE_HUNDRED_FORTY: number = 120;

  /**
   * Negative one hundred.
   */
  static readonly NEGATIVE_ONE_HUNDRED: number = -100;

  /**
   * Negative one hundred ten.
   */
  static readonly NEGATIVE_ONE_HUNDRED_TEN: number = -110;

  /**
   * Negative thirty-five.
   */
  static readonly NEGATIVE_THIRTY_FIVE: number = -35;

  /**
   * Negative seventy-five.
   */
  static readonly NEGATIVE_SEVENTY_FIVE: number = -75;

  /**
   * Ten.
   */
  static readonly TEN: number = 10;

  /**
   * Negative twelve.
   */
  static readonly NEGATIVE_TWELVE: number = -12;

  /**
   * Negative twenty-five.
   */
  static readonly NEGATIVE_TWENTY_FIVE: number = -25;

  /**
   * Negative five.
   */
  static readonly NEGATIVE_FIVE: number = -5;

  /**
   * Minus thirty.
   */
  static readonly MINUS_THIRTY: number = -30;

  /**
   * Draw.
   */
  static readonly DRAW: string = '画';

  /**
   * Therefore.
   */
  static readonly THEREFORE: string = '故';

  /**
   * Weir.
   */
  static readonly WEIR: string = '堰';

  /**
   * Communes.
   */
  static readonly COMMUNES: string = '乡';

  /**
   * Hua.
   */
  static readonly HUA: string = '华';

  /**
   * Ancients.
   */
  static readonly ANCIENTS: string = '古';

  /**
   * Hunan.
   */
  static readonly HUNAN: string = '湘';

  /**
   * Word.
   */
  static readonly WORD: string = '古堰画乡';

  /**
   * Destination.
   */
  static readonly NAV_DESTINATION_DATA: NavDestinationItem[] = [
    {
      name: 'TextBoxShowCursor', detail: $r('app.string.word')
    },
    {
      name: 'BottomWithBar', detail: $r('app.string.bottom')
    },
    {
      name: 'BackgroundColorChange', detail: $r('app.string.background')
    }
  ];
}