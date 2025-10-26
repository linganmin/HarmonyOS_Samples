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

import { GridManager, NodeItem, RecyclerView } from "@hadss/scroll_components";
import { CommonConstants } from "../common/constants/CommonConstants";
import CardGridViewModel from "../viewModel/CardGridViewModel";
import UserInfoViewModel from "../viewModel/UserInfoViewModel";
import { buildCard } from "./CardComponent";
import { buildManagerCard } from "./ManagerCardComponent";
import { buildUserCard } from "./UserCardComponent";

// [Start combine_item]
// [Start control_scroll_position]
// card grid view
@Component
export default struct CardGridComponent {
  // [StartExclude combine_item]
  scroller: Scroller = new Scroller();
  gridViewManager: GridViewManager = new GridViewManager({ defaultNodeItem: "card", context: this.getUIContext() });
  @State viewModel: CardGridViewModel = new CardGridViewModel(this.gridViewManager, this.scroller);
  // [EndExclude combine_item]

  // [Start fast_when_start]
  // [Start set_gap]
  // [Start set_column_template]
  // [Start set_item_style]
  // [Start long_press_delete]
  aboutToAppear(): void {
    // [StartExclude combine_item]
    // [StartExclude fast_when_start]
    // [StartExclude set_gap]
    // [StartExclude set_column_template]
    // [StartExclude control_scroll_position]
    // [StartExclude set_item_style]
    // [StartExclude long_press_delete]
    this.gridViewManager.setViewStyle()
      .width("95%")
      .height("100%")
      .cachedCount(3)
      .onScrollIndex((first: number, last: number) => {
        if (last > 0) {
          this.gridViewManager.visibleAreaChanged(first, last);
        }
      });

    this.gridViewManager.setViewStyle()
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .margin({
        left: 12,
        right: 12
      });
    // [EndExclude set_gap]
    this.gridViewManager.setViewStyle()
      .columnsGap(8) // set column spacing to 8vp. 
      .rowsGap(8); // set row spacing to 8vp.
    // [StartExclude set_gap]
    this.gridViewManager.setViewStyle()
      .scrollBar(BarState.Off);
    // [EndExclude set_column_template]
    // only set the columnsTemplate property. when the content exceeds the grid area, it can be scrolled vertically.
    this.gridViewManager.setViewStyle()
      .columnsTemplate("1fr 1fr 1fr");
    // [StartExclude set_column_template]
    // [EndExclude control_scroll_position]
    this.gridViewManager.setViewStyle(this.scroller);
    // [StartExclude control_scroll_position]
    // [EndExclude combine_item]
    // [EndExclude fast_when_start]
    // register the reusable template.
    this.gridViewManager.registerNodeItem("card", wrapBuilder(buildCard));
    this.gridViewManager.registerNodeItem("user", wrapBuilder(buildUserCard));
    this.gridViewManager.registerNodeItem("manager", wrapBuilder(buildManagerCard));
    // [StartExclude combine_item]
    // key point: `preCreate()` pre-creates the reusable template,
    // which must be registered before the reusable template.
    this.gridViewManager.preCreate("card", 25);
    this.gridViewManager.preCreate("user", 10);
    this.gridViewManager.preCreate("manager", 30);
    // [StartExclude fast_when_start]
    this.viewModel.registerPrefetch()

    // [EndExclude set_item_style]
    this.gridViewManager.setItemViewStyle((gridItem) => {
      gridItem({ style: GridItemStyle.PLAIN })
        .width(80) // set the cell width to 80vp.
        .backgroundColor($r('app.color.home_background_color'))
        .selectable(false)
    });
    // [StartExclude set_item_style]
    // [EndExclude long_press_delete]
    // register 'delete' event listener.
    this.getUIContext().getHostContext()?.eventHub.on(CommonConstants.EVENT_REMOVE_ITEM, (id: number) => {
      animateToImmediately({ duration: 500 }, () => {
        this.viewModel.deleteData(id);
      })
    });
    // [StartExclude long_press_delete]

    this.viewModel.loadData();
    // [EndExclude set_gap]
    // [EndExclude fast_when_start]
    // [EndExclude set_column_template]
    // [EndExclude control_scroll_position]
    // [EndExclude set_item_style]
    // [EndExclude long_press_delete]
    // [EndExclude combine_item]
  }
  // [End set_item_style]
  // [End set_column_template]
  // [End set_gap]
  // [End fast_when_start]
  // [StartExclude combine_item]

  // [StartExclude control_scroll_position]
  aboutToDisappear(): void {
    // when the page is destroyed, cancel the deletion listener.
    this.getUIContext().getHostContext()?.eventHub.off(CommonConstants.EVENT_REMOVE_ITEM);
    this.viewModel.destroy();
  }
  // [End long_press_delete]
  // [EndExclude combine_item]

  // [EndExclude control_scroll_position]
  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // main grid
      RecyclerView({
        viewManager: this.gridViewManager
      })
      // [StartExclude combine_item]

      Row() {
        // button goto pre page
        Button() {
          // [StartExclude control_scroll_position]
          Text() {
            SymbolSpan($r('sys.symbol.chevron_left_2'))
          }
          .fontSize(35)
          // [EndExclude control_scroll_position]
        }
        // [StartExclude control_scroll_position]
        .backgroundColor(Color.White)
        .width(55)
        // [EndExclude control_scroll_position]
        .onClick(() => {
          this.viewModel.prePage();
        })

        // button goto next page
        Button() {
          // [StartExclude control_scroll_position]
          Text() {
            SymbolSpan($r('sys.symbol.chevron_left_2'))
          }
          .fontSize(35)
          .rotate({
            centerX: '50%',
            centerY: '50%',
            centerZ: 0,
            perspective: 0,
            angle: '180deg'
          })
          // [EndExclude control_scroll_position]
        }
        // [StartExclude control_scroll_position]
        .backgroundColor(Color.White)
        .width(55)
        // [EndExclude control_scroll_position]
        .onClick(() => {
          this.viewModel.nextPage();
        })
      }
      // [StartExclude control_scroll_position]
      .backgroundColor('FFF1F0F0')
      .width(200)
      .height(36)
      .borderRadius(18)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceAround)
      .margin({
        bottom: 20
      })
      // [EndExclude control_scroll_position]
      // [EndExclude combine_item]
    }
  }
}
// [End control_scroll_position]

/**
 * grid manager class
 */
class GridViewManager extends GridManager {
  onWillCreateItem(index: number, data: UserInfoViewModel): NodeItem<CardCellData> | null {
    let node: NodeItem<CardCellData> | null = this.dequeueReusableNodeByType('card');
    node?.setData({ user: data });
    return node;
  }
}
// [End combine_item]

export interface CardCellData {
  user: UserInfoViewModel;
}