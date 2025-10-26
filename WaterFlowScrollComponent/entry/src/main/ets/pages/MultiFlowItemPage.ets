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

import { NodeItem, RecyclerView, WaterFlowManager } from '@hadss/scroll_components';
import { common } from '@kit.AbilityKit';
import { CommonConstants } from '../common/constants/CommonConstants';
import { BlogData, Params } from '../model/types';
import { collections, taskpool } from '@kit.ArkTS';
import { sceneMockData } from '../workers/GetNetworkData';
import { generateImages } from '../model/mock';

@Concurrent
async function generateRandomBlogData(): Promise<BlogData[]> {
  let array: collections.Array<sceneMockData> = await generateImages();
  const module = await import('../model/mock');
  let data = module.generateRandomBlogData(array.length);
  for (let index = 0; index < array.length; index++) {
    data[index].content = array[index].title;
    data[index].images = [array[index].thumbnails];
  }
  return data;
}

// [Start quick_start_4_c]
class MyWaterFlowManager extends WaterFlowManager {
  onWillCreateItem(index: number, data: BlogData) {
    let node: NodeItem<Params>
    if (index % 2 === 0) {
      node = this.dequeueReusableNodeByType('ImageContainer');
    } else  {
      node = this.dequeueReusableNodeByType('TextContainer');
    }
    node?.setData({ blogItem: data });
    return node;
  }
}
// [End quick_start_4_c]

// [Start quick_start_4_c]
@Entry
@Component
struct MultiFlowItemPage {
  waterFlowView: MyWaterFlowManager = new MyWaterFlowManager({
    defaultNodeItem: 'ImageContainer',
    context: this.getUIContext()
  });
  scroller: Scroller = new Scroller();
  @State dataArray: BlogData[] = [] // Bind data source for data iteration

  aboutToAppear(): void {
    this.initView();
    taskpool.execute(generateRandomBlogData).then((data: ESObject) => {
      this.dataArray = data;
      this.waterFlowView.setDataSource(data);
    })

    this.waterFlowView.registerNodeItem('ImageContainer', wrapBuilder(ImageContainer));
    this.waterFlowView.registerNodeItem('TextContainer', wrapBuilder(TextContainer));

    // [StartExclude quick_start_4_c]
    this.waterFlowView.preCreate('ImageContainer', 30);
    this.waterFlowView.preCreate('TextContainer', 30);
    // [EndExclude quick_start_4_c]
  }

  initView() {
    this.waterFlowView.setViewStyle({ scroller: this.scroller })
      // [StartExclude quick_start_4_c]
      .height(CommonConstants.FULL_HEIGHT)
      .columnsTemplate(CommonConstants.WATER_FLOW_COLUMNS_TEMPLATE)
      .columnsGap(CommonConstants.COLUMNS_GAP)
      .rowsGap(CommonConstants.ROWS_GAP)
      .padding({
        top: CommonConstants.PADDING,
        left: CommonConstants.PADDING,
        right: CommonConstants.PADDING
      })
    // [EndExclude quick_start_4_c]
  }

  build() {
    Column() {
      RecyclerView({
        viewManager: this.waterFlowView
      })
    }
    .height(CommonConstants.FULL_HEIGHT)
    .backgroundColor($r('app.color.home_background_color'))
  }
}
// [End quick_start_4_c]

// [Start quick_start_4_c]
// Reusable Image Component Template.
@Builder
function ImageContainer($$: Params) {
  ImageContainerView({ blogItem: $$.blogItem })
}
// [End quick_start_4_c]

@Component
struct ImageContainerView {
  @State blogItem: BlogData = new BlogData();
  @State showMenu: boolean = false;
  @State flowHeight: Length = 0;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToReuse(params: ESObject): void {
    this.blogItem = params.blogItem;
  }

  build() {
    Stack() {
      Image(this.blogItem.images[0])
        .sourceSize({ width: 100, height: 100 })
        .width(CommonConstants.FULL_WIDTH)
        .aspectRatio(1)
        .objectFit(ImageFit.Cover)
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.flowHeight = newValue.height;
        })
    }
    .borderRadius(12)
    .clip(true)
  }
}

// [Start quick_start_4_c]
// Reusable Text Component Template.
@Builder
function TextContainer($$: Params) {
  TextContainerView({ blogItem: $$.blogItem })
}
// [End quick_start_4_c]

@Component
struct TextContainerView {
  @State blogItem: BlogData = new BlogData();
  @State flowHeight: Length = 0;

  aboutToReuse(params: ESObject): void {
    this.blogItem = params.blogItem;
  }

  build() {
    Stack() {
      Text(this.blogItem.content)
        .width(CommonConstants.FULL_WIDTH)
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.flowHeight = newValue.height;
        })
        .padding(CommonConstants.PADDING)
        .borderRadius(12)
        .borderWidth(2)
        .borderColor(Color.Grey)
    }
    .borderRadius(12)
    .clip(true)
  }
}