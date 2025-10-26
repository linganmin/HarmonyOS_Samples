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

import { Constants } from '../constant/Constant';
import { BreakpointType } from '../utils/BreakpointUtil';
import { TrafficInfoView } from './TrafficInfoView';

@Component
export struct TrafficView {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageLink('horizontalBreakpoint') horizontalBreakpoint: string = Constants.BREAK_POINT_SM;
  @StorageLink('verticalBreakpoint') verticalBreakpoint: string = Constants.BREAK_POINT_SM;
  @StorageLink('lightTime') lightTime: number = 90;
  private uiContext: UIContext = this.getUIContext();
  private updateInterval: number | undefined;

  build() {
    if (this.horizontalBreakpoint !== Constants.BREAK_POINT_SM ||
      this.verticalBreakpoint !== Constants.BREAK_POINT_MD) {
      Column() {
        Row() {
          Column() {
            Column() {
              Row() {
                Image($r('app.media.big_arrow'))
                  .objectFit(ImageFit.Contain)
                  .height(new BreakpointType(80, 70, 70,).getValue(this.horizontalBreakpoint))
                Column() {
                  Text($r('app.string.traffic_info_meter'))
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                    .alignSelf(ItemAlign.Start)
                    .fontSize(40)
                    .margin({
                      top: $r('sys.float.padding_level8'),
                      left: $r('sys.float.padding_level8'),
                    })
                  Text($r('app.string.road_name'))
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Regular)
                    .alignSelf(ItemAlign.Start)
                    .fontSize(24)
                    .margin({
                      left: $r('sys.float.padding_level8'),
                    })
                }
              }
              .borderRadius({
                topLeft: new BreakpointType(0, 16, 16,).getValue(this.horizontalBreakpoint),
                topRight: new BreakpointType(0, 16, 16,).getValue(this.horizontalBreakpoint),
              })
              .backgroundColor($r('app.color.Index_background_first'))
              .width(new BreakpointType('100%', '50%', '30%',).getValue(this.horizontalBreakpoint))
              .padding({
                bottom: $r('sys.float.padding_level8'),
                top: new BreakpointType($r('sys.float.padding_level16'), $r('sys.float.padding_level0'),
                  $r('sys.float.padding_level0'),).getValue(this.horizontalBreakpoint),
                left: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level12'),
                  $r('sys.float.padding_level16'),).getValue(this.horizontalBreakpoint),
              })

              Row() {
                Text($r('app.string.then'))
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Regular)
                  .alignSelf(ItemAlign.Start)
                  .fontSize(22)
                  .margin({
                    left: $r('sys.float.padding_level8'),
                    right: $r('sys.float.padding_level2'),
                  })
                Image($r('app.media.little_arrow'))
                  .objectFit(ImageFit.Contain)
                  .height(25)
              }
              .borderRadius({
                bottomLeft: new BreakpointType(0, 16, 16,).getValue(this.horizontalBreakpoint),
                bottomRight: new BreakpointType(0, 16, 16,).getValue(this.horizontalBreakpoint),
              })
              .padding({
                bottom: $r('sys.float.padding_level2'),
                top: $r('sys.float.padding_level2'),
              })
              .width(new BreakpointType('100%', '50%', '30%',).getValue(this.horizontalBreakpoint))
              .backgroundColor($r('app.color.Index_background_second'))

              if (this.horizontalBreakpoint !== Constants.BREAK_POINT_SM) {
                Image($r('app.media.traffic_info_speed'))
                  .objectFit(ImageFit.Contain)
                  .height(80)
                  .position({
                    top: 0,
                    left: this.horizontalBreakpoint === Constants.BREAK_POINT_MD ? '51%' : '31%',
                  })
                Row() {
                  Stack() {
                    Image($r('app.media.ic_light'))
                      .width(106)
                      .height(52)
                    Text(this.lightTime + '')
                      .fontColor($r('sys.color.white'))
                      .fontSize(30)
                      .margin({ right: 16 })
                  }
                  .alignContent(Alignment.End)
                }
                .padding({
                  right: 16,
                  left: 9
                })
                .position({
                  top: 90,
                  left: this.horizontalBreakpoint === Constants.BREAK_POINT_MD ? '51%' : '31%'
                })
              }
            }

            Row() {
              if (this.horizontalBreakpoint === Constants.BREAK_POINT_SM) {
                Image($r('app.media.traffic_info_speed'))
                  .objectFit(ImageFit.Contain)
                  .height(70)
              }
              Image($r('app.media.traffic_info_label'))
                .objectFit(ImageFit.Contain)
                .height(new BreakpointType(70, 80, 80).getValue(this.horizontalBreakpoint))
            }
            .width(new BreakpointType('100%', '40%', '30%',).getValue(this.horizontalBreakpoint))

            if (this.horizontalBreakpoint === Constants.BREAK_POINT_SM) {
              Row() {
                Stack() {
                  Image($r('app.media.ic_light'))
                    .width(106)
                    .height(52)
                  Text(this.lightTime + '')
                    .fontColor($r('sys.color.white'))
                    .fontSize(30)
                    .margin({ right: 16 })
                }
                .alignContent(Alignment.End)
              }
              .width('100%')
              .justifyContent(FlexAlign.End)
              .padding({
                right: 16
              })
            }
          }
          .margin({
            left: new BreakpointType($r('sys.float.padding_level0'), $r('sys.float.padding_level12'),
              $r('sys.float.padding_level16'),).getValue(this.horizontalBreakpoint),
            top: new BreakpointType($r('sys.float.padding_level0'), $r('sys.float.padding_level16'),
              $r('sys.float.padding_level16'),).getValue(this.horizontalBreakpoint),
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        Blank()

        Row() {
          Column() {
            Divider()
              .strokeWidth(4)
              .color($r('app.color.traffic_info_line'))
              .width($r('sys.float.padding_level24'))
              .lineCap(LineCapStyle.Round)
              .margin({
                top: $r('sys.float.padding_level3'),
                bottom: $r('sys.float.padding_level7')
              })

            TrafficInfoView()
          }
          .height(100)
          .width(new BreakpointType('100%', '300vp', '360vp',).getValue(this.horizontalBreakpoint))
          .borderColor($r('sys.color.comp_divider'))
          .borderRadius({
            topLeft: $r('sys.float.corner_radius_level12'),
            topRight: $r('sys.float.corner_radius_level12'),
            bottomLeft: new BreakpointType($r('sys.float.padding_level0'), $r('sys.float.corner_radius_level12'),
              $r('sys.float.corner_radius_level12'),).getValue(this.horizontalBreakpoint),
            bottomRight: new BreakpointType($r('sys.float.padding_level0'), $r('sys.float.corner_radius_level12'),
              $r('sys.float.corner_radius_level12'),).getValue(this.horizontalBreakpoint),
          })
          .backgroundColor($r('app.color.traffic_info_background_color'))
          .shadow(ShadowStyle.OUTER_DEFAULT_XS)
          .position({
            bottom: 0,
            left: new BreakpointType($r('sys.float.padding_level0'), $r('sys.float.corner_radius_level12'),
              $r('sys.float.corner_radius_level16'),).getValue(this.horizontalBreakpoint),
          })
          .padding({
            bottom: new BreakpointType(this.uiContext.px2vp(this.bottomRectHeight), 0,
              0,).getValue(this.horizontalBreakpoint),
          })
          .margin({
            bottom: new BreakpointType(0, this.uiContext.px2vp(this.bottomRectHeight),
              this.uiContext.px2vp(this.bottomRectHeight),).getValue(this.horizontalBreakpoint),
          })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundImageSize(ImageSize.Cover)
      .backgroundImagePosition(Alignment.Center)
    } else {
      Column() {
        Stack() {
          Image($r('app.media.traffic_info_speed'))
            .objectFit(ImageFit.Contain)
            .height(70)
            .position({
              top: 16,
              left: 16,
            })

          Column({ space: 10 }) {
            Column() {
              Image($r('app.media.turn_right_light_rectangle'))
                .objectFit(ImageFit.Contain)
                .width(40)
                .height(25)
                .margin({
                  top: 8,
                })

              Text($r('app.string.traffic_info_smmd_first'))
                .fontColor(Color.Black)
                .alignSelf(ItemAlign.Start)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin({
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 8,
                })
              Text($r('app.string.traffic_info_smmd_second'))
                .fontColor(Color.Black)
                .alignSelf(ItemAlign.Start)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin({
                  left: 16,
                  right: 16,
                  bottom: 8,
                })
            }
            .justifyContent(FlexAlign.Center)
            .borderRadius(16)
            .backgroundColor($r('sys.color.ohos_id_blur_style_component_thick_color'))
            .backgroundBlurStyle(BlurStyle.Thick)

            Row() {
              Stack() {
                Image($r('app.media.ic_light'))
                  .width(106)
                  .height(52)
                Text(this.lightTime + '')
                  .fontColor($r('sys.color.white'))
                  .fontSize(30)
                  .margin({ right: 16 })
              }
              .alignContent(Alignment.End)
            }
            .padding({
              right: 16
            })
          }
          .position({
            top: 16,
            right: 16
          })


        }
        .width('100%')

        Blank()

        Row() {
          Column() {
            Divider()
              .strokeWidth(4)
              .color($r('app.color.traffic_info_line'))
              .width($r('sys.float.padding_level24'))
              .lineCap(LineCapStyle.Round)
              .margin({
                top: $r('sys.float.padding_level3'),
                bottom: $r('sys.float.padding_level7')
              })

            TrafficInfoView()
          }
          .height(100)
          .width(new BreakpointType('100%', '300vp', '360vp',).getValue(this.horizontalBreakpoint))
          .borderColor($r('sys.color.comp_divider'))
          .borderRadius({
            topLeft: $r('sys.float.corner_radius_level12'),
            topRight: $r('sys.float.corner_radius_level12'),
          })
          .backgroundColor($r('app.color.traffic_info_background_color'))
          .shadow(ShadowStyle.OUTER_DEFAULT_XS)
        }
        .width('100%')
      }
      .height('100%')
    }
  }
}