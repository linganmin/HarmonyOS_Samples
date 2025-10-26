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

import { PageFlipType } from '../common/Constants';

@Component
export struct BottomView {
  @Link filledName: string;
  @Link buttonClickedIndex: number;
  @Link isMenuViewVisible: boolean;
  @State buttonNameList: Array<number> = [PageFlipType.PFT_UP_DOWN, PageFlipType.PFT_EMULATION, PageFlipType.PFT_COVER];

  build() {
    Row() {
      ForEach(this.buttonNameList, (item: number) => {
        Button($r(`app.string.page_flip_type_${item}`), { type: ButtonType.Capsule })
          .backgroundColor(this.buttonClickedIndex === item ? Color.White : Color.Transparent)
          .fontColor(this.buttonClickedIndex === item ? '#e6000000' : '#99000000')
          .fontSize($r('app.float.bottom_font_size'))
          .height($r('app.float.bottom_selected_height'))
          .onClick(() => {
            if (this.buttonClickedIndex !== item) {
              this.buttonClickedIndex = item;
              this.isMenuViewVisible = false;
              this.filledName = '';
            }
          })
          .width('33%')
      }, (item: string, index: number) => index + JSON.stringify(item))
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .borderRadius(20)
    .height(40)
    .backgroundColor('#1a000000')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .width('100%')
    .padding(2)
    .width('100%')
  }
}