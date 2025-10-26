/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import CommonConstants from '../common/constants/CommonConstants';

@Component
export struct ShiftKey {
  private color: ResourceStr = $r('app.color.state_styles_normal');
  @Link upper: boolean;

  @Styles
  pressedStyles() {
    .backgroundColor($r('app.color.state_styles_pressed'))
  }

  @Styles
  normalStyles() {
    .backgroundColor(this.color)
  }

  build() {
    Stack() {
      Image(this.upper ? $r('app.media.shift_light') : $r('app.media.shift_normal'))
        .width($r('app.float.shift_image_size'))
        .aspectRatio(CommonConstants.IMAGE_ASPECT_RATIO)
    }
    .backgroundColor($r('app.color.delete_key_background'))
    .borderRadius($r('app.float.comm_image_radius'))
    .onClick(() => this.upper = !this.upper)
    .width(CommonConstants.PERCENTAGE_MAX)
    .height(CommonConstants.PERCENTAGE_MAX)
    .stateStyles({ normal: this.normalStyles, pressed: this.pressedStyles })
  }
}