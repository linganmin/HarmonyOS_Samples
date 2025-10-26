/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { image } from '@kit.ImageKit';

export class CommonConstants {
  /**
   * Title row width.
   */
  static readonly TITLE_ROW_WEIGHT: string = '50%';

  /**
   * Layout full screen.
   */
  static readonly LAYOUT_FULL_SCREEN: string = '100%';

  /**
   * Edit page height.
   */
  static readonly EDIT_PAGE_HEIGHT: string = '30%';

  /**
   * Image show height.
   */
  static readonly IMAGE_SHOW_HEIGHT: string = '70%';

  /**
   * Slider width.
   */
  static readonly SLIDER_WIDTH: string = '70%';

  /**
   * Loading width and height.
   */
  static readonly LOADING_WH: string = '30%';

  /**
   * Clock wise.
   */
  static readonly CLOCK_WISE: number = 90;

  /**
   * Anti clock.
   */
  static readonly ANTI_CLOCK: number = -90;

  /**
   * Tab menu width.
   */
  static readonly TAB_MENU_WIDTH: number = 24;

  /**
   * Navigation height.
   */
  static readonly NAVIGATION_HEIGHT: number = 56;

  /**
   * Adjust slider value.
   */
  static readonly ADJUST_SLIDER_VALUE: number[] = [100, 100, 100];

  /**
   * Slider min.
   */
  static readonly SLIDER_MIN: number = 1;

  /**
   * Slider step.
   */
  static readonly SLIDER_MAX: number = 100;

  /**
   * Slider step.
   */
  static readonly SLIDER_STEP: number = 10;

  /**
   * Pixel step.
   */
  static readonly PIXEL_STEP: number = 4;

  /**
   * Decimal two.
   */
  static readonly DECIMAL_TWO: number = 2;

  /**
   * Color level max.
   */
  static readonly COLOR_LEVEL_MAX: number = 255;

  /**
   * Convert int.
   */
  static readonly CONVERT_INT: number = 100;

  /**
   * Angle 60.
   */
  static readonly ANGLE_60: number = 60;

  /**
   * Angle 120.
   */
  static readonly ANGLE_120: number = 120;

  /**
   * Angle 240.
   */
  static readonly ANGLE_240: number = 240;

  /**
   * Angle 300.
   */
  static readonly ANGLE_360: number = 360;

  /**
   * Angle 360.
   */
  static readonly MOD_2: number = 2;

  /**
   * Average height and width.
   */
  static readonly AVERAGE_WEIGHT_WIDTH: number = 2;

  /**
   * Crop rate 4:3.
   */
  static readonly CROP_RATE_4_3: number = 0.75;

  /**
   * Crop rate 16:9.
   */
  static readonly CROP_RATE_9_16: number = 9 / 16;

  /**
   * Encode quality.
   */
  static readonly ENCODE_QUALITY: number = 100;

  /**
   * Title space.
   */
  static readonly TITLE_SPACE: number = 0;

  /**
   * Slider mode click.
   */
  static readonly SLIDER_CLICK_MODE: number = 3;

  /**
   * Encode format.
   */
  static readonly ENCODE_FORMAT: string = 'image/jpeg';

  /**
   * Encode file permission.
   */
  static readonly ENCODE_FILE_PERMISSION: string = 'rw';

  /**
   * Adjust worker file.
   */
  static readonly ADJUST_WORKER_FILE = 'entry/ets/workers/AdjustWork.ts';

  /**
   * Image name.
   */
  static readonly IMAGE_PREFIX = 'image';

  /**
   * Image format.
   */
  static readonly IMAGE_FORMAT = '.jpg';

  /**
   * Rawfile name.
   */
  static readonly RAW_FILE_NAME = 'low.jpg';

  static readonly IMG_PROPERTIES_KEYS = [
    image.PropertyKey.ORIENTATION,
    image.PropertyKey.BITS_PER_SAMPLE,
    image.PropertyKey.IMAGE_LENGTH,
    image.PropertyKey.IMAGE_WIDTH,
    image.PropertyKey.SCENE_TYPE,
    image.PropertyKey.ISO_SPEED_RATINGS,
    image.PropertyKey.F_NUMBER,
    image.PropertyKey.DATE_TIME,
    image.PropertyKey.IMAGE_DESCRIPTION,
    image.PropertyKey.MAKE,
    image.PropertyKey.MODEL,
    image.PropertyKey.PHOTO_MODE,
    image.PropertyKey.SENSITIVITY_TYPE,
    image.PropertyKey.ISO_SPEED,
    image.PropertyKey.APERTURE_VALUE,
    image.PropertyKey.METERING_MODE,
    image.PropertyKey.LIGHT_SOURCE,
    image.PropertyKey.FLASH,
    image.PropertyKey.FOCAL_LENGTH,
    image.PropertyKey.PIXEL_X_DIMENSION,
    image.PropertyKey.EXPOSURE_TIME,
  ];
}
