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

export class RouteConstants {
  /**
   * Divider stroke width.
   */
  static readonly STROKE_WIDTH: number = 1;
  /**
   * Text input area width.
   */
  static readonly TEXT_INPUT_WIDTH: string = '60%';
  /**
   * Tab area width.
   */
  static readonly TAB_AREA_WIDTH: string = '80%';
  /**
   * Result list differ height.
   */
  static readonly LIST_DIFFER_HEIGHT: number = 40;

  /**
   * Minutes.
   */
  static MINUTES (context: Context):string {
    return RouteConstants.getString(context, $r('app.string.minutes').id);
  }

  /**
   * Kilometres.
   */
  static KILOMETRES(context: Context): string {
    return RouteConstants.getString(context, $r('app.string.kilometers').id);
  }

  /**
   * Topic icons.
   */
  static readonly TOPIC_ICONS_SELECTED: Resource[] = [$r('app.media.navigate')];

  /**
   * Footer tab topics.
   */
  static TOPIC_LIST(context: Context): string[] {
    return [
      RouteConstants.getString(context, $r('app.string.drive').id),
      RouteConstants.getString(context, $r('app.string.taxi').id),
      RouteConstants.getString(context, $r('app.string.public_transportation').id),
      RouteConstants.getString(context, $r('app.string.cycling').id),
      RouteConstants.getString(context, $r('app.string.walk').id),
      RouteConstants.getString(context, $r('app.string.proxy_driving').id),
      RouteConstants.getString(context, $r('app.string.train').id),
      RouteConstants.getString(context, $r('app.string.passenger_car').id)
    ];
  }

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