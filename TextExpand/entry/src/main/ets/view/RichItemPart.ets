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

// [Start RichItemPart]
import { LastSpanAttribute, RichTextModel, RichTextSectionAttribute } from '../utils/Models';
import { RichTextExpandView } from './RichTextExpandView';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from  '@kit.BasicServicesKit'

@Component
export struct RichItemPart {
  @Prop index: string;
  @Prop profileImg: string | Resource = ''; // Avatar picture
  @Prop imgUrlList: Array<string | Resource> = []; // Display picture
  @Prop imgUrl: Resource | string = ''; // click picture
  @Prop iconUrlList: Resource[] | string[] = []; // icon
  @Prop rawTitle: string; // Received text
  @Prop tabItemIndex: number;
  @Prop dataModel: RichTextModel;

  handleContent() {
    try {
      return [this.getUIContext()
        .getHostContext()!.resourceManager.getStringSync($r('app.string.text_expand_expand_title').id),
        this.getUIContext()
          .getHostContext()!.resourceManager.getStringSync($r('app.string.text_expand_collapse_title').id),
      ];
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'testTag', `${error.code}, ${error.message}`);
      return ['', ''];
    }

  }

  build() {
    ListItem() {
      Flex({ direction: FlexDirection.Column }) {
        //[StartExclude RichItemPart]
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Row() {
            Image(this.profileImg)
              .width($r('app.integer.text_expand_image_width'))
              .height($r('app.integer.text_expand_image_height'))
              .borderRadius($r('app.integer.text_expand_image_border_radius'))
            Column() {
              Text($r('app.string.text_expand_text_name'))
                .fontSize($r('app.integer.text_expand_item_text_font_size'))
              Text($r('app.string.text_expand_text_date'))
                .fontSize($r('app.integer.text_expand_item_text_date_font_size'))
                .fontColor($r('app.color.text_expand_item_text_font_color'))
            }
            .margin({ left: $r('app.integer.text_expand_item_column_margin') })
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
          }
          .margin({
            top: $r('app.integer.text_expand_item_row_margin'),
            bottom: 8
          });

          Button() {
            Row() {
              SymbolGlyph($r('sys.symbol.plus'))
                .margin({ right: 3.5 })
                .fontSize(11)
                .renderingStrategy(SymbolRenderingStrategy.SINGLE)
                .fontColor(['#ff0a59f7', '#ff0a59f7', Color.White])

              Text($r('app.string.follow'))
                .fontSize(12)
                .fontColor('#ff0a59f7')
                .fontWeight(500)
            }
          }
          .width(64)
          .height(28)
          .backgroundColor('#0d000000')
        };

        //[EndExclude RichItemPart]
        RichTextExpandView({
          dataModel: this.dataModel,
          textSectionAttribute: new RichTextSectionAttribute(this.rawTitle),
          lastSpanAttribute: new LastSpanAttribute(0, 2,
            this.handleContent(), 16,
            $r('app.color.text_expand_selected_tab_name'))
        }).id(`textClick${this.index}`);

        //[StartExclude RichItemPart]
        Flex({ justifyContent: FlexAlign.Center }) {
          ForEach(this.imgUrlList, (item: Resource, index: number) => {
            Image(item)
              .width($r('app.integer.text_expand_item_main_body_image_width'))
              .height($r('app.integer.text_expand_item_main_body_image_height'))
              .margin({
                right: $r('app.integer.text_expand_item_main_body_image_margin'),
                left: $r('app.integer.text_expand_item_main_body_image_margin')
              })
              .flexGrow(1)
          }, (item: Resource, index: number) => index.toString())
        };

        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.iconUrlList, (item: Resource, index: number) => {
            if (index === 0) {
              SymbolGlyph($r('sys.symbol.ellipsis_message'))
                .fontSize(22)
                .renderingStrategy(SymbolRenderingStrategy.SINGLE)
                .fontColor(['#ff4f4f4f', '#ff4f4f4f', Color.White])
            } else {
              Image(item)
                .width(22)
                .height(22)
            }
          }, (item: Resource, index: number) => index.toString())
        }
        .height(48)
        .padding({
          left: 33,
          right: 33,
          top: 17,
          bottom: 8,
        })

        //[EndExclude RichItemPart]
      }
      .padding({ left: 16, right: 16 });
    }
  }
}

// [End RichItemPart]