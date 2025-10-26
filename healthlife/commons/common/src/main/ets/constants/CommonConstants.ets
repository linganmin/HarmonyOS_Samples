/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

export enum PickerType {
  NONE = 'none',
  TIME = 'time',
  TEXT = 'text'
}

export class CommonConstants {
  // thousandth
  static readonly THOUSANDTH_15: string = '1.5%';
  static readonly THOUSANDTH_33: string = '3.3%';
  static readonly THOUSANDTH_50: string = '5%';
  static readonly THOUSANDTH_66: string = '6.6%';
  static readonly THOUSANDTH_80: string = '8%';
  static readonly THOUSANDTH_100: string = '10%';
  static readonly THOUSANDTH_333: string = '33.3%';
  static readonly THOUSANDTH_400: string = '40%';
  static readonly THOUSANDTH_420: string = '42%';
  static readonly THOUSANDTH_500: string = '50%';
  static readonly THOUSANDTH_560: string = '56%';
  static readonly THOUSANDTH_800: string = '80%';
  static readonly THOUSANDTH_830: string = '83%';
  static readonly THOUSANDTH_880: string = '88%';
  static readonly THOUSANDTH_900: string = '90%';
  static readonly THOUSANDTH_940: string = '94%';
  static readonly THOUSANDTH_1000: string = '100%';
  static readonly PERCENTAGE_100_EXCEPT_7: string = `${100 / 7}%`;
  // default
  static readonly DEFAULT_0: number = 0;
  static readonly DEFAULT_56: number = 56;
  static readonly DEFAULT_100: number = 100;
  static readonly DEFAULT_NEGATIVE_20: number = -20;
  static readonly PERCENT: string = '%';
  // circle radius
  static readonly BORDER_RADIUS_PERCENT_50: string = '50%';
  // symbol glyph click scale
  static readonly SYMBOL_GLYPH_CLICK_SCALE: number = 0.5;
  // zIndex
  static readonly HOME_COMPONENT_Z_INDEX: number = 1;
  // aspect ratio
  static readonly DEFAULT_ASPECT_RATIO: number = 1;
  // flex grow
  static readonly FLEX_GROW_1: number = 1;
  // duration
  static readonly AD_DURATION: number = 3; // 3s
  static readonly LAUNCHER_DELAY_TIME: number = 1000; // 2000ms
  static readonly DURATION_100: number = 100; // 100ms
  static readonly DURATION_200: number = 200; // 200ms
  static readonly DURATION_800: number = 800; // 800ms
  static readonly DURATION_1000: number = 1000; // 1000ms
  // animate
  static readonly ANIMATE_ANGLE_0: number = 0;
  static readonly ANIMATE_ANGLE_360: number = 360;
  static readonly ANIMATE_OPACITY_0: number = 0;
  static readonly ANIMATE_OPACITY_1: number = 1;
  static readonly ANIMATE_SCALE_0: number = 0;
  static readonly ANIMATE_SCALE_1: number = 1;
  static readonly ANIMATE_ROTATE_0: number = 0;
  static readonly ANIMATE_ROTATE_1: number = 1;
  static readonly ANIMATE_ITERATIONS_1: number = 1;
  // font family
  static readonly HARMONY_HEI_TI_MEDIUM: string = 'HarmonyHeiTi-Medium';
  static readonly HARMONY_HEI_TI_BOLD: string = 'HarmonyHeiTi-Bold';
  static readonly HARMONY_HEI_TI: string = 'HarmonyHeiTi';
  static readonly HELVETICA: string = 'Helvetica';
  static readonly PING_FANG_SC_REGULAR: string = 'PingFangSC-Regular';
  // week info
  static readonly WEEK_LEFT_LIMIT: number = 150;
  static readonly WEEK_RIGHT_LIMIT: number = 500;
  static readonly WEEK_DAY_NUM: number = 7;
  static readonly WEEK_SHORTHAND_LIST: Resource[] = [
    $r('app.string.week_shorthand_mon'),
    $r('app.string.week_shorthand_tue'),
    $r('app.string.week_shorthand_wed'),
    $r('app.string.week_shorthand_thu'),
    $r('app.string.week_shorthand_fri'),
    $r('app.string.week_shorthand_sat'),
    $r('app.string.week_shorthand_sun')
  ];
  // task info
  static readonly TASK_NUM = 6;
  static readonly PICKER_RANGE_DRINK: string[] = [
    '0.5',
    '1',
    '1.5',
    '2',
    '2.5',
    '3',
  ];
  static readonly PICKER_RANGE_APPLE: string[] = [
    '1',
    '2',
    '3',
    '4',
    '5'
  ];
  // achievement info
  static readonly ACHIEVEMENT_STORE: string = 'achievementStore';
  static readonly MAX_CONSECUTIVE_DAYS: string = 'maxConsecutiveDays';
  static readonly CURRENT_CONSECUTIVE_DAYS: string = 'currentConsecutiveDays';
  static readonly CURRENT_DAY_STATUS: string = 'currentDayStatus';
  // menu info
  static readonly DEFAULT_MENU_INFO: Resource[] = [
    $r('app.string.mine_personal_data'),
    $r('app.string.mine_check_updates'),
    $r('app.string.mine_about')
  ];
  // Card Constants
  static readonly DEFAULT_DIMENSION_2X2 = 2;
  static readonly DEFAULT_DIMENSION_2X4 = 3;
  static readonly FORM_NAME_AGENCY = "agency";
  static readonly FORM_NAME_PROGRESS = "progress";
}