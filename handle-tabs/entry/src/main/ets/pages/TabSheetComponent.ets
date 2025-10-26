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

import { FULL_PERCENT, STYLE_CONFIGURATION } from '../model/ConstantsData';

@Component
export struct TabSheets {
  @Link tabArray: Array<number>;
  @Link @Watch('onFocusIndexChange') focusIndex: number;
  @State middleIndex: number = this.focusIndex;
  private controller: TabsController = new TabsController();

  onFocusIndexChange() {
    this.middleIndex = this.focusIndex;
  }

  build() {
    Row({ space: STYLE_CONFIGURATION.TAB_BAR_ITEM_GUTTER }) {
      ForEach(this.tabArray, (item: number, index: number) => {
        Row({ space: STYLE_CONFIGURATION.TAB_BAR_CONTENT_GUTTER }) {
          Image($r("app.media.world_clock_filled"))
            .width(STYLE_CONFIGURATION.ICON_SIZE)
            .aspectRatio(1)
          Text($r('app.string.newSheet'))
            .textOverflow({ overflow: TextOverflow.Clip })
            .maxLines(1)
            .flexShrink(1)
          Stack() {
            if (this.tabArray.length < 4 || this.middleIndex === index) {
              Image($r('app.media.ic_public_cancel_filled'))
                .width(STYLE_CONFIGURATION.ICON_SIZE)
                .aspectRatio(1)
                .onClick(() => {
                  if (this.tabArray.length > 1) {
                    this.tabArray.splice(index, 1);
                    if (this.tabArray[index] === undefined) {
                      this.focusIndex = index - 1;
                    } else if (this.tabArray[index] !== undefined && this.focusIndex !== index) {
                      this.focusIndex -= 1;
                    }
                  }
                })
            }
          }
        }
        .flexShrink(1)
        .padding({
          left: $r('sys.float.ohos_id_elements_margin_horizontal_m'),
          right: $r('sys.float.ohos_id_elements_margin_horizontal_m')
        })
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_xs'))
        .height(FULL_PERCENT)
        .backgroundColor(this.middleIndex === index ? $r('sys.color.ohos_id_color_background') :
          $r('sys.color.ohos_id_color_sub_background'))
        .onClick(() => {
          this.controller.changeIndex(index);
          this.focusIndex = index;
        })

        Stack() {
          if (this.middleIndex !== index && this.middleIndex - 1 !== index) {
            Divider()
              .vertical(true)
              .strokeWidth(STYLE_CONFIGURATION.SEPARATOR_STROKE_WIDTH)
              .height('50%')
              .lineCap(LineCapStyle.Round)
          }
        }
      })

      Image($r('app.media.ic_public_add_filled'))
        .width(STYLE_CONFIGURATION.ICON_SIZE)
        .aspectRatio(1)
        .onClick(() => {
          if (this.tabArray.length < 6) {
            this.tabArray.push(this.tabArray.length);
            let newTabIndex: number = this.tabArray.length - 1;
            this.middleIndex = newTabIndex;
            this.getUIContext().animateTo({ duration: 200 }, () => {
              this.focusIndex = newTabIndex;
            })
          }
        })
    }
    .padding(STYLE_CONFIGURATION.TAB_SHEET_PADDING)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width(FULL_PERCENT)
    .height(STYLE_CONFIGURATION.TAB_BAR_HEIGHT)
  }
}