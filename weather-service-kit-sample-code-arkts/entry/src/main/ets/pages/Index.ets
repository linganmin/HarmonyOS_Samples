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
import { weatherService } from '@kit.WeatherServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State weather: weatherService.Weather = {} as weatherService.Weather;

  build() {
    Scroll() {
      Column() {
        Text('Weather Service Kit')
          .fontSize(20)
          .fontWeight('bold')
          .margin({ bottom: 10 })
          .alignSelf(ItemAlign.Center)

        Button('获取天气数据', { type: ButtonType.Normal, stateEffect: true })
          .borderRadius(8)
          .backgroundColor(0x317aff)
          .width(140)
          .height(40)
          .margin({ bottom: 10 })
          .alignSelf(ItemAlign.Center)
          .onClick(async () => {
            let weatherRequest: weatherService.WeatherRequest = {
              location: {
                latitude: 0,
                longitude: 0
              },
              limitedDatasets: [
                weatherService.Dataset.CURRENT, weatherService.Dataset.DAILY, weatherService.Dataset.HOURLY,
                weatherService.Dataset.MINUTE, weatherService.Dataset.ALERTS, weatherService.Dataset.INDICES,
                weatherService.Dataset.TIDES
              ]
            };

            try {
              let weather: weatherService.Weather = await weatherService.getWeather(weatherRequest);
              hilog.info(0x0000, 'testTag', JSON.stringify(weather));

              this.weather = weather;
            } catch (err) {
              let businessError: BusinessError = err as BusinessError;
              hilog.error(0x0000, 'testTag', JSON.stringify(JSON.stringify(businessError)));
            }
          })

        Text('返回数据一览')
          .fontSize(16)
          .fontWeight('bold')
          .margin({ bottom: 10 })
          .alignSelf(ItemAlign.Center)


        if (this.weather.current) {
          CustomCurrentSheet({ current: this.weather.current })
            .margin({ bottom: 20 })
        }

        if (this.weather.daily) {
          CustomDailySheet({ daily: this.weather.daily })
            .margin({ bottom: 20 })
        }
      }
      .padding(10)
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.light_gray'))
    }
    .height('100%')
    .scrollBar(BarState.Off)
  }
}

@Component
struct CustomCurrentSheet {
  @Prop current: weatherService.CurrentWeather;

  build() {
    Column() {
      Text('实况天气')
        .fontSize(16)
        .fontWeight('bold')
        .margin({ bottom: 10 })

      Row() {
        Text('温度')
          .width('20%')
        Text(`${this.current.temperature}℃`)
          .width('80%')
          .height('36')
          .padding({ left: 15 })
      }

      Divider()
        .height(2)

      Row() {
        Text('湿度')
          .width('20%')
        Text(`${this.current.humidity}%`)
          .width('80%')
          .height('36')
          .padding({ left: 15 })
      }

      Divider()
        .height(2)

      Row() {
        Text('气压')
          .width('20%')
        Text(`${this.current.pressure}hPa`)
          .width('80%')
          .height('36')
          .padding({ left: 15 })
      }

      Divider()
        .height(2)

      Row() {
        Text('风力风向')
          .width('20%')
        Text(`${['未定义', '北', '东北', '东', '东南', '南', '西南', '西南',
          '西北'][this.current.wind.direction]}风 ${this.current.wind.level}级`)
          .width('80%')
          .height('36')
          .padding({ left: 15 })
      }

      Divider()
        .height(2)

      Row() {
        Text('天气现象')
          .width('20%')
        Text(`${this.current.condition.description}`)
          .height('36')
          .padding({ left: 15 })
        Image(this.current.condition.icon)
          .width(36)
          .height(36)
      }

      Divider()
        .height(2)

      Row() {
        Text('能见度')
          .width('20%')
        Text(`${this.current.visibility}Km`)
          .width('80%')
          .height('36')
          .padding({ left: 15 })
      }
    }
    .width('100%')
    .padding(10)
    .borderRadius(15)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
  }
}

@Component
struct CustomDailySheet {
  @Prop daily: weatherService.Forecast<weatherService.DailyWeather>;

  build() {
    Column() {
      Text('多日天气')
        .fontSize(16)
        .fontWeight('bold')
        .margin({ bottom: 10 })

      ForEach(this.daily.forecast.slice(0, 2), (item: weatherService.DailyWeather) => {
        Row() {
          Text('日期')
            .width('20%')
          Text(`${new Date(item.date).getMonth() + 1}月${new Date(item.date).getDate()}日`)
            .width('80%')
            .height('36')
            .padding({ left: 15 })
        }

        Divider()
          .height(2)

        Row() {
          Text('温度')
            .width('20%')
          Text(`${item.lowTemperature}℃ - ${item.highTemperature}℃`)
            .width('80%')
            .height('36')
            .padding({ left: 15 })
        }
      })
    }
    .width('100%')
    .padding(10)
    .borderRadius(15)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
  }
}