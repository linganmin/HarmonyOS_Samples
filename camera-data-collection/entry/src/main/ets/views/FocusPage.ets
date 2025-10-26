/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Constants } from '../common/Constants'

// Exposure selection.
@Component
export struct FocusPage {
  @Link focusPointBol: boolean;
  @Link focusPointVal: Array<number>;
  // Display where scale, focal length value, and focus box cannot coexist.
  @Link exposureBol: boolean;
  // Exposure value.
  @Link exposureNum: number;

  @Builder
  BorderBuilder(width: EdgeWidths | Length, radius: Length | BorderRadiuses) {
    Row() {
    }
    .border({
      width: width,
      color: Color.White,
      radius: radius
    })
    .size({
      width: $r('app.float.focus_frame_size'),
      height: $r('app.float.focus_frame_size')
    });
  }

  build() {
    Row() {
      if (this.focusPointBol) {
        if (this.exposureBol) {
          // Focus frame.
          Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              this.BorderBuilder({
                left: $r('app.float.focus_frame_width'),
                top: $r('app.float.focus_frame_width')
              }, {
                topLeft: $r('app.float.focus_frame_radius')
              });
              this.BorderBuilder({
                right: $r('app.float.focus_frame_width'),
                top: $r('app.float.focus_frame_width')
              }, {
                topRight: $r('app.float.focus_frame_radius')
              });
            }

            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              this.BorderBuilder({
                left: $r('app.float.focus_frame_width'),
                bottom: $r('app.float.focus_frame_width')
              }, {
                bottomLeft: $r('app.float.focus_frame_radius')
              });
              this.BorderBuilder({
                right: $r('app.float.focus_frame_width'),
                bottom: $r('app.float.focus_frame_width')
              }, {
                bottomRight: $r('app.float.focus_frame_radius')
              });
            }
          }
          .width($r('app.float.common_50'))
          .height($r('app.float.common_50'))
          .position({
            x: this.focusPointVal[0] - Constants.POSITION_25,
            y: this.focusPointVal[1] - Constants.POSITION_25
          });

        } else {
          // Focus value.
          Text(this.exposureNum + '')
            .fontSize($r('app.float.focus_value_font_size'))
            .fontColor(Color.White)
            .fontWeight(Constants.FONT_WEIGHT_400)
            .position({
              x: this.focusPointVal[0] - Constants.POSITION_58,
              y: this.focusPointVal[1] - Constants.POSITION_30
            });
          // Scale value.
          Flex() {
            Column() {
              Text('+4')
                .fontColor(Color.White);
              Text('0')
                .margin({
                  top: $r('app.float.common_50'),
                  bottom: $r('app.float.common_50')
                })
                .fontColor(Color.White);
              Text('-4')
                .fontColor(Color.White);
            }
            .margin({
              right: $r('app.float.scale_value_margin_right')
            });
            // Scale.
            Column() {
              Text('')
                .height($r('app.float.scale_height_67'))
                .border({
                  width: { right: $r('app.float.scale_width_4') },
                  color: Color.White,
                  radius: $r('app.float.scale_radius_2'),
                  style: BorderStyle.Dotted
                });
              Text('')
                .height($r('app.float.scale_height_8'))
                .border({
                  width: { right: $r('app.float.scale_width_8') },
                  color: Color.White,
                  radius: $r('app.float.scale_radius_4'),
                  style: BorderStyle.Solid
                })
                .margin({ top: $r('app.float.scale_width_4') })
              Text('')
                .height($r('app.float.scale_height_67'))
                .border({
                  width: { right: $r('app.float.scale_width_4') },
                  color: Color.White,
                  radius: $r('app.float.scale_radius_2'),
                  style: BorderStyle.Dotted
                })
                .margin({ top: $r('app.float.scale_width_4') });
            }
          }.position({
            x: this.focusPointVal[0] + Constants.POSITION_95,
            y: this.focusPointVal[1] - Constants.POSITION_73
          });
        }
        // Exposure icon.
        Image($r('app.media.ic_public_brightness'))
          .size({
            width: $r('app.float.exposure_icon_size'),
            height: $r('app.float.exposure_icon_size')
          })
          .position({
            x: this.focusPointVal[0] + Constants.POSITION_40,
            y: this.focusPointVal[1] - Constants.POSITION_10
          });
      }
    }
    .height(Constants.FULL_PERCENT)
    .width(Constants.FULL_PERCENT)
    .id('FocusPage')
  }
}