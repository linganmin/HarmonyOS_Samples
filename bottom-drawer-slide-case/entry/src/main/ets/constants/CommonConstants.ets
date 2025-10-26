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

import { SettingItem } from '../utils/SettingItem';

export class CommonConstants {
  /**
   * Full percent.
   */
  static readonly FULL_PERCENT: string = '100%';

  /**
   * Height of the slide-down list.
   */
  static readonly SLIDE_DOWN_LIST_HEIGHT: string = '80%';

  /**
   * Panel Animation Duration.
   */
  static readonly PANEL_ANIMATION_DURATION: number = 500;

  /**
   * Status head Animation Duration.
   */
  static readonly STATUS_HEAD_ANIMATION_DURATION: number = 200;

  /**
   * Animation Play Times.
   */
  static readonly ANIMATION_PLAY_TIMES: number = 1;

  /**
   * Pan gesture fingers.
   */
  static readonly PAN_GESTURE_FINGERS: number = 1;

  /**
   * Height of the title at the top of the list.
   */
  static readonly LIST_HEADER_HEIGHT: number = 60;

  /**
   * Height of the page status bar title.
   */
  static readonly PAGE_HEADER_HEIGHT: number = 62;

  /**
   * Height of the first item in the list.
   */
  static readonly FIRST_LIST_ITEM_HEIGHT: number = 131;

  /**
   * Home top align rules.
   */
  static readonly HOME_TOP_ALIGN_RULES: AlignRuleOption = {
    'top': { 'anchor': '__container', 'align': VerticalAlign.Top },
    'left': { 'anchor': '__container', 'align': HorizontalAlign.Start },
    'right': { 'anchor': '__container', 'align': HorizontalAlign.End }
  };

  /**
   * List align rules.
   */
  static readonly LIST_ALIGN_RULES: AlignRuleOption = {
    'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
    'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start },
    'right': { 'anchor': '__container__', 'align': HorizontalAlign.End }
  };

  /**
   * List top title align rules.
   */
  static readonly LIST_TITLE_ALIGN_RULES: AlignRuleOption = {
    'bottom': { 'anchor': 'scrollPart', 'align': VerticalAlign.Top },
    'left': { 'anchor': '__container', 'align': HorizontalAlign.Start },
    'right': { 'anchor': '__container', 'align': HorizontalAlign.End }
  };

  /**
   * List image data.
   */
  static readonly LIST_IMAGE_DATA: SettingItem[] = [
    new SettingItem(1001),
    new SettingItem(1002),
    new SettingItem(1003),
    new SettingItem(1004),
    new SettingItem(1005),
    new SettingItem(1006),
    new SettingItem(1007),
    new SettingItem(1008)
  ]
}