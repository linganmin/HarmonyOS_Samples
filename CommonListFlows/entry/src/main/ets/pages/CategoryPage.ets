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

import goodsViewModel, { GoodsDataModel, NavTitleModel } from '../model/LinkDataModel';

@Builder
export function CategoryPageBuilder() {
  CategoryPage()
}

@Component
struct CategoryPage {
  @State isSelected: boolean = false;
  @State currentTitleId: number = 0;
  private categoryList: NavTitleModel[] = [];
  private navTitleScroller: Scroller = new Scroller();
  private goodsListScroller: Scroller = new Scroller();
  @StorageLink('languageVal') @Watch('aboutToAppear') languageVal: string = '';

  aboutToAppear() {
    this.categoryList = goodsViewModel.getLinkData();
  }

  // Right side list header.
  @Builder
  goodsHeaderBuilder(headerName: Resource) {
    Row() {
      Text(headerName)
        .fontSize(18)
        .fontWeight(500)
    }
    .width('100%')
    .height(56)
    .padding({ left: 8 })
    .backgroundColor(0xF1F3F5)
  }

  // [Start list_sliding_event]
  // List sliding event.
  listChange(index: number, isGoods: boolean) {
    if (this.currentTitleId !== index) {
      this.currentTitleId = index;
      if (isGoods) {
        // IsGoods is true, controlling the data in the right-hand list to slide to the specified index.
        this.goodsListScroller.scrollToIndex(index);
      } else {
        // IsGoods is set to false, controlling the left list data to slide to the specified index.
        this.navTitleScroller.scrollToIndex(index);
      }
    }
  }
  // [End list_sliding_event]

  build() {
    NavDestination() {
      Row() {
        // [Start on_list_change]
        // [Start tabs_and_navigation]
        // Left List Data Display.
        List({ scroller: this.navTitleScroller }) {
          ForEach(this.categoryList, (item: NavTitleModel, index: number) => {
            ListItem() {
              Text(item.titleName)
                // [StartExclude on_list_change]
                // [StartExclude tabs_and_navigation]
                .width('100%')
                .height(56)
                .fontSize(this.currentTitleId === index ? 16 : 14)
                .textAlign(TextAlign.Center)
                .fontColor(this.currentTitleId === index ? '#0A59F7' : Color.Black)
                .opacity(this.currentTitleId === index ? 1 : 0.6)
                .fontWeight(this.currentTitleId === index ? FontWeight.Bold : FontWeight.Normal)
                // [EndExclude on_list_change]
                .onClick(() => {
                  // Pass in the current list item index and true.
                  this.listChange(index, true);
                })
                // [EndExclude tabs_and_navigation]
            }
          }, (item: NavTitleModel) => JSON.stringify(item.titleName))
        }
        // [StartExclude on_list_change]
        // [StartExclude tabs_and_navigation]
        .width(100)
        .height('100%')
        .scrollBar(BarState.Off)
        // [EndExclude tabs_and_navigation]
        // [EndExclude on_list_change]

        // Display of List Content on the Right.
        List({ scroller: this.goodsListScroller }) {
          // [StartExclude on_list_change]
          ForEach(this.categoryList, (item: NavTitleModel) => {
            ListItemGroup({ space: 12, header: this.goodsHeaderBuilder(item.titleName) }) {
              ForEach(item.goodsList, (goodsItem: GoodsDataModel) => {
                ListItem() {
                  Row() {
                    Image(goodsItem.imgUrl)
                      // [StartExclude tabs_and_navigation]
                      .height('100%')
                      .aspectRatio(1) // Set the aspect ratio of the component to 1.
                      // [EndExclude tabs_and_navigation]
                    Column() {
                      Text(goodsItem.goodsName)
                        // [StartExclude tabs_and_navigation]
                        .width('100%')
                        .fontSize(14)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Clip })
                        .lineHeight(20)
                        // [EndExclude tabs_and_navigation]
                      Text('￥' + goodsItem.price)
                        // [StartExclude tabs_and_navigation]
                        .fontSize(18)
                        .fontColor(Color.Red)
                        // [EndExclude tabs_and_navigation]
                    }
                    // [StartExclude tabs_and_navigation]
                    .height('100%')
                    .padding(12)
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.SpaceBetween)
                    // [EndExclude tabs_and_navigation]
                  }
                  // [StartExclude tabs_and_navigation]
                  .clip(true)
                  .width('100%')
                  .height(96)
                  .backgroundColor(Color.White)
                  .borderRadius(18)
                  // [EndExclude tabs_and_navigation]
                }
              }, (goodsItem: GoodsDataModel) => JSON.stringify(goodsItem.goodsId))
            }
          }, (item: NavTitleModel) => JSON.stringify(item.goodsList))
          // [EndExclude on_list_change]
        }
        // [StartExclude on_list_change]
        // [End tabs_and_navigation]
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.Header)
        .edgeEffect(EdgeEffect.None)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .padding({ left: 8, right: 12 })
        // [EndExclude on_list_change]
        .onScrollIndex((index: number) => {
          // Pass in the current list item index and false.
          this.listChange(index, false)
        })
        // [End on_list_change]
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignSelf(ItemAlign.Center)
    }
    .hideTitleBar(true)
    .backgroundColor(0xF1F3F5)
  }
}