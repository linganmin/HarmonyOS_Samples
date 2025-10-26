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

import { ListManager, NodeItem, RecyclerView } from '@hadss/scroll_components';
import { Logger } from "../common/util/Logger";
import { Utils } from "../common/util/Utils";
import { ItemData, ParamsItemData, TabsCeilingViewModel } from "../viewmodel/TabsCeilingViewModel";
import { util } from "@kit.ArkTS";
import { BusinessError } from '@kit.BasicServicesKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

@Builder
function buildTabsCeilingListPage() {
  TabsCeilingListPage()
}

// [Start Tabs_Ceiling_4]
// [Start Tabs_Ceiling_1]
// [Start Share_Pool_3]
@Component
struct TabsCeilingListPage {
  // [StartExclude Tabs_Ceiling_4]
  // [StartExclude Tabs_Ceiling_1]
  private tabArray: Resource[] = [
  // [StartExclude Share_Pool_3]
    $r('app.string.hot_search'), $r('app.string.follow'), $r('app.string.recommend'), $r('app.string.optional'),
    $r('app.string.found'), $r('app.string.news'), $r('app.string.more')
  // [EndExclude Share_Pool_3]
  ];
  // [StartExclude Share_Pool_3]
  @State currentTabIndex: number = 0;
  private contentTabController: TabsController = new TabsController();
  searchText: string = '';

  aboutToAppear(): void {
    try {
      this.searchText =
        uiContext?.getHostContext()?.resourceManager.getStringSync($r('app.string.search').id) ?? '搜索';
    } catch (error) {
      let err = error as BusinessError;
      Logger.error('SearchButton', `getStringSync failed. code = ${err.code}, message = ${err.message}`);
    }
  }

  // [EndExclude Share_Pool_3]
  aboutToDisappear(): void {
    Utils.getInstance().nodePool?.clear()
  }

  // [StartExclude Share_Pool_3]
  @Builder
  tabBuilder(index: number, item: Resource) {
    Row({ space: 8 }) {
      Text(item)
        .fontSize(14)
        .fontColor(this.currentTabIndex === index ? Color.White : '#E6000000')
        .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .onClick(() => {
          // Click to switch tabs content.
          this.contentTabController.changeIndex(index);
          this.currentTabIndex = index;
        })
    }
    .justifyContent(FlexAlign.Start)
    .backgroundColor(this.currentTabIndex === index ? "#0A59F7" : "#0D000000")
    .borderRadius(20)
    .height(40)
    .margin({ left: index === 0 ? 16 : 4, right: index === this.tabArray.length - 1 ? 16 : 4 })
    .padding({ left: 16, right: 16 })
  }

  // [EndExclude Tabs_Ceiling_4]
  // [EndExclude Tabs_Ceiling_1]
  // [EndExclude Share_Pool_3]
  build() {
    // [StartExclude Tabs_Ceiling_4]
    // [StartExclude Tabs_Ceiling_1]
    // [StartExclude Share_Pool_3]
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Scroll(new Scroller()) {
          Column() {
            Column() {
              Image($r('app.media.pic5'))
                .width('100%')
                .height(186)
                .padding({ left: 12, right: 12 })
                .borderRadius(16)
            }

            // [EndExclude Tabs_Ceiling_4]
            // [EndExclude Tabs_Ceiling_1]
            Column() {
              // [EndExclude Share_Pool_3]
              Tabs({ barPosition: BarPosition.Start, controller: this.contentTabController }) {
                // [StartExclude Tabs_Ceiling_4]
                ForEach(this.tabArray, (item: Resource, index: number) => {
                  TabContent() {
                    CustomListPage({ index: index })
                  }
                  .tabBar(this.tabBuilder(index, item))
                  .align(Alignment.Center)
                }, (item: string) => item)
                // [EndExclude Tabs_Ceiling_4]
              }
              // [StartExclude Share_Pool_3]
              // Set the height of the tab to 'calc(100% - 63vp)' to ensure that the Tabs component leaks out just when the nest slides
              .height('calc(100% - 58vp)')
              .barHeight(56)
              // [StartExclude Tabs_Ceiling_1]
              // [StartExclude Tabs_Ceiling_4]
              .barMode(BarMode.Scrollable)
              .align(Alignment.Start)
              // [EndExclude Tabs_Ceiling_1]
              .onChange((index: number) => this.currentTabIndex = index)
            }
            .backgroundColor($r('app.color.home_background_color'))
            // [StartExclude Tabs_Ceiling_1]
          }
        }
        .width('100%')
        .height('100%')
        .margin({ top: 60 })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .scrollBar(BarState.Off)

        Row() {
          Search({
            placeholder: $r('app.string.want_search'),
          })
            .searchButton(this.searchText, { fontSize: 14 })
            .width('100%')
            .height(40)
            .textFont({ size: 14 })
            .placeholderFont({ size: 14 })
            .backgroundColor('#E6E8E9')
            .layoutWeight(1)
            .margin({ left: 12, right: 12 })
        }
        .width('100%')
        .height(60)
        .justifyContent(FlexAlign.Center)
      }
    }
    .hideTitleBar(true)
    .height('calc(100% + 30vp)')
    .backgroundColor($r('app.color.home_background_color'))

    // [EndExclude Tabs_Ceiling_4]
    // [EndExclude Tabs_Ceiling_1]
    // [EndExclude Share_Pool_3]
  }
}

// [End Tabs_Ceiling_4]
// [End Tabs_Ceiling_1]
// [End Share_Pool_3]
// [Start Tabs_Ceiling_3]
// [Start Tabs_Ceiling_2]
// [Start Share_Pool_3]
@Component
struct CustomListPage {
  // [StartExclude Tabs_Ceiling_3]
  // [StartExclude Tabs_Ceiling_2]
  index: number = 1;
  myListManager: MyListManager = new MyListManager({
    defaultNodeItem: 'CustomListItemContainer',
    context: this.getUIContext()
  });
  @State myViewModel: TabsCeilingViewModel = new TabsCeilingViewModel(this.myListManager);
  scroller: Scroller = new Scroller();

  // [EndExclude Tabs_Ceiling_2]
  // [EndExclude Tabs_Ceiling_3]
  aboutToAppear(): void {
    // [StartExclude Tabs_Ceiling_3]
    // [StartExclude Share_Pool_3]
    this.myListManager.setItemViewStyle((_item, _index, _data: ESObject) => {
    })
    // [EndExclude Tabs_Ceiling_3]
    this.myListManager.setViewStyle({ space: 10, scroller: this.scroller, })
    // [StartExclude Tabs_Ceiling_3]
    // [StartExclude Tabs_Ceiling_2]
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .contentStartOffset(12)
      .contentEndOffset(30)
      // [EndExclude Tabs_Ceiling_3]
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST, // Set the effect of scrolling the component to the end: The parent component rolls first, and then rolls itself to the edge
        scrollBackward: NestedScrollMode.SELF_FIRST // Set the effect of rolling the component to the start end: Rolls itself first, and then the parent component scrolls to the edge
      })
    // [EndExclude Share_Pool_3]
    // Shared multiplexing pools
    // [StartExclude Tabs_Ceiling_3]
    // [Start Share_Pool_2]
    if (Utils.getInstance().nodePool) {
      this.myListManager.registerRecyclePool(Utils.getInstance().nodePool!);
    } else {
      Utils.getInstance().nodePool = this.myListManager.getRecyclePool();
    }
    // [End Share_Pool_2]
    // [StartExclude Share_Pool_3]
    // Print the hash value and check whether the public usage is successful
    Logger.info('SameItemListPage==>  nodePool : ' + JSON.stringify(util.getHash(this.myListManager.getRecyclePool())));
    // [EndExclude Share_Pool_3]
    this.myListManager.registerNodeItem('CustomListItemContainer', wrapBuilder(CustomListItemContainer));
    this.myListManager.preCreate('CustomListItemContainer', 5);
    this.myViewModel.loadData();
    // [EndExclude Tabs_Ceiling_2]
    // [EndExclude Tabs_Ceiling_3]
  }
  // [StartExclude Tabs_Ceiling_3]

  build() {
    RecyclerView({
      viewManager: this.myListManager
    })
  }
  // [EndExclude Tabs_Ceiling_3]
}

// [End Tabs_Ceiling_3]
// [End Tabs_Ceiling_2]
// [End Share_Pool_3]
// [Start Tabs_Ceiling_2]
class MyListManager extends ListManager {
  // [StartExclude Tabs_Ceiling_2]
  onWillCreateItem(_index: number, data: ItemData) {
    let node: NodeItem<ParamsItemData> | null = this.dequeueReusableNodeByType('CustomListItemContainer');
    node?.setData({ itemData: data });
    return node;
  }

  // [EndExclude Tabs_Ceiling_2]
}

// [End Tabs_Ceiling_2]
// [Start Tabs_Ceiling_2]
@Builder
function CustomListItemContainer($$: ParamsItemData) {
  CustomListItem({ itemData: $$.itemData })
}

// [End Tabs_Ceiling_2]
@Component
struct CustomListItem {
  @State itemData: ItemData = new ItemData();

  aboutToReuse(params: Record<string, ESObject>): void {
    this.itemData = params.itemData;
  }

  build() {
    Column() {
      Row() {
        Image(this.itemData.imgUrl)
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 8 })
        Column() {
          Text(this.itemData.title)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
          Text('12-21 12:00')
            .fontSize(12)
            .fontColor(Color.Black)
            .opacity(0.6)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Text(this.itemData.content)
        .width('100%')
        .fontSize(12)
        .fontColor(Color.Black)
        .opacity(0.6)
        .margin({ top: 12, bottom: 12 })
      Row() {
        Image(this.itemData.imgUrl)
          .width('32%')
          .height(72)
          .borderRadius(12)
        Image(this.itemData.imgUrl)
          .width('32%')
          .height(72)
          .borderRadius(12)
        Image(this.itemData.imgUrl)
          .width('32%')
          .height(72)
          .borderRadius(12)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(12)
    .margin({ left: 12, right: 12 })
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}