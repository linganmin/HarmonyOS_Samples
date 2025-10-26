/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { ToolBar } from '../view/ToolBar';

@Component
export struct Goods {
  @State phoneCovers: Resource[] = [
    $r('app.media.phone_small_1'),
    $r('app.media.phone_small_2'),
    $r('app.media.phone_small_2'),
    $r('app.media.phone_small_2'),
    $r('app.media.phone_small_2'),
    $r('app.media.phone_small_2'),
    $r('app.media.phone_small_2'),
  ];

  @Builder
  phoneCover(img: Resource) {
    Column() {
      Image(img)
        .width('100%')
    }
    .width(36)
    .height(36)
    .backgroundColor($r('app.color.color1'))
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  timeBox(text: ResourceStr) {
    Text(text)
      .width(16)
      .height(16)
      .fontColor(Color.White)
      .borderRadius(2)
      .backgroundColor($r('app.color.color14'))
      .textAlign(TextAlign.End)
      .fontSize(10)
      .fontWeight(500)
      .lineHeight(13)
  }

  @Builder
  tag(text: ResourceStr) {
    Row() {
      Text(text)
        .fontColor($r('app.color.color2'))
        .fontFamily('鸿蒙黑体')
        .fontSize(10)
        .fontWeight(400)
        .lineHeight(13)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .border({ width: 1, color: $r('app.color.color3') })
    .borderRadius(4)
    .linearGradient({
      angle: -75.03,
      colors: [[$r('app.color.color15'), -0.556], [$r('app.color.color16'), 176.794]]
    })
    .padding({
      left: 6,
      right: 6,
      top: 1,
      bottom: 2
    })
    .margin({ right: 4 })
    .height(17)
    .constraintSize({ maxWidth: 90 })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Scroll() {
          Column() {
            Column() {
              Stack({ alignContent: Alignment.Bottom }) {
                RelativeContainer() {
                  Row() {
                    Image($r('app.media.goods'))
                      .width('100%')
                  }
                  .width(240)
                  .height(240)
                  .id('goods')
                  .alignRules({
                    center: { anchor: '__container__', align: VerticalAlign.Center },
                    middle: { anchor: '__container__', align: HorizontalAlign.Center }
                  })

                  Column() {
                    Image($r('app.media.icon_video'))
                      .width(24)
                      .height(24)
                      .margin({ bottom: 4 })
                    Text($r('app.string.living'))
                      .fontWeight(400)
                      .fontSize(10)
                      .lineHeight(15)
                  }
                  .width(48)
                  .height(58)
                  .borderRadius(8)
                  .backgroundColor($r('app.color.color5'))
                  .border({
                    width: 0.5,
                    color: $r('app.color.color17')
                  })
                  .justifyContent(FlexAlign.Center)
                  .alignRules({
                    center: { anchor: '__container__', align: VerticalAlign.Center },
                    right: { anchor: '__container__', align: HorizontalAlign.End },
                  })
                  .id('live_entry')

                  Row() {
                    Text('1/5')
                      .fontColor(Color.White)
                      .fontSize(10)
                      .lineHeight(13)
                      .fontWeight(400)
                  }
                  .width(36)
                  .height(16)
                  .borderRadius(8)
                  .backgroundColor($r('app.color.color6'))
                  .justifyContent(FlexAlign.Center)
                  .alignRules({
                    right: { anchor: '__container__', align: HorizontalAlign.End },
                    bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                  })
                  .id('page_divider')

                  Image($r('app.media.back'))
                    .width(30)
                    .alignRules({
                      left: { anchor: '__container__', align: HorizontalAlign.Start },
                      top: { anchor: '__container__', align: VerticalAlign.Top },
                    })
                    .id('back')
                  Image($r('app.media.more'))
                    .width(30)
                    .alignRules({
                      right: { anchor: '__container__', align: HorizontalAlign.End },
                      top: { anchor: '__container__', align: VerticalAlign.Top },
                    })
                    .id('more')

                }
                .height(310)
                .padding({
                  left: 16,
                  right: 16,
                  top: 4,
                  bottom: 8
                })
                .backgroundColor(Color.White)
              }

              Column() {
                Row() {
                  Text('3D')
                    .fontColor(Color.Black)
                    .fontFamily('鸿蒙黑体')
                    .fontSize(12)
                    .fontWeight(400)
                    .lineHeight(16)
                    .margin({ left: 12 })

                  Image($r('app.media.arrow'))
                    .width(3.37)
                    .opacity(0.4)
                    .margin({ left: 4.5 })

                  Text($r('app.string.comparison_type'))
                    .fontColor(Color.Black)
                    .fontFamily('鸿蒙黑体')
                    .fontSize(12)
                    .fontWeight(400)
                    .margin({ left: 10.13 })
                    .lineHeight(16)
                    .width(48)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Image($r('app.media.arrow'))
                    .width(3.37)
                    .margin({ left: 5.5 })
                    .opacity(0.4)
                }
                .width(112)
                .height(24)
                .borderRadius(12)
                .backgroundColor($r('app.color.color7'))
                .margin({ bottom: 12 })

                Row() {
                  ForEach(this.phoneCovers, (item: Resource) => {
                    this.phoneCover(item)
                  }, (item: Resource, index: number) => JSON.stringify(item) + index)
                }
                .width('100%')
                .height(36)
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .height(96)
              .padding({
                top: 12,
                bottom: 12,
                left: 30,
                right: 30
              })
              .backgroundColor(Color.White)
            }

            Column() {
              Column() {
                Row() {
                  Row() {
                    Text('¥12999')
                      .fontColor(Color.White)
                      .fontSize(22)
                      .fontWeight(500)
                      .lineHeight(18)
                      .margin({ right: 11 })
                    Text('¥13999')
                      .fontColor(Color.White)
                      .fontSize(12)
                      .fontWeight(500)
                      .lineHeight(16)
                      .decoration({
                        type: TextDecorationType.LineThrough,
                        color: Color.White
                      })
                      .opacity(0.6)
                  }

                  Row() {
                    Text($r('app.string.time_remaining'))
                      .fontColor(Color.White)
                      .fontSize(9)
                      .fontWeight(500)
                      .lineHeight(12)
                      .margin({ right: 2 })
                    this.timeBox('07')
                    Text(':')
                      .fontColor(Color.White)
                      .fontSize(10)
                      .fontWeight(500)
                      .lineHeight(13)
                      .width(3)
                      .height(14)
                      .margin({ right: 2 })
                    this.timeBox('14')
                    Text(':')
                      .fontColor(Color.White)
                      .fontSize(10)
                      .fontWeight(500)
                      .lineHeight(13)
                      .width(3)
                      .height(14)
                      .margin({ right: 2 })
                    this.timeBox('50')
                  }
                }                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({ left: 8, right: 12 })
                .height(54)
                .borderRadius(8)
                .linearGradient({
                  angle: -52.67,
                  colors: [[$r('app.color.color2'), -29.533], [$r('app.color.color18'), 146.41]]
                })
                .margin({ bottom: 8 })

                Row() {
                  Text($r('app.string.interest_free_periods'))
                    .fontColor($r('app.color.color13'))
                    .fontSize(12)
                    .fontWeight(400)
                    .lineHeight(16)
                  Image($r('app.media.arrow'))
                    .width(4.5)
                    .opacity(0.4)

                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ bottom: 8 })

                Row() {
                  Row() {
                    this.tag($r('app.string.gift'))
                    this.tag($r('app.string.limited_time_discount'))
                    this.tag($r('app.string.trade_in_subsidy'))
                  }

                  Row() {
                    Text($r('app.string.promotion'))
                      .fontColor(Color.White)
                      .fontSize(12)
                      .fontWeight(500)
                      .lineHeight(16)
                      .maxLines(1)
                      .width(24)
                      .height(16)
                      .textAlign(TextAlign.Center)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width(56)
                  .height(20)
                  .borderRadius(14)
                  .backgroundColor($r('app.color.color8'))
                  .justifyContent(FlexAlign.Center)
                  .alignItems(VerticalAlign.Center)
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ bottom: 8 })

                Row() {
                  Row() {
                    Image($r('app.media.gps'))
                      .width(12)
                      .height(12)
                      .margin({ right: 4 })
                    Text($r('app.string.location'))
                      .fontColor($r('app.color.color13'))
                      .fontSize(12)
                      .fontWeight(400)
                      .lineHeight(16)
                  }

                  Image($r('app.media.arrow'))
                    .width(4.5)
                    .opacity(0.4)
                }
                .width('100%')
                .margin({ bottom: 4 })
                .justifyContent(FlexAlign.SpaceBetween)

                Row() {
                  Text($r('app.string.stock_status'))
                    .fontColor(Color.Black)
                    .fontSize(12)
                    .fontWeight(400)
                    .lineHeight(16)
                }
                .width('100%')
                .padding({ left: 16 })
                .justifyContent(FlexAlign.Start)

              }
              .padding(12)
              .backgroundColor(Color.White)
              .borderRadius(16)
              .margin({ bottom: 12 })

              Column() {
                Text($r('app.string.product_info'))
                  .fontColor(Color.Black)
                  .fontSize(14)
                  .fontWeight(500)
                  .lineHeight(19)
                  .margin({ bottom: 8 })

                Text($r('app.string.promotion_details'))
                  .fontColor($r('app.color.color9'))
                  .fontSize(12)
                  .fontWeight(400)
                  .lineHeight(18)
                  .margin({ bottom: 14 })

                Row() {
                  Row() {
                    Text($r('app.string.related_product'))
                      .fontColor($r('app.color.color9'))
                      .fontSize(12)
                      .fontWeight(400)
                      .lineHeight(16)
                      .margin({ right: 4 })

                    Text($r('app.string.limited_gift_earphones'))
                      .fontColor(Color.Black)
                      .fontSize(12)
                      .fontWeight(400)
                      .lineHeight(16)
                  }

                  Image($r('app.media.arrow'))
                    .width(4.5)
                    .fillColor($r('app.color.color9'))

                }
                .width('100%')
                .height(24)
                .borderRadius(14)
                .backgroundColor($r('app.color.color10'))
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(VerticalAlign.Center)
                .padding({ left: 8, right: 12 })
              }
              .padding(12)
              .backgroundColor(Color.White)
              .borderRadius(16)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F1F3F5')
          }
          .padding({ bottom: 56 })
        }
        .scrollBar(BarState.Off)

        ToolBar()
      }
    }    .backgroundColor($r('app.color.color1'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      return true;
    })
  }
}