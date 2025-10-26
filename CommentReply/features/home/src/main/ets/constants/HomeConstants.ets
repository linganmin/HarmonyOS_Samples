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

export class HomeConstants {
  /**
   * Size of component
   */
  static readonly FIFTH_SIZE: string = '5%';
  static readonly FIFTEEN_SIZE: string = '15%';
  static readonly TWENTY_SIZE: string = '20%';
  static readonly FOURTH_SIZE: string = '40%';
  static readonly FIFTY_SIZE: string = '50%';
  static readonly SIXTY_SIZE: string = '60%';
  static readonly SEVENTY_SIZE: string = '75%';
  static readonly EIGHTY_SIZE: string = '80%';
  static readonly FULL_SIZE: string = '100%';

  /**
   * Text of tabs
   */
  static readonly tabBarTitles: ResourceStr[] = [$r('app.string.tab1'), $r('app.string.tab2'), '', $r('app.string.tab4'), $r('app.string.tab5')];

  /**
   * Constants of window size.
   */
  static readonly HALF_WINDOW: number = 12;
  static readonly FULL_WINDOW: number = 24;

  /**
   * Size of space
   */
  static readonly MEDIUM_SPACE: number = 20;
  static readonly SMALL_SPACE: number = 10;

  static readonly OPERATE_BUTTON_COUNTS: number[] = [1557, 566, 147];
}