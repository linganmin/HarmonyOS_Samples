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
import { util } from '@kit.ArkTS';
import { BlogData, Params } from '../model/types';
import { CommonConstants } from '../common/constants/CommonConstants';
import { Utils } from '../common/util/Utils';
import { BottomContent, HeaderComponent } from './CombineWaterFlowPage';
import { Logger } from '../common/util/Logger';
import { PullToRefresh } from '@ohos/pulltorefresh';
import { isChinese } from '../model/mock'

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

@Component
export struct SharedPoolPage {
  waterFlowView: MyWaterFlowManager = new MyWaterFlowManager({
    defaultNodeItem: 'TestBlogItemContainer',
    context: this.getUIContext()
  });
  scroller: Scroller = new Scroller();
  @State data: Array<BlogData> = [];
  @State isRefreshing: boolean = false;

  aboutToDisappear(): void {
    Utils.getInstance().nodePool?.clear()
  }

  aboutToAppear(): void {
    this.initView();
    generateRandomBlogData().then((data: ESObject) => {
      this.data = data;
      this.waterFlowView.setDataSource(data);
    });
    // [Start Share_Pool]
    if (Utils.getInstance().nodePool) {
      // Registration Reuse Pool
      this.waterFlowView.registerRecyclePool(Utils.getInstance().nodePool!);
    } else {
      Utils.getInstance().nodePool = this.waterFlowView.getRecyclePool();
    }
    // [End Share_Pool]
    // Reusable Registration Template.
    this.waterFlowView.registerNodeItem('TestBlogItemContainer', wrapBuilder(MyBlogItemContainer));
    this.waterFlowView.registerNodeItem('GridImageViewContainer', wrapBuilder(GridImageViewContainer));
    // Pre-creation
    this.waterFlowView.preCreate('TestBlogItemContainer', 30);
    this.waterFlowView.preCreate('GridImageViewContainer', 30);
    Logger.info('SharedPoolPage==>  nodePool : ' + JSON.stringify(util.getHash(this.waterFlowView.getRecyclePool())));
  }

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
  }

  // [Start Pull_Refresh_2]
  @Builder
  getWaterFlow() {
    RecyclerView({
      viewManager: this.waterFlowView
    })
  }
  // [End Pull_Refresh_2]

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
      // [Start Load_More]
      // [Start Pull_Refresh_3]
      PullToRefresh({
        data: $data,
        scroller: this.scroller,
        customList: () => {
          this.getWaterFlow()
        },
        // [StartExclude Load_More]
        onRefresh: () => {
          return new Promise<string>((resolve) => {
            isChinese() ? resolve('刷新成功') : resolve('Refresh successful')
            // [Start Pull_Refresh_1]
            generateRandomBlogData().then((data: ESObject) => {
              this.data = data;
              this.waterFlowView.setDataSource(data);
            });
            // [End Pull_Refresh_1]
          })
        },
        // [EndExclude Load_More]
        // [StartExclude Pull_Refresh_3]
        onLoadMore: () => {
          return new Promise<string>((resolve) => {
            resolve('');
            generateRandomBlogData().then((data: ESObject) => {
              this.waterFlowView.nodeAdapter.pushData(data);
            });
          })
        }
        // [EndExclude Pull_Refresh_3]
      })
        .layoutWeight(1)
      // [End Pull_Refresh_3]
      // [Start Load_More]
    }
    .height(CommonConstants.FULL_HEIGHT)
    .backgroundColor('#F5F5F5')
  }
}

@Builder
function MyBlogItemContainer($$: Params) {
  MyBlogItem({ blogItem: $$.blogItem })
}

@Component
struct MyBlogItem {
  @State blogItem: BlogData = new BlogData();

  // In reusable components, you must use aboutToReuse to update data, just like native recycling.
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

@Builder
export function GridImageViewContainer($$: Params) {
  GridImageView({ blogItem: $$.blogItem })
}

@Component
struct GridImageView {
  @State blogItem: BlogData = new BlogData();

  // In reusable components, you must use aboutToReuse to update data, just like native recycling.
  aboutToReuse(params: ESObject): void {
    this.blogItem = params.blogItem;
  }

  build() {
    Image(this.blogItem.images[0])
      .sourceSize({ width: 100, height: 100 })
      .width(CommonConstants.FULL_WIDTH)
      .aspectRatio(1)
      .objectFit(ImageFit.Cover)
  }
}


