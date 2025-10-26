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

export class CameraConstants {
  /**
   * full screen
   */
  public static readonly FULL_PERCENT: string = '100%';
  /**
   * camera selection width
   */
  public static readonly CENTER_WIDTH: string = '40%';
  /**
   * time format
   */
  public static readonly TIME_FORMAT: string = 'mm:ss.SS';
  /**
   * Parameter Configuration button size
   */
  public static readonly IMAGE_HEIGHT: number = 24;
  /**
   * Parameter Configuration button margin
   */
  public static readonly MARGIN: number = 5;
  /**
   * Parameter Configuration button margin top
   */
  public static readonly MARGIN_TOP: number = 40;
  /**
   * camera switch icon size
   */
  public static readonly CAMERA_SWITCH_SIZE: number = 50;
  /**
   * capture icon size
   */
  public static readonly CAPTURE_SIZE: number = 70;
  /**
   * margin top to surface
   */
  public static readonly MARGIN_HEIGHT: number = 10;
  /**
   * dot opacity
   */
  public static readonly OPACITY: number = 0.2;
  /**
   * dot margin left
   */
  public static readonly MARGIN_LEFT: number = 6;
  /**
   * dot position
   */
  public static readonly LEFT_DISTANCE: number = 15;
  /**
   * zoom button size
   */
  public static readonly ZOOM_SIZE: number = 35;
  /**
   * dot size
   */
  public static readonly SMALL_DOT: number = 2;
  /**
   * camera preview size
   */
  public static readonly PREVIEW_WIDTH: number = 2048;
  /**
   * camera preview size
   */
  public static readonly PREVIEW_HEIGHT: number = 1536;
  /**
   * photo size
   */
  public static readonly PHOTO_WIDTH: number = 4160;
  /**
   * photo size
   */
  public static readonly PHOTO_HEIGHT: number = 3120;
  /**
   * camera preview size
   */
  public static readonly FRONT_WIDTH: number = 4096;
  /**
   * camera preview size
   */
  public static readonly FRONT_HEIGHT: number = 3072;
  /**
   * camera shoot ratio
   */
  public static readonly PHOTO_RATIO: number = 4 / 3;
  /**
   * video record ratio
   */
  public static readonly VIDEO_RATIO: number = 16 / 9;
  /**
   * burst capture count step
   */
  public static readonly BURST_CAPTURE_STEP: number = 5;
  /**
   * minimum burst capture count
   */
  public static readonly BURST_CAPTURE_MIN_COUNT: number = 5;
  /**
   * maximum burst capture count
   */
  public static readonly BURST_CAPTURE_MAX_COUNT: number = 100;
}