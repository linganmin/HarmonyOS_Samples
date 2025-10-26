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
import { CommonConstants } from '../common/constants/CommonConstants';

@Entry
@Component
struct Privacy {
  @State visible: Visibility = Visibility.None;
  scroller: Scroller = new Scroller();
  private pointsArr: string[] = ['400vp', '600vp', '800vp'];

  build() {
    Navigation() {
      Stack() {
        Row() {
          Column() {
            Button($r('app.string.button_name1'))
              .onClick(() => {
                if (this.visible === Visibility.Visible) {
                  this.visible = Visibility.None;
                } else {
                  this.visible = Visibility.Visible;
                }
              })
              .fontColor(Color.White)
              .margin({ bottom: $r('app.float.text_size_headline') })
          }
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
        }
        .alignItems(VerticalAlign.Bottom)
        .height(CommonConstants.ONE_HUNDRED_PERCENT)
        Column() {
          GridRow({
            columns: {
              xs: CommonConstants.JANUARY,
              sm: CommonConstants.FOUR,
              md: CommonConstants.EIGHT,
              lg: CommonConstants.TWELVES
            },
            breakpoints: {
              value: this.pointsArr,
              reference: BreakpointsReference.WindowSize
            }
          }) {
            GridCol({
              span: {
                xs: CommonConstants.JANUARY,
                sm: CommonConstants.GRID_COUNT,
                md: CommonConstants.FOUR,
                lg: CommonConstants.EIGHT
              },
              offset: {
                xs: CommonConstants.ZERO,
                sm: CommonConstants.JANUARY,
                md: CommonConstants.GRID_COUNT,
                lg: CommonConstants.GRID_COUNT
              }
            }) {
              Column() {
                Text($r('app.string.button_name2'))
                  .height($r('app.float.button_height1'))
                  .fontSize($r('app.float.font_size3'))
                  .fontWeight(FontWeight.Bold)

                Scroll(this.scroller) {
                  Text() {
                    Span($r('app.string.word1'))
                    Span($r('app.string.toast_text'))
                      .fontColor(Color.Orange)
                      .fontWeight(FontWeight.Bold)
                      .decoration({ type: TextDecorationType.Underline, color: Color.Orange })
                      .onClick(() => {
                        this.getUIContext().getRouter().pushUrl({
                          url: 'pages/Details'
                        })
                      })
                    Span($r('app.string.word2'))
                  }
                  .fontSize($r('app.float.font_size1'))
                  .padding({
                    left: $r('app.float.column_padding'),
                    right: $r('app.float.column_padding')
                  })
                }
                .scrollable(ScrollDirection.Vertical)
                .height($r('app.float.dialog_height'))
                Row({ space: CommonConstants.SPACE_ONE }) {
                  Button($r('app.string.disagree'), { stateEffect: false, buttonStyle: ButtonStyleMode.TEXTUAL})
                    .onClick(() => {
                      if (this.visible === Visibility.Visible) {
                        this.visible = Visibility.None;
                      } else {
                        this.visible = Visibility.Visible;
                      }
                    })
                    .width(CommonConstants.FORTY_PERCENT)
                  Button($r('app.string.agreed'), { type: ButtonType.Capsule })
                    .onClick(() => {
                      if (this.visible === Visibility.Visible) {
                        this.visible = Visibility.None;
                      } else {
                        this.visible = Visibility.Visible;
                      }
                    })
                    .width(CommonConstants.FORTY_PERCENT)
                }
                .alignItems(VerticalAlign.Top)
                .margin({ top: $r('app.float.border_radius1') })
                .height($r('app.float.button_height1'))
              }
              .backgroundColor(Color.White)
              .visibility(this.visible)
              .borderRadius($r('app.float.border_radius3'))
              .width($r('app.float.bind_sheet_height'))
            }
          }
        }
        .width(CommonConstants.NINETY_FIVE_PERCENT)
      }
    }
    .backgroundColor($r('app.color.dialog_background'))
    .title($r('app.string.toast_private_dialog'))
    .titleMode(NavigationTitleMode.Mini)
  }
}