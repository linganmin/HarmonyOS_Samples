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

// [Start TextExpand]
import { ItemData, TabData } from '../utils/Models';
import { ItemPart } from '../view/ItemPart';

@Entry
@Component
export struct TextExpand {
  //[StartExclude TextExpand]
  @State currentIndex: number = 1; // Current index
  @State changeValue: string = ''; // Search keywords
  private controller: TabsController = new TabsController();
  private controllerSearch: SearchController = new SearchController();
  @State tabData: TabData[] = [
    new TabData(0, $r('app.string.text_expand_tab_name_main_page')),
    new TabData(1, $r('app.string.text_expand_tab_name_hot')),
    new TabData(2, $r('app.string.text_expand_tab_name_same_city')),
    new TabData(3, $r('app.string.text_expand_tab_name_else'))
  ];
  @State iconList: string[] = ['house_fill', 'star_fill', 'play_round_rectangle_fill', 'person'];
  uiContext = this.getUIContext()

  //[EndExclude TextExpand]

  // [Start TextExpand_tab]
  @Builder
  tabBuilder(index: number, name: string | Resource) {
    Column() {
      //[StartExclude TextExpand]
      SymbolGlyph($r(`sys.symboy.${this.iconList[index]}`))
        .fontSize(24)
        .renderingStrategy(SymbolRenderingStrategy.SINGLE)
        .fontColor(this.currentIndex === index ? ['#ff0a59f7', '#ff0a59f7', Color.White] :
          ['#80000000', '#80000000', Color.White])
        .margin({
          top: $r('app.integer.text_expand_text_margin_top'),
          bottom: $r('app.integer.text_expand_text_margin_bottom')
        })
      Text(name)
        .fontColor(this.currentIndex === index ? $r('app.color.text_expand_selected_tab_name') :
        $r('app.color.text_expand_tab_name'))
        .font({
          size: $r('app.integer.text_expand_text_font_size'),
          weight: this.currentIndex === index ? 500 : 400
        })
        .lineHeight($r('app.integer.text_expand_text_line_height'))
      //[EndExclude TextExpand]
    }
    .width($r('app.string.text_expand_layout_100'))
  }

  // [End TextExpand_tab]

  build() {
    Column() {
      //[StartExclude TextExpand]
      Search({
        value: this.changeValue,
        placeholder: $r('app.string.text_expand_search_placeholder'),
        controller: this.controllerSearch
      })
        .enableKeyboardOnFocus(false)
        .width($r('app.string.text_expand_layout_95'))
        .height($r('app.integer.text_expand_search_height'))
        .enabled(false)
        .backgroundColor($r('app.color.text_expand_search_background_color'))
        .placeholderColor(Color.Grey)
        .placeholderFont({
          size: $r('app.integer.text_expand_search_placeholder_font_size'),
          weight: 400
        })
        .onSubmit((value: string) => {
          this.uiContext.getPromptAction().showToast({ message: $r('app.string.text_expand_show_button') });
        })
        .onChange((value: string) => {
          this.changeValue = value;
        })
      Tabs({
        barPosition: BarPosition.End, index: this.currentIndex, controller: this.controller
      }) {
        ForEach(this.tabData, (item: TabData, index: number) => {
          TabContent() {
            if (index === 1) {
              Column() {
                List({ space: 20, initialIndex: 0 }) {
                  ForEach(item.ItemList, (itemData: ItemData, index2: number) => {
                    ItemPart({
                      index: `${index}${index2}`,
                      profileImg: index2 % 2 === 0 ? itemData.profileImg : itemData.profileImg1,
                      imgUrlList: itemData.imgUrlList,
                      iconUrlList: itemData.iconUrlList,
                      rawTitle: itemData.rawTitle as Resource,
                      tabItemIndex: index
                    });
                  }, (itemData: ItemData, index2: number) => index2.toString())
                }
                .layoutWeight(1)
                .divider({
                  strokeWidth: $r('app.integer.text_expand_divider_stroke_width'),
                  color: $r('app.color.text_expand_divider_0c_color')
                })
              }
              .width($r('app.string.text_expand_layout_100'))
              .height($r('app.string.text_expand_layout_100'))
            } else {
              Text($r('app.string.tip'))
                .fontSize($r('app.integer.text_expand_text_font_size'))
            }
          }
          .tabBar(this.tabBuilder(item.id, item.name))
        }, (item: TabData, index: number) => index.toString())
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barWidth($r('app.integer.text_expand_tab_bar_width'))
      .barHeight($r('app.integer.text_expand_tab_bar_height'))
      .animationDuration(400)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .width($r('app.string.text_expand_layout_100'))
      .layoutWeight(1)
      .backgroundColor($r('app.color.text_expand_bar_background_color'))

      //[StartExclude TextExpand]
    }
    .width($r('app.string.text_expand_layout_100'))
    .height($r('app.string.text_expand_layout_100'))
  }
}

// [End TextExpand]
