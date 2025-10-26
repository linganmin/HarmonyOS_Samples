/*
 * Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { IntroductionTitle } from '../../../../common/IntroductionTitle';
import { TitleBar } from '../../../../common/TitleBar';
import Logger from '../../../../util/Logger';

@Extend(Row)
function rowStyle() {
  .borderRadius(24)
  .width('100%')
  .backgroundColor(Color.White)
  .margin({ left: 12, right: 12 })
}

@Extend(Column)
function columnStyle() {
  .borderRadius(24)
  .width('100%')
  .backgroundColor(Color.White)
  .margin({ left: 12, right: 12 })
}

@Entry
@Component
struct GridSettingsSample {
  @State Number: String[] = ['0', '1', '2', '3'];

  build() {
    Column() {
      TitleBar({ title: $r('app.string.grid_settings') })
      Scroll() {
        Column() {
          IntroductionTitle({ introduction: $r('app.string.grid_edgeEffect_spring') })
          Column() {
            Grid() {
              ForEach(this.Number, (day: string) => {
                ForEach(this.Number, (day: string) => {
                  GridItem() {
                    Text(day)
                      .fontSize(16)
                      .backgroundColor(0x66bbb2cb)
                      .width('100%')
                      .height(80)
                      .textAlign(TextAlign.Center)
                  }
                }, (day: string) => day)
              }, (day: string) => day)
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .columnsGap(10)
            .rowsGap(10)
            .edgeEffect(EdgeEffect.Spring)
            .onScrollIndex((first: number) => {
              Logger.info(first.toString())
            })
            .width('90%')
            .backgroundColor(0x66b6c5d1)
            .height(300)
            .scrollBar(BarState.On)
          }
          .columnStyle()
        }
        .constraintSize({ minHeight: '100%' })
        .padding(12)
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.background_shallow_grey'))
  }
}