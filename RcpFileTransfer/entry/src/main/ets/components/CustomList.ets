/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

export interface CustomListItem {
  id: string
  title: ResourceStr
  image?: ResourceStr
}

@Component
export struct CustomList {
  @Prop data: CustomListItem[] = [];
  onRowClick: (item: CustomListItem) => void = () => {};

  @BuilderParam
  operateButton: (item: CustomListItem) => void;

  build() {
    Scroll() {
      Column() {
        ForEach(this.data, (item: CustomListItem, index) => {
          if (index !== 0) {
            Divider()
              .color('#0D000000')
              .strokeWidth(0.5)
          }
          Row() {
            if (item.image) {
              Image(item.image)
                .width(24)
                .height(24)
                .margin({ right: 5 })
            }
            Text(item.title)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
            Blank()
            if (this.operateButton) {
              this.operateButton(item)
            } else {
              Image($r('app.media.arrow_right'))
                .width(24)
                .height(24)
                .opacity(0.6)
            }
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })
          .onClick(() => { this.onRowClick(item) })
        }, ((item: CustomListItem) => item.id))
      }
    }
    .width('100%')
    .constraintSize({ maxHeight: '100%' })
    .backgroundColor(Color.White)
    .borderRadius(20)
    .margin({ top: 16, bottom: 28 })
    .padding({ left: 12, right: 12 })
    .scrollBar(BarState.Off)
  }
}