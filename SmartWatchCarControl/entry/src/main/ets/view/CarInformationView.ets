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

@Component
export struct CarInformationView {
  @State time: string = '';

  aboutToAppear(): void {
    const data = new Date();
    const hour = data.getHours().toString().padStart(2, '0');
    const minute = data.getMinutes().toString().padStart(2, '0');
    this.time = hour + ':' + minute;
  }

  build() {
    Column() {
      Text($r('app.string.car_name'))
        .fontSize(19)
        .fontWeight(700)
        .fontColor($r('sys.color.white'))
        .margin({ top: 20 })
      Row() {
        Image($r('app.media.synthesis'))
          .width(20)
          .height(14)
          .borderRadius(2)
          .padding(2)
        Text('960')
          .fontSize(15)
          .fontWeight(400)
          .fontColor($r('sys.color.white'))
          .margin({
            left: 4
          , right: 4
          })
        Text('KM')
          .fontSize(15)
          .fontColor($r('sys.color.font_on_secondary'))
      }
      .margin({ top: 4 })
      .width('100%')
      .height('10%')
      .justifyContent(FlexAlign.Center)

      Row() {
        Column() {
          Image($r('app.media.electric'))
            .width(25.67)
            .margin({ bottom: 3 })
          Text('660')
            .fontSize(24)
            .fontWeight(700)
            .fontColor($r('sys.color.white'))
            .margin({ bottom: 3 })
          Text('KM')
            .fontSize(13)
            .fontColor($r('sys.color.font_on_secondary'))
        }

        Image($r('app.media.logo'))
          .width(108)
          .height(108)

        Column() {
          Image($r('app.media.gasoline'))
            .width(25.67)
            .margin({ bottom: 3 })
          Text('300')
            .fontSize(24)
            .fontWeight(700)
            .fontColor($r('sys.color.white'))
            .margin({ bottom: 3 })
          Text('KM')
            .fontSize(13)
            .fontColor($r('sys.color.font_on_secondary'))
        }
      }
      .width('100%')
      .height('53%')
      .justifyContent(FlexAlign.SpaceAround)

      Text($r('app.string.charge_completed'))
        .fontSize(13)
        .fontColor('#FF64BC5C')

      Row() {
        Text($r('app.string.Update'))
          .fontSize(10)
          .fontWeight(400)
          .fontColor($r('sys.color.font_on_secondary'))
        Text(this.time)
          .fontSize(10)
          .fontWeight(400)
          .fontColor($r('sys.color.font_on_secondary'))
      }
      .margin({ top: 3 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}