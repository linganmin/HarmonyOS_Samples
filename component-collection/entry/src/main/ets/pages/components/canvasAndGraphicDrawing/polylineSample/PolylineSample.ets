/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { TitleBar } from '../../../../common/TitleBar';
import { LEFT_PADDING, RIGHT_PADDING } from '../../ComponentData';
import { PolylineControlPanel } from './ChangePanel';

@Extend(Column)
function cardStyle() {
  .backgroundColor($r('app.color.white'))
  .borderRadius(16)
  .width('100%')
  .padding(12)
}

@Entry
@Component
struct PolylineSample {
  @State polylineFirstX: number = 0;
  @State polylineFirstY: number = 0;
  @State polylineSecondX: number = 20;
  @State polylineSecondY: number = 60;
  @State polylineThirdX: number = 100;
  @State polylineThirdY: number = 100;
  @State strokeWidth: number = 3;
  @State stroke: Color = Color.Blue;
  @State strokeDashArray: number = 1;
  @State strokeOpacity: number = 50;

  build() {
    Column() {
      TitleBar({ title: $r('app.string.polyline_title') })
      Column() {
        Column() {
          // Draw a polyline in a 100 * 100 rectangular box, starting from (0, 0), passing through (20,60), and reaching the end point (100, 100)
          Polyline({ width: 100, height: 100 })
            .points([[this.polylineFirstX, this.polylineFirstY], [this.polylineSecondX, this.polylineSecondY], [this.polylineThirdX, this.polylineThirdY]])
            .fillOpacity(0)
            .stroke(this.stroke)
            .strokeWidth(this.strokeWidth)
            .strokeDashArray([this.strokeDashArray])
            .strokeOpacity(this.strokeOpacity / 100)// Set the corners of the polyline to arcs
            .strokeLineJoin(LineJoinStyle.Round)// Set both ends of the polyline to semicircles
            .strokeLineCap(LineCapStyle.Round)
        }.cardStyle()
        .height('35%')
        .margin({ bottom: 10 })

        Column() {
          Scroll() {
            PolylineControlPanel({
              polylineFirstX: $polylineFirstX,
              polylineFirstY: $polylineFirstY,
              polylineSecondX: $polylineSecondX,
              polylineSecondY: $polylineSecondY,
              polylineThirdX: $polylineThirdX,
              polylineThirdY: $polylineThirdY,
              stroke: $stroke,
              strokeWidth: $strokeWidth,
              strokeDashArray: $strokeDashArray,
              strokeOpacity: $strokeOpacity
            })
          }.id('polyline_scroll_1')
        }.cardStyle()
        .layoutWeight(1)
        .margin({ bottom: 4 })
      }.padding({ left: LEFT_PADDING, right: RIGHT_PADDING })
      .layoutWeight(1)
    }
    .backgroundColor($r('app.color.background_light_gray'))
    .height('100%')
  }
}