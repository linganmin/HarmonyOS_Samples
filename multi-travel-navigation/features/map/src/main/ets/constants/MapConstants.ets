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
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";

export class MapConstants {
  /**
   * Divider stroke width.
   */
  static readonly STROKE_WIDTH: number = 4;

  /**
   * Footer tab topics.
   */
  static FOOTER_TOPIC_LIST(context: Context): string[] {
    return [
      MapConstants.getString(context, $r('app.string.home').id),
      MapConstants.getString(context, $r('app.string.nearby').id),
      MapConstants.getString(context, $r('app.string.taxi').id),
      MapConstants.getString(context, $r('app.string.mine').id)
    ];
  }

  /**
   * Default latitude.
   */
  static readonly LATITUDE: number = 39.91;

  /**
   * Default longitude.
   */
  static readonly LONGITUDE: number = 116.3975;

  /**
   * Default zoom.
   */
  static readonly ZOOM: number = 15;

  /**
   * Back button margin bottom.
   */
  static readonly BUTTON_BOTTOM: number = 82;

  /**
   * Footer topic icons.
   */
  static readonly FOOTER_TOPIC_ICONS: Resource[] = [$r('app.media.home'), $r('app.media.locate'),
    $r('app.media.taxi'), $r('app.media.my')];

  /**
   * Footer topic icons.
   */
  static readonly FOOTER_TOPIC_ICONS_SELECTED: Resource[] = [$r('app.media.home_selected'),
    $r('app.media.locate_selected'), $r('app.media.taxi_selected'), $r('app.media.my_selected')];

  static getString(context: Context, id: number) {
    let result = '';
    try {
      result = context!.resourceManager.getStringSync(id)
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'RouteConstants',
        `getStringSync failed, error code=${err.code}, message=${err.message}`);
    }
    return result;
  }
}