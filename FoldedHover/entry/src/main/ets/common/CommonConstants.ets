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

export class CommonConstants {
  /**
   * Page Names.
   */
  static readonly PAGE_NAMES: string[] = ['FoldStack', 'FoldSplitContainer', 'Custom'];

  /**
   * Page titles.
   */
  static readonly PAGE_TITLES: Resource[] = [
    $r('app.string.FoldStackComponent'),
    $r('app.string.FoldSplitContainerComponent'),
    $r('app.string.CustomComponent')];

  /**
   * Window util.
   */
  static readonly WINDOW_UTIL: string = 'windowUtil';

  /**
   * X component id.
   */
  static readonly X_COMPONENT_ID: string = 'videoPlayer';

  /**
   * Video aspect ratio.
   */
  static readonly VIDEO_ASPECT_RATIO: number = 1.78;

  /**
   * Update time of av player.
   */
  static readonly AV_PLAYER_UPDATE_TIME: string = 'updateTime';

  /**
   * Current time of av player.
   */
  static readonly AV_PLAYER_CURRENT_TIME: string = 'currentTime';

  /**
   * Total time of av player.
   */
  static readonly AV_PLAYER_TOTAL_TIME: string = 'totalTime';

  /**
   * Progress of av player.
   */
  static readonly AV_PLAYER_PROGRESS: string = 'progress';

  /**
   * One hundred for progress.
   */
  static readonly PROGRESS_HUNDRED: number = 100;

  /**
   * One thousand for progress.
   */
  static readonly PROGRESS_THOUSAND: number = 1000;

  /**
   * Product video name.
   */
  static readonly PRODUCT_VIDEO_NAME: string = 'product.mp4';

  /**
   * Second in hour.
   */
  static readonly SECOND_IN_HOUR: number = 3600;

  /**
   * Second in minute.
   */
  static readonly SECOND_IN_MINUTE: number = 60;

  /**
   * colon.
   */
  static readonly COLON: string = ':';

  /**
   * Time prefix.
   */
  static readonly TIME_PREFIX: string = '0';

  /**
   * Empty time.
   */
  static readonly EMPTY_TIME: string = '00';

  /**
   * Breakpoints that represent small device types.
   */
  static readonly BREAKPOINT_SM: string = 'sm';

  /**
   * Breakpoints that represent middle device types.
   */
  static readonly BREAKPOINT_MD: string = 'md';

  /**
   * Breakpoints that represent large device types.
   */
  static readonly BREAKPOINT_LG: string = 'lg';

  /**
   * Player text list.
   */
  static readonly PLAYER_TEXT_LIST: ResourceStr[] = [
    $r('app.string.selections'),
    $r('app.string.super'),
    $r('app.string.speed')];
}