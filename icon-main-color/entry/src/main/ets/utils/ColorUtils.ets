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
import CommonConstants from '../constants/CommonContants';

/**
 * RGB color type
 */
export interface ColorRgb {
  red: number;
  green: number;
  blue: number;
  alpha: number;
}

/**
 * HSV color type
 */
export interface ColorHsv {
  hue: number;
  saturation: number;
  value: number;
  alpha: number;
}

export class ColorUtils {
  /**
   * Convert RGB format to HSV format，Formula reference "resources/base/media/rgb_to_hsv.png"
   */
  public static rgb2hsv(color: ColorRgb): ColorHsv {
    const red: number = color.red / CommonConstants.MAX_RGB_VALUE;
    const green: number = color.green / CommonConstants.MAX_RGB_VALUE;
    const blue: number = color.blue / CommonConstants.MAX_RGB_VALUE;

    const max: number = Math.max(red, green, blue);
    const min: number = Math.min(red, green, blue);
    const delta: number = max - min;

    let hue: number = 0;
    let saturation: number = 0;
    let value: number = 0;
    if (max === min) {
      hue = 0;
    } else if (Math.abs(max - red) < Number.EPSILON) {
      hue = (green >= blue ? ((green - blue) / delta) * CommonConstants.RGB_TO_HSV_60 :
        ((green - blue) / delta) * CommonConstants.RGB_TO_HSV_60 + CommonConstants.RGB_TO_HSV_360);
    } else if (Math.abs(max - green) < Number.EPSILON) {
      hue = (((blue - red) / delta) + CommonConstants.RGB_TO_HSV_2) * CommonConstants.RGB_TO_HSV_60;
    } else if (Math.abs(max - blue) < Number.EPSILON) {
      hue = (((red - green) / delta) + CommonConstants.RGB_TO_HSV_4) * CommonConstants.RGB_TO_HSV_60;
    }
    saturation = (max === 0 ? 0 : delta / max);
    value = max;

    return {
      hue: hue,
      saturation: saturation,
      value: value,
      alpha: color.alpha
    }
  }

  /**
   * Convert HSV format to RGB format，Formula reference "resources/base/media/hsv_to_rgb.png"
   */
  public static hsv2rgb(color: ColorHsv): ColorRgb {
    const h60: number = color.hue / CommonConstants.HSV_TO_RGB_60;
    const h60f: number = Math.floor(h60);
    const hi: number = h60f % CommonConstants.HSV_TO_RGB_6;
    const f: number = h60 - h60f;
    const p: number = color.value * (1 - color.saturation);
    const q: number = color.value * (1 - f * color.saturation);
    const t: number = color.value * (1 - (1 - f) * color.saturation);

    let red: number = 0.0;
    let green: number = 0.0;
    let blue: number = 0.0;
    if (hi === 0) {
      red = color.value;
      green = t;
      blue = p;
    } else if (hi === CommonConstants.HSV_TO_RGB_REMAINDER_1) {
      red = q;
      green = color.value;
      blue = p;
    } else if (hi === CommonConstants.HSV_TO_RGB_REMAINDER_2) {
      red = p;
      green = color.value;
      blue = t;
    } else if (hi === CommonConstants.HSV_TO_RGB_REMAINDER_3) {
      red = p;
      green = q;
      blue = color.value;
    } else if (hi === CommonConstants.HSV_TO_RGB_REMAINDER_4) {
      red = t;
      green = p;
      blue = color.value;
    } else if (hi === CommonConstants.HSV_TO_RGB_REMAINDER_5) {
      red = color.value;
      green = p;
      blue = q;
    }

    return {
      red: Math.floor(red * CommonConstants.MAX_RGB_VALUE),
      green: Math.floor(green * CommonConstants.MAX_RGB_VALUE),
      blue: Math.floor(blue * CommonConstants.MAX_RGB_VALUE),
      alpha: color.alpha
    }
  }

  /**
   * Convert RGB color value to integer value
   */
  public static rgbToNumber(color: ColorRgb): number {
    return ((color.alpha << CommonConstants.BIT_24) | (color.red << CommonConstants.BIT_16) |
      (color.green << CommonConstants.BIT_8) | color.blue);
  }

  /**
   * Convert integer value to RGB color value
   */
  public static numberToRgb(color: number): ColorRgb {
    return {
      red: (color & 0xFF0000) >> CommonConstants.BIT_16,
      green: (color & 0xFF00) >> CommonConstants.BIT_8,
      blue: (color & 0xFF),
      alpha: (color & 0xFF000000) >> CommonConstants.BIT_24
    }
  }
}