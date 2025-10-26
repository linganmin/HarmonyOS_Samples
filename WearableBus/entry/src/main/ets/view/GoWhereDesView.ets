/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { CommonConstants } from '../common/CommonConstants';

@Component
export struct GoWhereDesView {
  private roadData: Array<number> = [0, 1];

  build() {
    Scroll() {
      Column() {
        this.itemHead();
        List({ space: 8 }) {
          ForEach(this.roadData, (_: number) => {
            ListItem() {
              this.itemRoad();
            }
          }, (item: number) => JSON.stringify(item))
        }
        .margin({ top: 12 })
        .scrollBar(BarState.Off)
        .width(CommonConstants.FULL_PERCENT)
      }
    }
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor('#141414')
    .borderRadius('50%')
  }

  @Builder
  itemHead() {
    Column() {
      Text($r('app.string.road_plan'))
        .fontSize(19)
        .lineHeight(25)
        .fontWeight(700)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .margin({ top: 17 })
        .width(CommonConstants.FULL_PERCENT)
    }
  }

  @Builder
  itemRoad() {
    Column() {
      Column() {
        Row() {
          Text($r('app.string.time'))
            .fontSize(20)
            .fontWeight(500)
            .lineHeight(27)
            .fontColor(Color.White)
          Row() {
            SymbolGlyph($r('sys.symbol.figure_walk'))
              .fontSize(16)
              .fontColor([Color.White])
            Text($r('app.string.road_distance'))
              .fontSize(14)
              .lineHeight(19)
              .fontWeight(400)
              .fontColor(Color.White)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .layoutWeight(1)
          .padding({ left: 50 })
        }
        .padding({
          left: 28,
          right: 28
        })
        .width(CommonConstants.FULL_PERCENT)
        .margin({ top: 8 })

        Row() {
          Text($r('app.string.plan'))
            .fontSize(14)
            .fontWeight(500)
            .lineHeight(19)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor(Color.White)
          Text($r('app.string.car'))
            .fontSize(14)
            .fontWeight(500)
            .lineHeight(19)
            .fontColor($r('sys.color.font_on_secondary'))
            .margin({ left: 36 })
        }
        .padding({
          left: 8,
          right: 8
        })
        .width(CommonConstants.FULL_PERCENT)
        .margin({ top: 4 })

        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.bus_fill'))
              .fontSize(16)
              .fontColor([Color.White])
              .margin({ left: 8 })
            Text($r('app.string.station_1'))
              .fontSize(14)
              .lineHeight(19)
              .fontWeight(500)
              .fontColor(Color.White)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: 3 })
          }
          .width(73)
          .height(31)
          .backgroundColor('#317AF7')
          .borderRadius(72)
          .margin({
            left: 46,
            top: 8
          })

          SymbolGlyph($r('sys.symbol.arrowtriangle_up_fill'))
            .fontSize(8)
            .fontColor([Color.White])
            .margin({
              left: 3,
              top: 6
            })
            .rotate({
              angle: 90
            })
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .width(224)
      .height(112)
      .borderRadius(54)
      .backgroundColor('#26FFFFFF')
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}

@Builder
function goWhereDesBuilder(name: string): void {
  if (name === CommonConstants.NAV_GO_WHERE_PATH_DES) {
    NavDestination() {
      GoWhereDesView();
    }
    .hideTitleBar(true)
  }
}

export const wrappedBuilderGoWherePathDes: WrappedBuilder<[string]> =
  wrapBuilder(goWhereDesBuilder);