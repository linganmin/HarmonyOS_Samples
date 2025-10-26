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

import { Config, ListItemGroupManager, ListManager, NodeItem, RecyclerView } from '@hadss/scroll_components';
import { GoodsDataModel, CategoryModel, ParamsGoods } from '../model/CategoryModel';
import { ComponentContent } from '@kit.ArkUI';
import { GroupLayoutViewModel } from '../viewmodel/GroupLayoutViewModel';
import { Logger } from '../common/util/Logger';
import { ToastUtil } from '../common/util/ToastUtil';

@Builder
function buildGroupLayoutListPage() {
  GroupLayoutListPage()
}

// [Start Secondary_Linkage_2]
// [Start Group_Ceiling_1]
// [Start Group_Swipe_Delete]
// [Start group_layout_3]
// [Start group_layout_4]
class MyListManager extends ListManager {
  // [StartExclude Secondary_Linkage_2]
  // [StartExclude Group_Ceiling_1]
  // [StartExclude group_layout_4]
  // [StartExclude Group_Swipe_Delete]
  context: UIContext;

  constructor(config: Config) {
    super(config);
    this.context = config.context;
  }

  // [EndExclude Group_Swipe_Delete]
  // [EndExclude group_layout_4]
  onWillCreateItem(_index: number, data: CategoryModel): NodeItem {
    const groupManager = new MyListItemGroupManager({ defaultNodeItem: 'GoodItemContainer', context: this.context });
    groupManager.registerNodeItem('GoodItemContainer', wrapBuilder(GoodItemContainer));
    // [StartExclude Group_Swipe_Delete]
    groupManager.setDataSource(data.goodsList);
    // The header and footer of the group
    groupManager.setViewStyle({
      space: 12,
      // [StartExclude group_layout_3]
      headerComponent: new ComponentContent<Resource>(this.context,
        wrapBuilder<[Resource]>(goodsHeaderBuilderPublic),
        data.titleName),
      // onClick:(...)=>{} can be declared in the DataModel, and data.onClick is used when data is assigned
      // headerComponent: new ComponentContent<DataModel>(this.context,
      //   wrapBuilder<[DataModel]>(groupHeaderBuilderPublic),
      //   dataModel)
      footerComponent: new ComponentContent<[Resource, number]>(this.context,
        wrapBuilder<[[Resource, number]]>(goodsFooterBuilderPublic),
        [data.titleName, data.titleId]),
      // [EndExclude group_layout_3]
    })
    // [StartExclude group_layout_4]
    // [EndExclude Group_Swipe_Delete]
    groupManager.setItemViewStyle((listItem, index, data: ParamsGoods) => {
      // Used to set the scratch component of ListItem.
      listItem().swipeAction({
        // [StartExclude group_layout_3]
        end: {
          builderComponent: new ComponentContent<[number, GoodsDataModel, ListItemGroupManager]>(this.context,
            wrapBuilder<[[number, GoodsDataModel, ListItemGroupManager]]>(GroupItemActionEnd),
            [index, data.dataModel, groupManager]),
          onEnterActionArea: () => Logger.info("onEnterActionArea"),
          onExitActionArea: () => Logger.info("onExitActionArea"),
          onStateChange: (state: SwipeActionState) => Logger.info("onStateChange" + state)
        },
        start: {
          builderComponent: new ComponentContent<[number, GoodsDataModel]>(this.context,
            wrapBuilder<[[number, GoodsDataModel]]>(GroupItemActionStart),
            [index, data.dataModel]),
        },
        onOffsetChange: (offset: number) => Logger.info("offset:" + offset),
        edgeEffect: SwipeEdgeEffect.Spring,
        // [EndExclude group_layout_3]
      })
    })
    // [EndExclude group_layout_4]
    return groupManager.getNodeItem(this);
  }
  // [EndExclude Secondary_Linkage_2]
  // [EndExclude Group_Ceiling_1]
}
// [End Secondary_Linkage_2]
// [End Group_Ceiling_1]
// [End Group_Swipe_Delete]
// [End group_layout_3]
// [End group_layout_4]
// [Start Secondary_Linkage_2]
// [Start Group_Ceiling_1]
// [Start Group_Swipe_Delete]
// [Start group_layout_2]
class MyListItemGroupManager extends ListItemGroupManager {
  // [StartExclude Secondary_Linkage_2]
  // [StartExclude Group_Ceiling_1]
  // [StartExclude Group_Swipe_Delete]
  onWillCreateItem(_index: number, data: GoodsDataModel): NodeItem | null {
    let node: NodeItem<ParamsGoods> | null = this.dequeueReusableNodeByType('GoodItemContainer');
    node?.setData({ dataModel: data });
    return node;
  }
  // [EndExclude Secondary_Linkage_2]
  // [EndExclude Group_Ceiling_1]
  // [EndExclude Group_Swipe_Delete]
}

// [End Secondary_Linkage_2]
// [End Group_Ceiling_1]
// [End Group_Swipe_Delete]
// [End group_layout_2]
// [Start Secondary_Linkage_2]
// [Start Group_Ceiling_1]
// [Start Group_HeaderView]
// [Start group_layout_5]
@Component
struct GroupLayoutListPage {
  // [StartExclude Group_Ceiling_1]
  // [StartExclude Secondary_Linkage_2]
  // [StartExclude Group_HeaderView]
  // [StartExclude group_layout_5]
  @State currentTitleId: number = 0;
  private categoryScroller: Scroller = new Scroller();
  // [EndExclude group_layout_5]
  myListManager: MyListManager = new MyListManager({ defaultNodeItem: '', context: this.getUIContext() });
  private goodsListScroller: ListScroller = new ListScroller();
  @State myViewModel: GroupLayoutViewModel = new GroupLayoutViewModel(this.myListManager, this.goodsListScroller);

  // [EndExclude Secondary_Linkage_2]
  aboutToAppear() {
    this.initView();
    this.myListManager.registerNodeItem('GoodItemContainer', wrapBuilder(GoodItemContainer));
    this.myListManager.preCreate('GoodItemContainer', 30);
    this.myViewModel.loadData();
  }

  // [EndExclude Group_HeaderView]
  // [Start Secondary_Linkage_3_2]
  // [StartExclude Secondary_Linkage_2]
  // [StartExclude group_layout_5]
  // [Start Group_Ceiling_2]
  initView() {
    // [StartExclude Secondary_Linkage_3_2]
    // [StartExclude Group_Ceiling_2]
    // [StartExclude Group_HeaderView]
    this.myListManager.setItemViewStyle((_item, _index, _data: ESObject) => {
    })
    // [EndExclude Secondary_Linkage_3_2]
    // [EndExclude Group_Ceiling_2]
    // [EndExclude Group_HeaderView]
    this.myListManager.setViewStyle({ space: 10, scroller: this.goodsListScroller })
      // [StartExclude Secondary_Linkage_3_2]
      // [StartExclude Group_Ceiling_2]
      // [StartExclude Group_HeaderView]
      .width('100%')
      .height('100%')
      .cachedCount(3)
      .scrollBar(BarState.Off)
      // [EndExclude Group_Ceiling_2]
      .sticky(StickyStyle.Header)// Set up grouped ceilings
      // [StartExclude Group_Ceiling_2]
      .edgeEffect(EdgeEffect.None)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .padding({ left: 8, right: 12 })
      // [EndExclude Secondary_Linkage_3_2]
      .onScrollIndex((index: number) => { // Scrolling listeners
        this.listChange(index, false);
      })
      // [StartExclude Secondary_Linkage_3_2]
      .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
        Logger.info(`GroupLayoutListPage onDidScroll params:  ${JSON.stringify(scrollOffset)} course: ${scrollState} `);
      })
      // [EndExclude Group_HeaderView]
      .nestedScroll({
        // 1.Nested scrolling: Set up a scrolling scheme
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    // [EndExclude Secondary_Linkage_3_2]
    // [EndExclude Group_Ceiling_2]
  }

  // [End Secondary_Linkage_3_2]
  // [End Group_Ceiling_2]
  // [Start Secondary_Linkage_3_2]
  // [StartExclude Group_HeaderView]
  listChange(index: number, isGoods: boolean) {
    if (this.currentTitleId !== index) {
      this.currentTitleId = index;
      if (isGoods) {
        this.goodsListScroller.scrollToIndex(index);
      } else {
        this.categoryScroller.scrollToIndex(index);
      }
    }
  }

  // [End Secondary_Linkage_3_2]
  // [EndExclude Group_HeaderView]
  // [EndExclude Secondary_Linkage_2]
  // [EndExclude Group_Ceiling_1]
  // [EndExclude group_layout_5]
  build() {
    // [StartExclude Secondary_Linkage_2]
    // [StartExclude Group_HeaderView]
    // [StartExclude group_layout_5]
    NavDestination() {
      Row() {
        // [Start Secondary_Linkage_3]
        // [Start Secondary_Linkage_1]
        List({ scroller: this.categoryScroller }) {
          // [StartExclude Group_Ceiling_1]
          ForEach(this.myViewModel.categoryList, (item: CategoryModel, index: number) => {
            ListItem() {
              Text(item.titleName)
                // [StartExclude Secondary_Linkage_1]
                // [StartExclude Secondary_Linkage_3]
                .width('100%')
                .height(56)
                .fontSize(this.currentTitleId === index ? 16 : 14)
                .textAlign(TextAlign.Center)
                .fontColor(this.currentTitleId === index ? '#0A59F7' : Color.Black)
                .opacity(this.currentTitleId === index ? 1 : 0.6)
                .fontWeight(this.currentTitleId === index ? FontWeight.Bold : FontWeight.Normal)
                // [EndExclude Secondary_Linkage_3]
                .onClick(() => this.listChange(index, true))
              // [EndExclude Secondary_Linkage_1]
            }
          }, (item: CategoryModel) => JSON.stringify(item.titleName))
          // [EndExclude Group_Ceiling_1]
        }
        // [End Secondary_Linkage_1]
        // [End Secondary_Linkage_3]
        .width(100)
        .height('100%')
        .scrollBar(BarState.Off)

        // [EndExclude Group_HeaderView]
        // Nested scrolling: Implement the ListHeader effect
        Scroll() { // 2.Nested Scroll: Outer Scroll
          Column() {
            ListHeaderView()
            // [EndExclude group_layout_5]
            // [EndExclude Secondary_Linkage_2]
            Column() { // 3.Nested Scrolling: Inner List
              RecyclerView({
                viewManager: this.myListManager
              })
            }
            .height('100%')
            // [StartExclude Secondary_Linkage_2]
            // [StartExclude group_layout_5]
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        // [StartExclude Group_HeaderView]
      }
      // [StartExclude Group_Ceiling_1]
      .width('100%')
      .height('calc(100% + 30vp)')
      .justifyContent(FlexAlign.Center)
      .alignSelf(ItemAlign.Center)

      // [EndExclude Group_Ceiling_1]
    }
    // [StartExclude Group_Ceiling_1]
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor($r('app.color.home_background_color'))
    // [EndExclude Secondary_Linkage_2]
    // [EndExclude Group_Ceiling_1]
    // [EndExclude Group_HeaderView]
    // [EndExclude group_layout_5]
  }
}

// [End Secondary_Linkage_2]
// [End Group_Ceiling_1]
// [End Group_HeaderView]
// [StartExclude group_layout_5]
// [Start group_layout_4]
// The global Builder: passes multiple parameters
@Builder
function goodsHeaderBuilderPublic(headerName: Resource) {
  // [StartExclude group_layout_4]
  Row() {
    Text(headerName)
      .fontSize(18)
      .fontWeight(500)
  }
  .width('100%')
  .height(56)
  .padding({ left: 8 })
  .backgroundColor($r('app.color.home_background_color'))

  // [EndExclude group_layout_4]
}

// [End group_layout_4]
// [Start group_layout_4]
// The global Builder: passes multiple parameters
@Builder
function goodsFooterBuilderPublic(args: [Resource, number]) {
  // [StartExclude group_layout_4]
  Row() {
    Text(args[0])
      .fontSize(14)
      .fontColor('#666666')
    Text($r('app.string.category_id'))
      .fontSize(14)
      .fontColor('#666666')
    Text(args[1].toString())
      .fontSize(14)
      .fontColor('#666666')
  }
  .width('100%')
  .height(30)
  .padding({ left: 8 })
  .backgroundColor($r('app.color.home_background_color'))

  // [EndExclude group_layout_4]
}

// [End group_layout_4]
// [EndExclude group_layout_5]
// [Start Group_Ceiling_1]
// [Start group_layout_1]
@Builder
function GoodItemContainer($$: ParamsGoods) {
  GoodItem({ dataModel: $$.dataModel })
}

// [End Group_Ceiling_1]
// [End group_layout_5]
@Component
struct GoodItem {
  @Prop dataModel: GoodsDataModel = {
    titleId: 0,
    goodsId: 0,
    goodsName: '',
    imgUrl: $r('app.media.pic2'),
    price: 0
  };

  aboutToReuse(params: Record<string, ESObject>): void {
    this.dataModel = params.dataModel;
  }

  build() {
    Row() {
      Image(this.dataModel.imgUrl)
        .height('100%')
        .aspectRatio(1)
        .sourceSize({ width: 96, height: 96})
      Column() {
        Text(this.dataModel.goodsName)
          .width('100%')
          .fontSize(14)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Clip })
          .lineHeight(20)
        Text('￥' + this.dataModel.price)
          .fontSize(18)
          .fontColor(Color.Red)
      }
      .height('100%')
      .padding(12)
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .clip(true)
    .width('100%')
    .height(96)
    .backgroundColor(Color.White)
    .borderRadius(18)
  }
}

// [End group_layout_1]
// [Start Group_Swipe_Delete]
@Builder
function GroupItemActionStart(args: [number, GoodsDataModel]) {
  // [StartExclude Group_Swipe_Delete]
  Row() {
    Text($r('app.string.collection'))
      .padding({ left: 24, right: 24 })
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.swipe_collection_color'))
      .height("100%")
      .textAlign(TextAlign.Center)
      .align(Alignment.Center)
  }
  .height('auto')
  .backgroundColor($r('app.color.black_0D'))
  .onClick(() => {
    // When an external page is required to initiate a request
    if (args[1].clickCollection) {
      args[1].clickCollection!().then((isSuccess) => {
        if (isSuccess) {
          ToastUtil.success($r('app.string.collection_success'));
        }
      })
    }
  })
  // [EndExclude Group_Swipe_Delete]
}

@Builder
function GroupItemActionEnd(args: [number, GoodsDataModel, ListItemGroupManager]) {
  // [StartExclude Group_Swipe_Delete]
  Row() {
    Text($r('app.string.delete'))
      .padding({ left: 24, right: 24 })
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.swipe_delete_color'))
      .height("100%")
      .textAlign(TextAlign.Center)
      .align(Alignment.Center)
  }
  .height('auto')
  .backgroundColor($r('app.color.black_0D'))
  .onClick(() => {
    // Click to delete the list item， Simple logic, no need for external page operation
    let dataModel = args[1];
    let manager = args[2];
    if (dataModel.realIndex) {
      let realIndex = dataModel.realIndex!();
      animateToImmediately({ duration: 200 }, () => {
        manager.nodeAdapter.deleteData(realIndex);
      })
      ToastUtil.success($r('app.string.delete_success'));
    }
  })
  // [EndExclude Group_Swipe_Delete]
}
// [End Group_Swipe_Delete]
// [Start Group_HeaderView]
@Component
export struct ListHeaderView {
  build() {
    Column() {
      // ListHeaderView: You can set up various types of subassemblies
      // Swiper(...){...}
      // Grid(...){...}
      // CustomComponent(...){...}
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.pic1'))
        Row() {
          Text($r('app.string.i_am'))
            .fontSize(16)
            .fontColor('#333')
          Text(' ListHeaderView')
            .fontSize(16)
            .fontColor('#333')
        }
      }
    }
    .alignItems(HorizontalAlign.Center)
  }
}

// [End Group_HeaderView]
