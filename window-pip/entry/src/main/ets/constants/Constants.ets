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

export class Constants {
  /**
   * NavDestination page name.
   */
  public static readonly NAV_DESTINATION_NAME: string = 'PlayVideo';

  /**
   * Control width.
   */
  public static readonly CONTROL_WIDTH: string = '95%';

  /**
   * NavDestination width.
   */
  public static readonly NAV_DESTINATION_WIDTH: string = '100%';

  /**
   * avDestination height.
   */
  public static readonly NAV_DESTINATION_HEIGHT: string = '100%';

  /**
   * Video1 button width.
   */
  public static readonly VIDEO1_BUTTON_WIDTH: string = '95%';

  /**
   * Video button width.
   */
  public static readonly VIDEO_BUTTON_WIDTH: string = '45%';

  /**
   * XComponent width.
   */
  public static readonly X_COMPONENT_WIDTH: string = '100%';

  /**
   * PIP width.
   */
  public static readonly AUTO_PIP_WIDTH: string = '95%';

  /**
   * Scroll layout width.
   */
  public static readonly SCROLL_LAY_OUT_WEIGHT: number = 1;

  /**
   * Default error information.
   */
  public static readonly ERROR_BY_DEFAULT: string = '无';

  /**
   * Layout Element Spacing.
   */
  public static readonly SPACE: number = 20;

  /**
   * HomePage Element Spacing.
   */
  public static readonly HOME_SPACE: number = 10;

  /**
   * Error type.
   */
  public static readonly AVPLAYER_TYPE: number = 1;

  /**
   * GridRow columns.
   */
  public static readonly GRID_ROW_COLUMNS: number = 2;

  /**
   * GridRow gutter x.
   */
  public static readonly GRID_ROW_X: number = 10;

  /**
   * GridRow gutter y.
   */
  public static readonly GRID_ROW_Y: number = 20;

  /**
   * Column padding.
   */
  public static readonly COLUMNS_PADDING: number = 20;

  /**
   * Idle state.
   */
  public static readonly idle_STATUS: string = 'idle';

  /**
   * Resource Initialization.
   */
  public static readonly INITIALIZED_STATUS: string = 'initialized';

  /**
   * Prepared state.
   */
  public static readonly PREPARED_STATUS: string = 'prepared';

  /**
   * Playing status.
   */
  public static readonly PLAYING_STATUS: string = 'playing';

  /**
   * Paused status.
   */
  public static readonly PAUSED_STATUS: string = 'paused';

  /**
   * Play to end state.
   */
  public static readonly COMPLETED_STATUS: string = 'completed';

  /**
   * Stopped status.
   */
  public static readonly STOPPED_STATUS: string = 'stopped';

  /**
   * Destruction Status.
   */
  public static readonly RELEASED_STATUS: string = 'released';
}