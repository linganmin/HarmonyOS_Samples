/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

export class CommonConstants {
  /**
   * Window util.
   */
  static readonly WINDOW_UTIL: string = 'windowUtil';
  /**
   * Device types.
   */
  static readonly DEVICE_2IN1: string = '2in1';
  /**
   * Margin of window floating.
   */
  static readonly WINDOW_FLOATING_MARGIN: number = 5.2;
  /**
   * Index scenes.
   */
  static readonly INDEX_SCENES: Resource[] = [$r('app.string.short_video'), $r('app.string.detail_page'),
    $r('app.string.waterFlow_page'), $r('app.string.another_scene'), $r('app.string.another_scene'),
    $r('app.string.another_scene'), $r('app.string.another_scene'), $r('app.string.another_scene'),
    $r('app.string.another_scene'), $r('app.string.another_scene'), $r('app.string.another_scene'),
    $r('app.string.another_scene'), $r('app.string.another_scene'), $r('app.string.another_scene'),
    $r('app.string.another_scene')];
  /**
   * Short video tabs.
   */
  static readonly SHORT_VIDEO_TABS: Resource[] =
    [$r('app.string.index'), $r('app.string.friend'), $r('app.string.message'),
      $r('app.string.mine')];
  /**
   * Short video top tabs.
   */
  static readonly SHORT_VIDEO_TOP_TABS: Resource[] = [$r('app.string.recommended'), $r('app.string.follow'),
    $r('app.string.city'), $r('app.string.selected'), $r('app.string.mall'), $r('app.string.live'),
    $r('app.string.society'), $r('app.string.food')];
  /**
   * Icon resources.
   */
  static readonly SIDE_ICONS: Resource[] = [$r('app.media.icon_like'), $r('app.media.icon_star'),
    $r('app.media.icon_message'), $r('app.media.icon_share')];
  /**
   * Icon numbers.
   */
  static readonly ICON_NUMBERS: number[] = [1557, 1142, 566, 147];
  /**
   * User profiles.
   */
  static readonly USER_PROFILES: Resource[] = [$r('app.media.user_profile_1'), $r('app.media.user_profile_2'),
    $r('app.media.user_profile_3')];
  /**
   * User names.
   */
  static readonly USER_NAMES: Resource[] = [$r('app.string.user_name_1'), $r('app.string.user_name_2'),
    $r('app.string.user_name_3')];
  /**
   * User types.
   */
  static readonly USER_TYPES: Resource[] = [$r('app.string.user_type_1'), $r('app.string.user_type_2'),
    $r('app.string.user_type_3')];
  /**
   * Blog descriptions.
   */
  static readonly BLOG_DESCRIPTIONS: Resource[] = [$r('app.string.blog_content_1'), $r('app.string.blog_content_2'),
    $r('app.string.blog_content_3')];
  /**
   * Blog photos.
   */
  static readonly BLOG_PHOTOS: Resource[][] =
    [[$r('app.media.ic_follow_picture1')], [$r('app.media.ic_follow_picture2'),
      $r('app.media.ic_follow_picture3')], [$r('app.media.ic_follow_picture4'), $r('app.media.ic_follow_picture5'),
      $r('app.media.ic_follow_picture6')]];
  /**
   * Breakpoint types.
   */
  static readonly BREAKPOINT_TYPES: string[] = ['xs', 'sm', 'md', 'lg', 'xl'];
  /**
   * Dpi constant.
   */
  static readonly DPI_CONSTANT: number = 160;
  /**
   * Util heights.
   */
  static readonly UTIL_HEIGHTS: number[] = [56, 78, 134];
  /**
   * Index tab name.
   */
  static readonly INDEX_TAB_NAME: Resource = $r('app.string.tab_name');
  /**
   * Font weights.
   */
  static readonly FONT_WEIGHTS: number[] = [500, 700];
  /**
   * Hundred percent.
   */
  static readonly HUNDRED_PERCENT: string = '100%';
  /**
   * Twenty five percent.
   */
  static readonly TWENTY_FIVE_PERCENT: string = '25%';
  /**
   * Opacity.
   */
  static readonly OPACITY: number = 0.6;
  /**
   * List space.
   */
  static readonly LIST_SPACE: number[] = [8, 12];
  /**
   * Time constants.
   */
  static readonly TIME_CONSTANTS: number[] = [300, 2000];
  /**
   * Follow button.
   */
  static readonly FOLLOW_BUTTON: Resource = $r('app.string.follow_button');
  /**
   * Image aspect ratio.
   */
  static readonly IMAGE_ASPECT_RATIO: number = 0.6;
  /**
   * Share button.
   */
  static readonly SHARE_BUTTON: Resource = $r('app.string.share_button');
  /**
   * Dialog constrain.
   */
  static readonly DIALOG_CONSTRAIN: string = '90%';
  /**
   * Top tab height.
   */
  static readonly TOP_TAB_HEIGHT: number = 24;
  /**
   * Bottom tab height.
   */
  static readonly BOTTOM_TAB_HEIGHT: number = 48;
}