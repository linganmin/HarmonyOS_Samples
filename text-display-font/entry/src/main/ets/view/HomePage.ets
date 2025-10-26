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

import { FontType, listData, ListItemData } from '../common/CommonData';
import PreferenceUtils, { fp2pxUtil, registerMyFont } from '../common/CommonUtils';

@Component
export struct HomePage {
  @StorageLink('toggleState') toggleState: boolean = false;
  @StorageLink('fontSizeOffset') fontSizeOffset: number = 0;
  @StorageLink('fontWeightOffset') fontWeightOffset: number = 400;
  @StorageLink('fontOffset') fontOffset: string = '';
  private envFont: FontType | undefined = { fontSizeScale: 0, fontWeightScale: 0, };

  aboutToAppear() {
    // Register font
    registerMyFont(this.getUIContext());
    // Get fontSize data from preferences
    this.fontSizeOffset = PreferenceUtils.getFontSize();
    // Get fontWeight data from preferences
    this.fontWeightOffset = PreferenceUtils.getFontWeight();
    // Get font data from preferences
    this.fontOffset = PreferenceUtils.getFont();
  }

  build() {
    Column() {
      Search({ placeholder: $r('app.string.text_input') })
        .borderWidth(1.5)
        .backgroundColor('#FFF1F3F5')
        .margin({ top: 10, bottom: 12 })
        .searchIcon({ src: $r('app.media.search') })
        .placeholderFont({ size: this.toggleState ? 16 : fp2pxUtil(16), weight: 400 })
      List({ space: 12 }) {
        ForEach(listData, (item: ListItemData) => {
          ListItem() {
            Column({ space: 12 }) {
              Text(item.content)
                .fontSize(this.toggleState ? 16 : fp2pxUtil(16 + this.fontSizeOffset))
                .fontWeight(this.toggleState ? this.envFont?.fontWeightScale : this.fontWeightOffset)
                .fontFamily(this.fontOffset)
              Row({ space: 6 }) {
                Text(item.type)
                  .fontColor('#0A59F7')
                  .fontSize(this.toggleState ? 12 : fp2pxUtil(12 + this.fontSizeOffset))
                  .fontWeight(this.toggleState ? this.envFont?.fontWeightScale : this.fontWeightOffset)
                  .fontFamily(this.fontOffset)
                Text(item.source)
                  .fontColor('#999')
                  .fontSize(this.toggleState ? 12 : fp2pxUtil(12 + this.fontSizeOffset))
                  .fontWeight(this.toggleState ? this.envFont?.fontWeightScale : this.fontWeightOffset)
                  .fontFamily(this.fontOffset)
                Text(item.time)
                  .fontColor('#999')
                  .fontSize(this.toggleState ? 12 : fp2pxUtil(12 + this.fontSizeOffset))
                  .fontWeight(this.toggleState ? this.envFont?.fontWeightScale : this.fontWeightOffset)
                  .fontFamily(this.fontOffset)
              }
            }
            .width('100%')
            .padding(16)
            .borderRadius(12)
            .backgroundColor('#FFF')
            .alignItems(HorizontalAlign.Start)
          }
        }, (item: ListItemData) => item.id.toString())
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: 64 })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
  }
}