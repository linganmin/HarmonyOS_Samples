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

import { IntroductionTitle } from '../../../../common/IntroductionTitle';
import { TitleBar } from '../../../../common/TitleBar';
import { LEFT_PADDING, RIGHT_PADDING } from '../../ComponentData';
import { ArgumentsControlPanel } from './GridRowControlPanel';

@Extend(Column)
function backgroundStyle() {
  .width('100%')
  .padding(12)
  .borderRadius(16)
  .backgroundColor(Color.White)
  .justifyContent(FlexAlign.SpaceAround)
}

@Entry
@Component
struct GridRowSample {
  @State bgColors: Color[] = [Color.Red, Color.Orange, Color.Yellow, Color.Green, Color.Pink, Color.Grey, Color.Blue, Color.Brown];
  @State currentBp: string = 'unknown';
  @State columns: number = 5;
  @State gutterX: number = 5;
  @State gutterY: number = 10;

  build() {
    Column() {
      TitleBar({ title: $r('app.string.gridrow_title') })
      Scroll() {
        Column() {
          GridRow({
            columns: this.columns,
            gutter: { x: this.gutterX, y: this.gutterY },
            breakpoints: { value: ["400vp", "600vp", "800vp"],
              reference: BreakpointsReference.WindowSize },
            direction: GridRowDirection.Row
          }) {
            ForEach(this.bgColors, (color: Color) => {
              GridCol({ span: { xs: 1, sm: 2, md: 3, lg: 4 }, offset: 0, order: 0 }) {
                Row().width("100%").height("20vp")
              }.borderColor(color).borderWidth(2)
            })
          }.width("100%").height("100%")
          .onBreakpointChange((breakpoint) => {
            this.currentBp = breakpoint;
          })

          IntroductionTitle({ introduction: $r('app.string.gridrow_introdional_arguments') })
          Column() {
            ArgumentsControlPanel(
              {
                columns: $columns,
                gutterX: $gutterX,
                gutterY: $gutterY,
              }
            )
          }
          .backgroundStyle()
        }
        .width('100%')
      }
      .padding({ left: LEFT_PADDING, right: RIGHT_PADDING })
      .margin({ bottom: 80 })
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.background_shallow_grey'))
  }
}