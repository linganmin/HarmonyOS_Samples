/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import CommonConstants from '../common/CommonConstants';

@Component
export default struct TitleBar {
  private title: Resource = $r('app.string.MainAbility_label');

  build() {
    Row() {
      Text(this.title)
        .fontColor(Color.White)
        .fontSize($r('app.float.title_fontsize'))
        .id('title')
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.EIGHT_PERCENT)
    .constraintSize({ minHeight: $r('app.float.title_min_height') })
    .padding({ left: $r('app.float.title_padding_left'), right: $r('app.float.title_padding_right') })
    .backgroundColor($r('app.color.title_background_color'))
  }
}