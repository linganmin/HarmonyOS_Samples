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

import { GridManager, NodeItem, RecyclerView } from '@hadss/scroll_components';
import WorkGridViewModel from '../viewModel/WorkGridViewModel';
import { buildVideoWork } from './VideoWorkComponent';
import WorkHeadComponent from './WorkHeadComponent';
import { LengthMetrics } from '@kit.ArkUI';
import WorkViewModel from '../viewModel/WorkViewModel';
import { buildPhoto } from './PhotoCellComponent';
import { Utils } from '../common/util/Utils';
import { buildPictureWork } from './PictureWorkComponent';

// [Start different_item]
// [Start pages_reuse]
// [Start refresh]
// [Start load_more]
// [Start drag]
@Component
export default struct WorkComponent {
  // [StartExclude different_item]
  // [StartExclude pages_reuse]
  // [StartExclude refresh]
  // [StartExclude load_more]
  // [StartExclude drag]
  scroller: Scroller = new Scroller();
  outerScroller: Scroller = new Scroller();
  // [EndExclude load_more]
  // [EndExclude refresh]
  gridViewManager: GridViewManager = new GridViewManager({ defaultNodeItem: 'video', context: this.getUIContext() });
  @State viewModel: WorkGridViewModel = new WorkGridViewModel(this.gridViewManager);
  // [StartExclude refresh]
  // [StartExclude load_more]
  // [EndExclude drag]
  @State workModel: WorkViewModel = new WorkViewModel();
  // [EndExclude load_more]
  // [EndExclude different_item]
  // [EndExclude pages_reuse]

  // [Start nested_scrolling]
  // [Start set_fading]
  aboutToAppear(): void {
    // [StartExclude drag]
    // [StartExclude load_more]
    // [StartExclude different_item]
    // [StartExclude nested_scrolling]
    // [StartExclude set_fading]
    if (Utils.getInstance().nodePool) {
      this.gridViewManager.registerRecyclePool(Utils.getInstance().nodePool!);
    } else {
      // save recycle pool.
      Utils.getInstance().nodePool = this.gridViewManager.getRecyclePool();
    }
    // [StartExclude pages_reuse]
    this.gridViewManager.setViewStyle()
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(2)
      .rowsGap(2)
      .width("100%")
      .padding({
        bottom: 10
      })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None);
    // [EndExclude load_more]
    this.gridViewManager.setViewStyle()
      .onReachEnd(() => {
        // listen the scroll position.
        this.viewModel.loadMore();
      });
    // [StartExclude load_more]
    // [EndExclude drag]
    this.gridViewManager.setViewStyle()
      .editMode(true)
      .onItemDragStart((event: ItemDragInfo, itemIndex: number) => {
        let model = this.viewModel.getItemData(itemIndex);
        this.workModel = model;
        return this.buildDrag();
      })
      .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
        if (!isSuccess) {
          return;
        }
        this.viewModel.move(itemIndex, insertIndex);
      });
    // [StartExclude drag]

    // [EndExclude nested_scrolling]
    this.gridViewManager.setViewStyle(this.scroller)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      });
    // [StartExclude nested_scrolling]
    // [EndExclude set_fading]
    this.gridViewManager.setViewStyle()
      .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(40) })
    // [StartExclude set_fading]
    // [EndExclude different_item]
    this.gridViewManager.registerNodeItem("video", wrapBuilder(buildVideoWork));
    this.gridViewManager.registerNodeItem("picture", wrapBuilder(buildPictureWork));
    this.gridViewManager.registerNodeItem("photoContainer", wrapBuilder(buildPhoto));
    // [StartExclude different_item]
    this.viewModel.loadData();
    // [EndExclude different_item]
    // [EndExclude pages_reuse]
    // [EndExclude load_more]
    // [EndExclude nested_scrolling]
    // [EndExclude drag]
    // [EndExclude set_fading]
  }
  // [End set_fading]
  // [End nested_scrolling]
  // [StartExclude load_more]

  // [StartExclude pages_reuse]
  // [StartExclude different_item]
  @Builder
  buildDrag() {
    Column() {
      buildVideoWork({ work: this.workModel });
    }
    .width(125)
  }
  // [StartExclude drag]

  @Builder
  refreshBuilder() {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.viewModel.refreshState != RefreshStatus.Inactive && this.viewModel.refreshState != RefreshStatus.Done) {
        Progress({ value: this.viewModel.refreshOffset, total: 64, type: ProgressType.Ring })
          .width(32)
          .height(32)
          .style({ status: this.viewModel.isRefresh ? ProgressStatus.LOADING : ProgressStatus.PROGRESSING })
          .margin(10)
      }
    }
    .clip(true)
    .width('100%')
    .height('100%')
  }

  @Builder
  footer() {
    Row() {
      LoadingProgress().height(32).width(48)
      Text($r("app.string.loading"))
    }
    .width('100%')
    .height(64)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .visibility(this.viewModel.isLoading ? Visibility.Visible : Visibility.None)
  }
  // [EndExclude refresh]

  build() {
    Refresh({ refreshing: $$this.viewModel.isRefresh, builder: this.refreshBuilder() }) {
      // [StartExclude refresh]
      List({ scroller: this.outerScroller }) {
        ListItem() {
          WorkHeadComponent()
        }

        ListItem() {
          Stack({ alignContent: Alignment.Bottom }) {
            Column() {
              Text($r('app.string.works'))
                .alignSelf(ItemAlign.Start)
                .fontWeight(FontWeight.Bold)
                .height(20)
                .margin({
                  left: 10
                })
              // [EndExclude refresh]
              // main grid
              RecyclerView({
                viewManager: this.gridViewManager
              })
              // [StartExclude refresh]
            }

            this.footer()
          }
        }
        .layoutWeight(1)
        .height('100%')
        .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      // [EndExclude refresh]
    }
    // [StartExclude refresh]
    .width('100%')
    .height('100%')
    .onOffsetChange((offset) => {
      this.viewModel.refreshOffset = offset;
    })
    .onStateChange((state) => {
      this.viewModel.refreshState = state;
    })
    // [EndExclude refresh]
    .onRefreshing(() => {
      this.viewModel.refreshData();
    })
  }
  // [EndExclude different_item]
  // [EndExclude pages_reuse]
  // [EndExclude load_more]
  // [EndExclude drag]
}
// [End drag]
// [End pages_reuse]
// [End refresh]
// [End load_more]

/**
 * grid manager class
 */
class GridViewManager extends GridManager {
  onWillCreateItem(index: number, data: WorkViewModel): NodeItem<WorkCellData> | null {
    // select the corresponding template according to the data type.
    let node: NodeItem<WorkCellData> | null = this.dequeueReusableNodeByType(data.type);
    node?.setData({ work: data });
    return node;
  }
}
// [End different_item]

export interface WorkCellData {
  work: WorkViewModel;
}