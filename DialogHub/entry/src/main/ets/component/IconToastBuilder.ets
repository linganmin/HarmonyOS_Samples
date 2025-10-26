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
import CommonConstant from "../utils/CommonConstant"

@Builder
export function IconToastBuilder() {
  Column() {
    Image($r('app.media.icon_success')).width(CommonConstant.HALF_FULL_LENGTH).height(CommonConstant.HALF_FULL_LENGTH)
    Text($r('app.string.IconToastBuilderText'))
      .fontSize($r('app.float.font_size_regular'))
      .fontColor($r('app.color.base_blue'))
      .margin({ top: $r('app.float.IconToastBuilderMargin') })
  }
  .justifyContent(FlexAlign.Center)
  .height($r('app.float.IconToastBuilderHeight'))
  .width($r('app.float.IconToastBuilderWidth'))
}