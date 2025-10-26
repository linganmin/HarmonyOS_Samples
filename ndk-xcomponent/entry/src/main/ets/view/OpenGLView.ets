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

import XComponentContext from '../interface/XComponentContext';
import { CommonConstant as Common }  from '../common/CommonConstant';

@Component
export struct OpenGLView {
  @State currentStatus: ResourceStr = '';
  @State currentIndex: number = 0;
  @State isClick: boolean = true;
  private xComponentContext: XComponentContext | undefined = undefined;

  build() {
    Column() {
      Column() {
        XComponent({
          id: Common.OPENGL_XCOMPONENT_ID,
          type: XComponentType.TEXTURE,
          libraryname: Common.LIBRARY_NAME
        })
          .width($r('app.float.xcomponent_width'))
          .aspectRatio(1)
          .onLoad((xComponentContext) => {
            this.xComponentContext = xComponentContext as XComponentContext;
            this.currentStatus = ' ';
          })
          .borderRadius($r('app.float.xcomponent_border_radius'))
          .backgroundColor(Color.White)

        Text(this.currentStatus)
          .fontSize($r('app.float.status_font_size'))
          .fontColor($r('app.color.status_font_color'))
          .fontWeight(Common.FONT_WEIGHT_500)
          .opacity(Common.TEXT_OPACITY)
          .margin({
            top: $r('app.float.status_margin_top')
          })
      }
      .onClick(() => {
        let hasChangeColor: boolean = false;
        if (this.xComponentContext && this.xComponentContext.getStatus()) {
          hasChangeColor = this.xComponentContext.getStatus().hasChangeColor;
        }
        if (hasChangeColor) {
          this.currentStatus = $r('app.string.status_redraw');
          this.isClick = true;
        }
      })
      .width(Common.FULL_PERCENT)

      Row() {
        Button($r('app.string.draw_star'))
          .fontSize($r('app.float.button_font_size'))
          .fontWeight(Common.FONT_WEIGHT_500)
          .onClick(() => {
            if (this.xComponentContext) {
              this.xComponentContext.drawPattern();
              let hasDraw: boolean = false;
              if (this.xComponentContext.getStatus()) {
                hasDraw = this.xComponentContext.getStatus().hasDraw;
              }
              if (hasDraw) {
                this.currentStatus = $r('app.string.change_color');
                this.isClick = false;
              }
            }
          })
          .width(Common.BUTTON_WIDTH)
          .height($r('app.float.button_height'))
          .margin({
            bottom:$r('app.float.button_margin_bottom')
          })
          .backgroundColor(this.isClick ? $r('app.color.button_clickable') : $r('app.color.button_unclickable'))
          .stateEffect(this.isClick)
      }
      .alignItems(VerticalAlign.Bottom)
      .layoutWeight(1)
    }
    .width(Common.FULL_PERCENT)
    .height(Common.FULL_PERCENT)
  }
}