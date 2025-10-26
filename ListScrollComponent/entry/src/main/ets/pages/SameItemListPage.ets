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

// [Start quick_start_3]
// [Start quick_start_1]
import { ListManager, NodeItem, RecyclerView } from '@hadss/scroll_components';
// [End quick_start_1]
// [End quick_start_3]
import { JSON } from '@kit.ArkTS';
import { window, LengthMetrics } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants } from '../common/constants/CommonConstants';
import { BlogData, Params } from '../model/types';
import { EasyBlogItem } from '../component/PublicView';
import { Logger } from '../common/util/Logger';
import { SameItemViewModel } from '../viewmodel/SameItemViewModel';
import { ToastUtil } from '../common/util/ToastUtil';

@Builder
function buildSameItemListPage() {
  SameItemListPage()
}

// [Start Toggle_Columns]
// [Start quick_start_4_a]
// [Start quick_start_1]
// [Start quick_start_3]
// [Start Swipe_Delete]
@Component
struct SameItemListPage {
  // [StartExclude Toggle_Columns]
  // [StartExclude Swipe_Delete]
  myListManager: MyListManager = new MyListManager({
    defaultNodeItem: 'EasyBlogItemContainer',
    context: this.getUIContext()
  });
  // [StartExclude quick_start_4_a]
  // [StartExclude quick_start_1]
  @State myViewModel: SameItemViewModel = new SameItemViewModel(this.myListManager);
  // [StartExclude quick_start_3]
  listScroller: ListScroller = new ListScroller();
  // [EndExclude Toggle_Columns]
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass = (this.context as common.UIAbilityContext).windowStage.getMainWindowSync();
  @State listChildrenSize: ChildrenMainSize = new ChildrenMainSize(100);

  // [EndExclude quick_start_3]
  // [EndExclude quick_start_4_a]
  aboutToAppear(): void {
    // [StartExclude quick_start_3]
    // [StartExclude quick_start_4_a]
    // The settings page is free to rotate
    let orientation = window.Orientation.AUTO_ROTATION;
    this.windowClass.setPreferredOrientation(orientation, (err: BusinessError) => {
      const errCode: number = err.code;
      if (errCode) {
        Logger.error('Failed to set window orientation. Cause:' + JSON.stringify(err));
        return;
      }
      Logger.info('Succeed to setting window orientation');
    })
    // Listen for screen size changes
    this.windowClass.on('windowSizeChange', (size) => {
      let viewWidth = size.width;
      let viewHeight = size.height;
      if (viewWidth > viewHeight) { // Criteria are judged based on business settings
        this.myListManager.setViewStyle().lanes(2);
      } else {
        this.myListManager.setViewStyle().lanes(1);
      }
    })

    this.initView();
    // [EndExclude quick_start_3]
    // [EndExclude quick_start_4_a]
    // [StartExclude Toggle_Columns]
    // Register a reuse template
    this.myListManager.registerNodeItem('EasyBlogItemContainer', wrapBuilder(EasyBlogItemContainer));
    // [StartExclude quick_start_3]
    // [StartExclude quick_start_4_a]
    // Pre-created
    this.myListManager.preCreate('EasyBlogItemContainer', 30);
    // [EndExclude quick_start_3]
    // Simulate request data
    this.myViewModel.loadData();
    // [EndExclude Toggle_Columns]
    // [EndExclude quick_start_4_a]
  }
  // [EndExclude Swipe_Delete]
  // [StartExclude quick_start_3]
  // [StartExclude quick_start_4_a]
  initView() {
    // [StartExclude Toggle_Columns]
    // [Start quick_start_2]
    this.myListManager.setItemViewStyle((item, index, data: Params) => {
      item({ style: ListItemStyle.NONE })
        .width('100%')
        .height('auto')
        .swipeAction({
          // [StartExclude quick_start_2]
          end: { builder: () => this.ItemActionEnd(data.blogData) },
          start: { builder: () => this.ItemActionStart(data.blogData) },
          onOffsetChange: (offset: number) => Logger.info("offset:" + offset)
          // [EndExclude quick_start_2]
        })
        .onClick(() => Logger.info("index:" + index))
    })
    // [EndExclude Toggle_Columns]
    // [StartExclude Swipe_Delete]
    // [Start Fading_Edge]
    this.myListManager.setViewStyle({ space: 10, scroller: this.listScroller })
    // [StartExclude Fading_Edge]
    // [StartExclude Toggle_Columns]
      .cachedCount(2)// Set the number of preloaded ListItemListItemGroups in the list and whether to display the preloaded nodes
      .width('100%')
      .layoutWeight(1)
      .contentStartOffset(20)// Sets the offset at the start of the content area
      .contentEndOffset(20)// Sets the offset at the end of the content area
      .scrollBar(BarState.Off)// Set the scrollbar status
      // [StartExclude quick_start_2]
      .divider({
        strokeWidth: 2,
        color: '#F5F5F5',
        startMargin: 20,
        endMargin: 20
      })// Set the ListItem divider style, there is no dividing line by default
      .onClick(() => Logger.info('ListView onClick'))
      .onScrollIndex((start: number, end: number, center: number) => {
        Logger.info('SameItemListPage onScrollIndex: start: ' + start + ' end: ' + end + ' center ' + center)
      })
      .onScrollVisibleContentChange((start: VisibleListContentInfo,
        end: VisibleListContentInfo) => {
        Logger.info(' start index: ' + start.index + ' end index: ' + end.index);
      })
      .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
        Logger.info(`onScroll scrollState = ScrollState` + scrollState + `, scrollOffset = ` + scrollOffset);
      })
      // [EndExclude quick_start_2]
      // [EndExclude Toggle_Columns]
      .alignListItem(ListItemAlign.Start)// Set the direction of the List cross axis
      .lanes(1)// Set the number of layout columns or rows in the List portlet
      // [StartExclude Toggle_Columns]
      .childrenMainSize(this.listChildrenSize)// Set the size of the child components of the List component in the direction of the main axis
      // [EndExclude Fading_Edge]
      .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(80) })
      // [End Fading_Edge]
      // Nested scrolling: Set up a scrolling scheme
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST, // The parent component scrolls first, scrolls to the edge, and then scrolls itself
        scrollBackward: NestedScrollMode.SELF_FIRST // Itself rolls first, and then the parent component scrolls to the edge
      })
    // [EndExclude Toggle_Columns]
    // [End quick_start_2]
    // [EndExclude Swipe_Delete]
  }
  // [StartExclude Toggle_Columns]

  @Builder
  ItemActionStart(data: BlogData) {
    Row() {
      Text($r('app.string.collection'))
      // [StartExclude Swipe_Delete]
        .padding({ left: 24, right: 24 })
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.swipe_collection_color'))
        .height("100%")
        .textAlign(TextAlign.Center)
        .align(Alignment.Center)
      // [EndExclude Swipe_Delete]
    }
    // [StartExclude Swipe_Delete]
    .height('auto')
    .backgroundColor($r('app.color.black_0D'))
    .onClick(() => {
      this.myViewModel.collectionData(data, (isSuccess) => {
        if (isSuccess) {
          this.listScroller.closeAllSwipeActions();
          ToastUtil.success($r('app.string.collection_success'));
        }
      });
    })
    // [EndExclude Swipe_Delete]
  }

  @Builder
  ItemActionEnd(data: BlogData) {
    Row() {
      Text($r('app.string.delete'))
      // [StartExclude Swipe_Delete]
        .padding({ left: 24, right: 24 })
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.swipe_delete_color'))
        .height("100%")
        .textAlign(TextAlign.Center)
        .align(Alignment.Center)
      // [EndExclude Swipe_Delete]
    }
    // [StartExclude Swipe_Delete]
    .height('auto')
    .backgroundColor($r('app.color.black_0D'))
    .onClick(() => {
      // Click to delete the list item
      this.myViewModel.deleteDataRequest(data, (isSuccess) => {
        if (isSuccess) {
          this.getUIContext().animateTo({ duration: 200 }, () => {
            this.myViewModel.deleteData(data);
          })
          ToastUtil.success($r('app.string.delete_success'));
        }
      });
    })
    // [EndExclude Swipe_Delete]
  }

  // [EndExclude quick_start_3]
  build() {
    // [StartExclude Swipe_Delete]
    // [StartExclude quick_start_3]
    NavDestination() {
      Column() {
        // Header navigation bar
        Row({ space: 8 }) {
          Text($r('app.string.page_same_item'))
            .fontSize($r('app.float.title_font_size'))
            .fontWeight(FontWeight.Bold)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(12)
        .width(CommonConstants.FULL_WIDTH)
        .backgroundColor(Color.White)
        // [EndExclude Swipe_Delete]
        // [EndExclude quick_start_3]
        Column() {
          RecyclerView({
            viewManager: this.myListManager
          })
        }
        // [StartExclude Swipe_Delete]
        // [StartExclude quick_start_3]
      }
      .height(CommonConstants.FULL_HEIGHT)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .backgroundColor($r('app.color.home_background_color'))
    }
    .hideTitleBar(true)
    // [EndExclude Swipe_Delete]
    // [EndExclude quick_start_3]
  }
  // [EndExclude quick_start_1]
  // [EndExclude quick_start_4_a]
  // [EndExclude Toggle_Columns]
}

// [End Toggle_Columns]
// [End Swipe_Delete]
// [End quick_start_1]
// [End quick_start_3]
// [Start quick_start_1]
class MyListManager extends ListManager {
  onWillCreateItem(_index: number, data: BlogData) {
    // [StartExclude quick_start_1]
    let node: NodeItem<Params> | null = this.dequeueReusableNodeByType('EasyBlogItemContainer');
    node?.setData({ blogData: data });
    return node;
    // [EndExclude quick_start_1]
  }
}

// [End quick_start_1]
// [Start quick_start_3]
// Define an item template
@Builder
function EasyBlogItemContainer($$: Params) {
  EasyBlogItem({ blogData: $$.blogData })
}
// [End quick_start_3]
// [End quick_start_4_a]