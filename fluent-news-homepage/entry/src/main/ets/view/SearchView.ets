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

import { router } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';

@Component
export struct SearchView {
  @Link searchList: string[];
  @Link isSearchState: boolean;
  private scroller: Scroller = new Scroller();

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        List({
          space: CommonConstants.LIST_ITEM_SPACE,
          initialIndex: CommonConstants.ZERO,
          scroller: this.scroller
        }) {
          ForEach(this.searchList, (index: string) => {
            ListItem() {
              Column() {
                Text(index)
                  .height($r('app.integer.search_list_height'))
                  .fontSize($r('app.integer.text_font_size'))
                  .onClick(() => {
                    AppStorage.setOrCreate('local', index);
                    this.getUIContext().getRouter().back();
                  })
              }
            }
          }, (item: string) => JSON.stringify(item))
        }
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
        .edgeEffect(EdgeEffect.None)
        .divider({
          strokeWidth: $r('app.integer.divider_strokeWidth'),
          color: $r('app.color.divider_color'),
          startMargin: $r('app.integer.divider_start'),
          endMargin: $r('app.integer.divider_end')
        })
        .listDirection(Axis.Vertical)
        .sticky(StickyStyle.Header)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
    .visibility(this.isSearchState ? Visibility.Visible : Visibility.None)
  }
}