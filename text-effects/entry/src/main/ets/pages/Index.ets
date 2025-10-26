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

import Constants from '../constants/Constants';
import TextGradientView from '../view/TextGradientView';
import TextMarqueeView from '../view/TextMarqueeView';
import TextReflectionView from '../view/TextReflectionView';
import TextScrollingView from '../view/TextScrollingView';

@Entry
@Component
struct Index {
  @State message: ResourceStr = $r('app.string.text_content');
  @State messageLong: ResourceStr = $r('app.string.text_content_long');
  @State value: number = 0;

  @Styles
  fancy() {
    .borderRadius($r('app.float.row_border_radius'))
    .backgroundColor(Color.White)
    .padding({
      top: $r('app.float.row_padding'),
      bottom: $r('app.float.row_padding')
    })
    .width(Constants.FULL_PERCENT)
  }

  @Builder
  textBuilder(value: ResourceStr) {
    Row() {
      Text(value)
        .fontSize($r("app.float.title_font_size"))
        .fontColor($r('app.color.title_font_color'))
        .fontWeight(Constants.FONT_WEIGHT_500)
        .margin({ top: $r('app.float.title_margin_bottom') })
        .lineHeight($r('app.float.title_line_height'))
    }
    .width(Constants.FULL_PERCENT)
    .height($r('app.float.title_row_height'))
    .margin({ bottom: $r('app.float.title_row_margin_bottom') })
  }

  build() {
    Navigation() {
      Column() {
        this.textBuilder($r('app.string.text_gradient'))
        Row() {
          TextGradientView({ message: this.message })
        }
        .fancy()
        .justifyContent(FlexAlign.Center)

        this.textBuilder($r('app.string.text_scrolling'))
        Row() {
          TextScrollingView({ message: this.message })
        }
        .fancy()
        .justifyContent(FlexAlign.Center)

        this.textBuilder($r('app.string.text_reflection'))
        Row() {
          TextReflectionView({ message: this.message })
        }
        .fancy()
        .justifyContent(FlexAlign.Center)

        this.textBuilder($r('app.string.text_marquee'))
        Row() {
          TextMarqueeView({ message: this.messageLong })
        }
        .fancy()
        .justifyContent(FlexAlign.Center)
      }
      .padding({
        left: $r('app.float.area_padding_left'),
        right: $r('app.float.area_padding_left')
      })
    }
    .height(Constants.FULL_PERCENT)
    .width(Constants.FULL_PERCENT)
    .title($r('app.string.title'))
    .backgroundColor($r('app.color.page_background_color'))
    .mode(NavigationMode.Stack)
  }
}