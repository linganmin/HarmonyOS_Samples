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

import { ItemInfo } from '../common/models/ItemInfo';

@Component
export struct CustomListItem {
  @ObjectLink itemInfo: ItemInfo;

  build() {
    Row() {
      Circle({ width: $r('app.float.size_8vp'), height: $r('app.float.size_8vp') }).fill('#0088ff')
      Text(this.itemInfo.nameString)
        .fontSize($r('app.float.size_16fp'))
        .fontWeight(FontWeight.Medium)
        .height($r('app.float.size_21vp'))
        .fontColor($r('app.color.font_primary'))
        .margin({
          left: $r('app.float.size_13vp')
        })

      Blank()

      Column({ space: '2vp' }) {
        Text(this.itemInfo.valueString)
          .fontSize($r('app.float.size_16fp'))
          .height($r('app.float.size_21vp'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_primary'))
          .textAlign(TextAlign.End)

        Text(this.itemInfo.resultString)
          .fontSize($r('app.float.size_14fp'))
          .height($r('app.float.size_19vp'))
          .fontWeight(FontWeight.Regular)
          .fontColor(this.itemInfo.resultColor)
          .textAlign(TextAlign.End)
      }.alignItems(HorizontalAlign.End)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .constraintSize({
      minHeight: $r('app.float.size_64vp')
    })
    .padding({
      top: $r('app.float.size_8vp'),
      bottom: $r('app.float.size_8vp')
    })
  }
}