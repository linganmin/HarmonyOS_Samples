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

import { Constants } from '../common/constants/Constants';

@Component
@Preview
export struct InfoItemView {
  title: ResourceStr = '';
  msg: ResourceStr = '';

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.float.info_title_font_size'))
        .fontWeight(Constants.INFO_TITLE_FONT_WEIGHT)
        .fontColor(Color.Black)
      Blank()
      Text(this.msg)
        .fontSize($r('app.float.info_msg_font_size'))
        .fontWeight(Constants.INFO_TITLE_FONT_WEIGHT)
        .fontColor($r('sys.color.mask_secondary'))
    }
    .height($r('app.float.info_height'))
    .width(Constants.FULL_PERCENT)
    .padding({
      left: $r('app.float.info_padding_left'),
      right: $r('app.float.info_padding_left')
    })
  }
}