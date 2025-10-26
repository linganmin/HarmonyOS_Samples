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

import { CommonConstants } from '../constants/CommonConstants';
import { ContactGroup, ContactInfo } from '../models/CommonModel';

@Component
export struct ContactListView {
  @State selectedIndex: number = 0;
  @State changeValue: string = '';
  @Prop data: ContactGroup[] = [];
  private scroller: Scroller = new Scroller();

  @Builder
  titleBar() {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(28)
      }
      .width(40)
      .height(40)
      .margin({ right: 16 })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius('50%')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.getUIContext().getRouter().back();
      })
      Text($r('app.string.contact'))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
  }

  @Builder
  alphabetIndexer() {
    AlphabetIndexer({ arrayValue: CommonConstants.TAB_VALUE, selected: this.selectedIndex })
      .height('100%')
      .selectedColor('#0A59F7')
      .popupColor('#A9A9A9')
      .popupBackground($r('sys.color.background_secondary'))
      .usingPopup(true)
      .alignStyle(IndexerAlign.Right)
      .itemSize(20)
      .popupPosition({
        x: 50,
        y: 350
      })
      .selectedFont({
        size: 13,
        weight: FontWeight.Bolder
      })
      .popupFont({
        size: 24,
        weight: FontWeight.Bolder
      })
      .onSelect((tabIndex: number) => {
        this.scroller.scrollToIndex(tabIndex);
      })
  }

  build() {
    Column() {
      this.titleBar()
      Stack({ alignContent: Alignment.End }) {
        List({ initialIndex: 0, scroller: this.scroller }) {
          ForEach(this.data, (group: ContactGroup) => {
            ListItem() {
              Flex({ direction: FlexDirection.Column }) {
                Text(group.title)
                  .height(40)
                  .fontSize(16)
                  .fontColor('#606162')
                  .width('100%')
                  .backgroundColor($r('sys.color.background_secondary'))
                  .padding({ left: 16 })
                Column() {
                  ForEach(group.contact, (item: ContactInfo) => {
                    Flex({ alignItems: ItemAlign.Center }) {
                      Image($r(item.imgName))
                        .width(40)
                        .height(40)
                        .borderRadius(20)
                        .margin({
                          right: 16,
                          left: 16
                        })
                      Text(item.name)
                        .fontSize(16)
                    }
                    .onClick(() => {
                      AppStorage.setOrCreate('contactInfo', item);
                      this.getUIContext().getRouter().back({ url: 'pages/Home' });
                    })
                    .width('100%')
                    .margin({
                      top: 12,
                      bottom: 12
                    })
                  }, (item: string, index: number) => JSON.stringify(item + index))
                }
                .backgroundColor(Color.White)
              }
            }
            .width('100%')
          }, (item: string, index: number) => JSON.stringify(item + index))
        }
        .width('100%')
        .alignListItem(ListItemAlign.Center)
        .padding({ bottom: 30 })
        .edgeEffect(EdgeEffect.None)
        .listDirection(Axis.Vertical)
        .scrollBar(BarState.Off)
        .onScrollIndex((firstIndex: number) => {
          this.selectedIndex = firstIndex;
        })

        this.alphabetIndexer()
      }
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}