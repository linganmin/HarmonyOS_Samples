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

import { liveViewManager } from "@kit.LiveViewKit";

export class CommonUtil {

  /**
   * 为实况窗设置天气
   * @param weatherType  天气类型
   * @returns  对应的天气信息
   */
  public static setWeather(weatherType?: CustomerWeatherType): liveViewManager.WeatherInfo {
    if (weatherType) {
      return WEATHER_SAMPLE_DATA[weatherType];
    }

    // 此处开发者可以根据自身业务需要编写设置逻辑,这里 默认不设置
    return {};
  }


  /**
   * 为实况窗设置航班背景（仅适用于航旅出行场景）
   * @param backgroundType   指定的航班背景
   * @returns 对应的航班背景
   */
  public static setFlightBackground(backgroundType?: liveViewManager.BackgroundType): liveViewManager.BackgroundType {
    if (backgroundType) {
      return backgroundType;
    }

    // 此处开发者可以根据自身业务需要编写设置逻辑，这里默认不显示
    return liveViewManager.BackgroundType.SYS_BACKGROUND_UNDEFINED;
  }
}

export enum CustomerWeatherType {
  SUNNY = 'SUNNY',
  CLOUDY = 'CLOUDY',
  LIGHT_RAIN = 'LIGHT_RAIN',
  MODERATE_RAIN = 'MODERATE_RAIN',
  HEAVY_RAIN = 'HEAVY_RAIN',
  LIGHT_SNOW = 'LIGHT_SNOW',
  MODERATE_SNOW = 'MODERATE_SNOW',
  MODERATE_SNOW2 = 'MODERATE_SNOW2',
  HEAVY_SNOW = 'HEAVY_SNOW'
}


/**
 * 天气信息样例 <br/>
 * --CustomerWeatherType.SUNNY  晴天天气类型 <br/>
 * --CustomerWeatherType.CLOUDY  多云天气 <br/>
 * --CustomerWeatherType.LIGHT_RAIN 小雨天气 <br/>
 * --CustomerWeatherType.MODERATE_RAIN 中雨天气<br/>
 * --CustomerWeatherType.HEAVY_RAIN 大雨天气<br/>
 * --CustomerWeatherType.LIGHT_SNOW 小雪天气<br/>
 * --CustomerWeatherType.MODERATE_SNOW 中雪天气<br/>
 * --CustomerWeatherType.MODERATE_SNOW2 中雪天气2(仅温度发生了变化)<br/>
 * --CustomerWeatherType.HEAVY_SNOW 大雪天气<br/>
 *
 */
export const WEATHER_SAMPLE_DATA: Record<string, liveViewManager.WeatherInfo> = {
  [CustomerWeatherType.SUNNY]: {
    weatherType: liveViewManager.WeatherType.WEATHER_TYPE_SUNNY,
    locationType: liveViewManager.WeatherLocationType.LOCATION_TYPE_DESTINATION,
    highTemperature: 33,
    lowTemperature: 28
  },
  [CustomerWeatherType.CLOUDY]: {
    weatherType: liveViewManager.WeatherType.WEATHER_TYPE_CLOUDY,
    locationType: liveViewManager.WeatherLocationType.LOCATION_TYPE_DESTINATION,
    highTemperature: 27,
    lowTemperature: 20
  },
  [CustomerWeatherType.LIGHT_RAIN]: {
    weatherType: liveViewManager.WeatherType.WEATHER_TYPE_LIGHT_RAIN,
    locationType: liveViewManager.WeatherLocationType.LOCATION_TYPE_DESTINATION,
    highTemperature: 25,
    lowTemperature: 18
  },
  [CustomerWeatherType.MODERATE_RAIN]: {
    weatherType: liveViewManager.WeatherType.WEATHER_TYPE_MODERATE_RAIN,
    locationType: liveViewManager.WeatherLocationType.LOCATION_TYPE_DESTINATION,
    highTemperature: 23,
    lowTemperature: 15
  },
  [CustomerWeatherType.HEAVY_RAIN]: {
    weatherType: liveViewManager.WeatherType.WEATHER_TYPE_HEAVY_RAIN,
    locationType: liveViewManager.WeatherLocationType.LOCATION_TYPE_DESTINATION,
    highTemperature: 20,
    lowTemperature: 15
  },
  [CustomerWeatherType.LIGHT_SNOW]: {
    weatherType: liveViewManager.WeatherType.WEATHER_TYPE_LIGHT_SNOW,
    locationType: liveViewManager.WeatherLocationType.LOCATION_TYPE_DESTINATION,
    highTemperature: 8,
    lowTemperature: 1
  },
  [CustomerWeatherType.MODERATE_SNOW]: {
    weatherType: liveViewManager.WeatherType.WEATHER_TYPE_MODERATE_SNOW,
    locationType: liveViewManager.WeatherLocationType.LOCATION_TYPE_DESTINATION,
    highTemperature: 5,
    lowTemperature: -1
  },
  [CustomerWeatherType.MODERATE_SNOW2]: {
    weatherType: liveViewManager.WeatherType.WEATHER_TYPE_MODERATE_SNOW,
    locationType: liveViewManager.WeatherLocationType.LOCATION_TYPE_DESTINATION,
    highTemperature: 1,
    lowTemperature: -6
  },
  [CustomerWeatherType.HEAVY_SNOW]: {
    weatherType: liveViewManager.WeatherType.WEATHER_TYPE_HEAVY_SNOW,
    locationType: liveViewManager.WeatherLocationType.LOCATION_TYPE_DESTINATION,
    highTemperature: 0,
    lowTemperature: -10
  }
}
