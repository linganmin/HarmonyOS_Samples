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

// [Start RichTextExpand]
import { ItemData, RichTextContentModel, RichTextModel, TabData } from '../utils/Models';
import { RichItemPart } from '../view/RichItemPart';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from  '@kit.BasicServicesKit'

@Entry
@Component
export struct RichTextExpand {
  //[StartExclude RichTextExpand]
  @State currentIndex: number = 1; // Current index
  @State changeValue: string = ''; // Search keywords
  private controller: TabsController = new TabsController();
  private controllerSearch: SearchController = new SearchController();
  tabData: TabData[] = [
    new TabData(0, $r('app.string.text_expand_tab_name_main_page')),
    new TabData(1, $r('app.string.text_expand_tab_name_hot')),
    new TabData(2, $r('app.string.text_expand_tab_name_same_city')),
    new TabData(3, $r('app.string.text_expand_tab_name_else'))
  ];
  @State dataModel: RichTextModel | undefined = undefined;
  @State iconList: string[] = ['house_fill', 'star_fill', 'play_round_rectangle_fill', 'person'];
  uiContext = this.getUIContext()

  //[EndExclude RichTextExpand]
  // [Start RichTextTextExpand_tabBuilder]
  @Builder
  tabBuilder(index: number, name: string | Resource) {
    Column() {
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
    }
    .width($r('app.string.text_expand_layout_100'))
  }

  // [End RichTextTextExpand_tabBuilder]
  onPageShow(): void {
    /**
     * To parse text, textArray is the data that needs to be displayed, including normal text, hyperlinks, images and other data types.
     * [Emoji] here represents the image (in the text the length is 4).
     * index indicates the index value of the data in the text.
     * length indicates the length of the data (in the case of images, the length is Number of images*4).
     */
    this.dataModel = new RichTextModel();
    //[StartExclude RichTextExpand]
    this.dataModel.fontSize = 16;
    this.dataModel.text =
      '#话题# [表情][表情][表情]，亲近大海，领悟海，体会到了海的心声，海自然与你共鸣，无须刻意强求，也无须费力搜寻，海，始终都会以潮声与你相亲，以其海色伴你舒适。山腰盘旋的那曲折险峻的实木栈道，如缕缕飘带缠绕在绿水青山之中，成为一道独特的亮丽风景。#特色社会主义建设# ';
    let model = new RichTextContentModel();
    //[StartExclude RichTextExpand]
    model.type = 'link';
    model.fontColor = '#007DFF';
    try {
      model.content = this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.topicName').id);
      model.link = 'https://www.baidu.com';
      model.index = 0;
      model.length = model.content.length;
      //[EndExclude RichTextExpand]

      let model2 = new RichTextContentModel();
      //[StartExclude RichTextExpand]
      model2.type = 'images';
      model2.content = '[表情]';
      model2.imgHeight = 19;
      model2.imgWidth = 19;
      model2.images = ['emoji_1', 'emoji_2', 'emoji_3'];
      model2.index = model.index + model.length;
      model2.length = model2.images.length;
      //[EndExclude RichTextExpand]

      let model3 = new RichTextContentModel();
      //[StartExclude RichTextExpand]
      model3.type = 'text';
      model3.fontColor = '#000000';
      model3.content =
        '，' +
        this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.text_expand_long_title').id);
      model3.index = model2.index + model2.length;
      model3.length = model3.content.length;
      //[EndExclude RichTextExpand]

      let model4 = new RichTextContentModel();
      //[StartExclude RichTextExpand]
      model4.type = 'link';
      model4.fontColor = '#007DFF';
      model4.content =
        this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.environmentName').id);
      model4.link = 'https://www.baidu.com';
      model4.index = model3.index + model3.length;
      model4.length = model4.content.length;
      //[EndExclude RichTextExpand]

      this.dataModel.textArray.push(model);
      this.dataModel.textArray.push(model2);
      this.dataModel.textArray.push(model3);
      this.dataModel.textArray.push(model4);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
      model.content = '';
    }
  }

  build() {
    Column() {
      //[StartExclude RichTextExpand]
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
        .margin({ top: 18 })
      Tabs({
        barPosition: BarPosition.End, index: this.currentIndex, controller: this.controller
      }) {
        ForEach(this.tabData, (item: TabData, index: number) => {
          TabContent() {
            if (index === 1) {
              Column() {
                List({ space: 20, initialIndex: 0 }) {
                  ForEach(item.ItemList, (itemData: ItemData, index2: number) => {
                    RichItemPart({
                      index: `${index}${index2}`,
                      profileImg: index2 % 2 === 0 ? itemData.profileImg : itemData.profileImg1,
                      imgUrlList: itemData.imgUrlList,
                      imgUrl: itemData.imgUrl,
                      iconUrlList: itemData.iconUrlList,
                      rawTitle: '',
                      dataModel: this.dataModel,
                      tabItemIndex: index
                    })
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
        // Modify the current index when it is changed
        this.currentIndex = index;
      })
      .width($r('app.string.text_expand_layout_100'))
      .layoutWeight(1)
      .backgroundColor($r('app.color.text_expand_bar_background_color'))

      //[EndExclude RichTextExpand]
    }
    .width($r('app.string.text_expand_layout_100'))
    .height($r('app.string.text_expand_layout_100'))
  }
}

// [End RichTextExpand]