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

import { NodeItem, PartReuse, RecyclerView, WaterFlowManager } from '@hadss/scroll_components';
import { Utils } from '../common/util/Utils';
import { util } from '@kit.ArkTS';
import { CommonConstants } from '../common/constants/CommonConstants';
import { BlogData, Params } from '../model/types';
import { BottomContent, HeaderComponent } from './CombineWaterFlowPage';
import { Logger } from '../common/util/Logger';
import { GridImageViewContainer } from './SharedPoolPage';

@Concurrent
async function generateRandomBlogData(): Promise<BlogData[]> {
  const module = await import('../model/mock');
  return module.generateRandomBlogData(30);
}

class MyWaterFlowManager extends WaterFlowManager {
  onWillCreateItem(index: number, data: BlogData) {
    let node: NodeItem<Params> | null = this.dequeueReusableNodeByType('TestBlogItemContainer');
    node?.setData({ blogItem: data });
    return node;
  }
}
// [Start Share_Pool]
@Component
export struct SharedPoolSecondPage {
  waterFlowView: MyWaterFlowManager = new MyWaterFlowManager({
    defaultNodeItem: 'TestBlogItemContainer',
    context: this.getUIContext()
  });
  // [StartExclude Share_Pool]
  scroller: Scroller = new Scroller();
  @State data: Array<BlogData> = [];
  @State isRefreshing: boolean = false;

  aboutToDisappear(): void {
    Utils.getInstance().nodePool?.clear()
  }
  // [EndExclude Share_Pool]

  aboutToAppear(): void {
    // [StartExclude Share_Pool]
    this.initView();
    generateRandomBlogData().then((data: ESObject) => {
      this.data = data;
      this.waterFlowView.setDataSource(data);
    });
    // [EndExclude Share_Pool]
    if (Utils.getInstance().nodePool) {
      // Registration Reuse Pool.
      this.waterFlowView.registerRecyclePool(Utils.getInstance().nodePool!);
    } else {
      Utils.getInstance().nodePool = this.waterFlowView.getRecyclePool();
    }
    // [StartExclude Share_Pool]
    // Reusable Registration Template.
    this.waterFlowView.registerNodeItem('TestBlogItemContainer', wrapBuilder(MyBlogItemContainer));
    this.waterFlowView.registerNodeItem('GridImageViewContainer', wrapBuilder(GridImageViewContainer));
    // Pre-initialization.
    this.waterFlowView.preCreate('TestBlogItemContainer', 30);
    this.waterFlowView.preCreate('GridImageViewContainer', 30);
    Logger.info('SharedPoolSecondPage==>  nodePool : ' +
    JSON.stringify(util.getHash(this.waterFlowView.getRecyclePool())));
    // [EndExclude Share_Pool]
  }

  // [StartExclude Share_Pool]
  initView() {
    this.waterFlowView.setViewStyle({ scroller: this.scroller })
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .columnsTemplate(CommonConstants.WATER_FLOW_COLUMNS_TEMPLATE)
      .columnsGap(CommonConstants.COLUMNS_GAP)
      .rowsGap(CommonConstants.ROWS_GAP)
      .padding({
        top: CommonConstants.PADDING,
        left: CommonConstants.PADDING,
        right: CommonConstants.PADDING
      })
      .onScrollIndex((_start: number, end: number) => {
        if (end > this.waterFlowView.nodeAdapter.totalNodeCount - 10) {
          setTimeout(() => {
            generateRandomBlogData().then((data: ESObject) => {
              this.waterFlowView.nodeAdapter.pushData(data)
            })
          }, 100)
        }
      })
  }

  @Builder
  getWaterFlow() {
    RecyclerView({
      viewManager: this.waterFlowView
    })
  }

  build() {
    Column() {
      // Header navigation bar.
      Row() {
        Text($r('app.string.scenario_waterFlow3'))
          .fontWeight(FontWeight.Bold)
          .fontSize($r('app.float.title_font_size'))
          .width(CommonConstants.FULL_WIDTH)
          .fontColor($r('app.color.text_color'))
      }
      .padding(CommonConstants.PADDING)
      .width(CommonConstants.FULL_WIDTH)
      .backgroundColor(Color.White)

      Refresh({ refreshing: $$this.isRefreshing }) {
        this.getWaterFlow()
      }
      .layoutWeight(1)
      .onRefreshing(() => {
        generateRandomBlogData().then((data: BlogData[]) => {
          this.isRefreshing = false
          this.data = data;
          this.waterFlowView.setDataSource(data);
        })
      })

    }
    .height(CommonConstants.FULL_HEIGHT)
    .backgroundColor('#F5F5F5')
  }
  // [EndExclude Share_Pool]
}
// [End Share_Pool]
@Builder
function MyBlogItemContainer($$: Params) {
  MyBlogItem({ blogItem: $$.blogItem })
}

@Component
struct MyBlogItem {
  @State blogItem: BlogData = new BlogData();

  aboutToReuse(params: ESObject): void {
    this.blogItem = params.blogItem;
  }

  build() {
    Column({ space: 12 }) {
      HeaderComponent({ blogItem: this.blogItem })
      // Image display.
      if (this.blogItem?.images && this.blogItem.images.length > 0) {
        Column() {
          PartReuse({
            type: 'GridImageViewContainer',
            builder: wrapBuilder(GridImageViewContainer),
            data: { blogItem: this.blogItem }
          })
        }.height(150)
      }
      BottomContent({ blogItem: this.blogItem })
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}