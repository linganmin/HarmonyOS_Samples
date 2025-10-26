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

export class ProgressParams {
  constructor(text: string, value: number, total: number) {
    this.text = text;
    this.value = value;
    this.total = total;
  }

  text: string = "";
  value: number;
  total: number;
}

@Builder
export function ProgressBuilder(params: ProgressParams) {
  Column() {
    Text(params.text)
      .fontSize($r('app.float.font_size_large'))
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.ProgressBuilderFontColor'))

    Progress({ value: params.value, total: params.total, type: ProgressType.Capsule })
      .width(CommonConstant.FULL_LENGTH)
      .height($r('app.float.ProgressBuilderProgressHeight'))
      .margin({
        top: $r('app.float.ProgressBuilderProgressMarginTop'),
        bottom: $r('app.float.ProgressBuilderProgressMarginBottom')
      })
      .color($r('app.color.base_blue'))

    Text(Math.ceil(params.value) + '%')
      .fontSize($r('app.float.font_size_medium'))
      .fontColor($r('app.color.ProgressBuilderFontColor'))
  }
  .padding({
    left: $r('app.float.ProgressBuilderProgressPaddingLeft'),
    right: $r('app.float.ProgressBuilderProgressPaddingRight'),
    top: $r('app.float.ProgressBuilderProgressPaddingTop'),
    bottom: $r('app.float.ProgressBuilderProgressPaddingBottom')
  })
  .width($r('app.float.ProgressBuilderProgressColumnWidth'))
  .height($r('app.float.ProgressBuilderProgressColumnHeight'))
}