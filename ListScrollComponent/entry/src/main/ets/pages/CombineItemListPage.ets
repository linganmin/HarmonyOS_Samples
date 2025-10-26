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

// [Start quick_start_4_b]
import { ListManager, NodeItem, PartReuse, RecyclerView, } from '@hadss/scroll_components';
// [End quick_start_4_b]
import { BlogData, ImagePixelMap, Params } from '../model/types';
import { CommonConstants } from '../common/constants/CommonConstants';
import { BlogItemHeaderView, BottomActionView } from '../component/PublicView';
import { CombineItemViewModel } from '../viewmodel/CombineItemViewModel';
import { Logger } from '../common/util/Logger';

@Builder
function buildCombineItemListPage() {
  CombineItemListPage()
}

// [Start quick_start_4_b]
// [Start Prefetch_4]
@Component
struct CombineItemListPage {
  // [StartExclude Prefetch_4]
  myListManager: MyListManager = new MyListManager({
    defaultNodeItem: "BlogItemContainer",
    context: this.getUIContext()
  });
  // [StartExclude quick_start_4_b]
  @State myViewModel: CombineItemViewModel = new CombineItemViewModel(this.myListManager);
  scroller: Scroller = new Scroller();

  // [Start Prefetch_3]
  // [EndExclude quick_start_4_b]
  // [Start PreCreate]
  aboutToAppear(): void {
    // [StartExclude PreCreate]
    // [StartExclude quick_start_4_b]
    this.initView();
    // Register a preload function callback
    this.myViewModel.registerPrefetch();
    // [EndExclude PreCreate]
    // [EndExclude quick_start_4_b]
    // [StartExclude Prefetch_3]
    // Register a reuse template
    this.myListManager.registerNodeItem('BlogItemContainer', wrapBuilder(BlogItemContainer));
    this.myListManager.registerNodeItem('AdaptiveTextComponentContainer', wrapBuilder(AdaptiveTextComponentContainer));
    this.myListManager.registerNodeItem('GridImageViewContainer', wrapBuilder(GridImageViewContainer));
    // [StartExclude quick_start_4_b]
    // Pre-creation Important: preCreate pre-creates a reusable template, which must be done after the reuse template is registered
    // Pre-create 30 list items to optimize the first-screen performance; the number can be adjusted according to actual needs.
    this.myListManager.preCreate('BlogItemContainer', 30);
    this.myListManager.preCreate('AdaptiveTextComponentContainer', 30);
    this.myListManager.preCreate('GridImageViewContainer', 30);
    // [StartExclude PreCreate]
    this.myViewModel.loadData();
    // [EndExclude Prefetch_3]
    // [EndExclude quick_start_4_b]
    // [EndExclude PreCreate]
  }
  // [StartExclude quick_start_4_b]

  // [EndExclude Prefetch_4]
  // [End Prefetch_3]
  // [End PreCreate]
  initView() {
    this.myListManager.setViewStyle({ space: 10, scroller: this.scroller })
    // [StartExclude Prefetch_4]
      .cachedCount(2)
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .contentStartOffset(20)
      .contentEndOffset(20)
      .divider({
        strokeWidth: 2,
        color: '#F5F5F5',
        startMargin: 20,
        endMargin: 20
      })
      .onClick(() => Logger.info('ListView onClick'))// [EndExclude Prefetch_4]
      .onScrollIndex((start: number, end: number) => {
        // Infinite swipe, when the 10th data is counted, new data is requested in advance
        if (end > this.myViewModel.dataArray.length - 10) {
          this.myViewModel.loadDataMore();
        }
        // Trigger a preload callback, request an image in advance, and resolve the white block of the image
        if (end > 0) {
          this.myListManager.visibleAreaChanged(start, end);
        }
      })
  }
  // [StartExclude Prefetch_4]
  build() {
    NavDestination() {
      Column() {
        Row({ space: 8 }) {
          Text($r('app.string.page_combine_item'))
            .fontSize($r('app.float.title_font_size'))
            .fontWeight(FontWeight.Bold)
        }
        .padding(12)
        .width('100%')
        .backgroundColor(Color.White)

        Column() {
          RecyclerView({
            viewManager: this.myListManager
          })
        }
      }
      .height(CommonConstants.FULL_HEIGHT)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .backgroundColor($r('app.color.home_background_color'))
    }
    .hideTitleBar(true)
  }
  // [EndExclude quick_start_4_b]
  // [EndExclude Prefetch_4]
}

// [End Prefetch_4]
// [End quick_start_4_b]
// [Start quick_start_4_b]
class MyListManager extends ListManager {
  onWillCreateItem(_index: number, data: BlogData) {
    let node: NodeItem<Params> | null = this.dequeueReusableNodeByType('BlogItemContainer');
    node?.setData({ blogData: data });
    return node;
  }
}

@Builder
function BlogItemContainer($$: Params) {
  BlogItem({ blogData: $$.blogData })
}

@Component
struct BlogItem {
  @State blogData: BlogData = new BlogData();

  aboutToReuse(params: Record<string, ESObject>): void {
    this.blogData = params.blogData;
  }

  build() {
    Column({ space: 12 }) {
      BlogItemHeaderView({ blogData: this.blogData })
      if (this.blogData?.content.length > 0) {
        PartReuse({
          type: 'AdaptiveTextComponent',
          builder: wrapBuilder(AdaptiveTextComponentContainer),
          data: { blogData: this.blogData }
        })
      }
      // Display pictures
      if (this.blogData?.images && this.blogData.images.length > 0) {
        PartReuse({
          type: 'GridImageViewContainer',
          builder: wrapBuilder(GridImageViewContainer),
          data: { blogData: this.blogData }
        })
      }
      BottomActionView({ blogData: this.blogData })
    }
    // [StartExclude quick_start_4_b]
    .justifyContent(FlexAlign.Start)
    .padding(12)
    .backgroundColor(Color.White)

    // [EndExclude quick_start_4_b]
  }
}

@Builder
function AdaptiveTextComponentContainer($$: Params) {
  AdaptiveTextComponent({ blogData: $$.blogData })
}

// [End quick_start_4_b]
@Component
struct AdaptiveTextComponent {
  @State private showFullText: boolean = false;
  @State blogData: BlogData = new BlogData();

  aboutToReuse(params: Record<string, ESObject>): void {
    this.blogData = params.blogData;
  }

  build() {
    Stack() {
      Text(this.blogData.content)
        .fontSize(16)
        .lineHeight(20)
        .maxLines(this.showFullText ? undefined : 3)
        .textOverflow({ overflow: TextOverflow.None })
        .width('100%')
        .height('auto')
        .onAreaChange((_oldValue, _newValue) => {
        })
    }
    .width('auto')
    .height('auto')
  }
}

// [Start quick_start_4_b]
@Builder
function GridImageViewContainer($$: Params) {
  GridImageView({ blogData: $$.blogData })
}

// [End quick_start_4_b]
// [Start Prefetch_5]
@Component
struct GridImageView {
  @State blogData: BlogData = new BlogData();

  aboutToReuse(params: Record<string, ESObject>): void {
    this.blogData = params.blogData;
  }

  build() {
    Grid() {
      ForEach(this.blogData.imagePixelMapArray, (image: ImagePixelMap | undefined, _index: number) => {
        GridItem() {
          Stack() {
            ObservedImage({ imagePixelMap: image })
          }
        }
      })
    }
    .columnsTemplate("1fr 1fr 1fr")
    .rowsGap(5)
    .columnsGap(5)
  }
}

@Component
struct ObservedImage {
  @ObjectLink imagePixelMap: ImagePixelMap;

  build() {
    Image(this.imagePixelMap.imagePixelMap)
      .sourceSize({ width: 100, height: 100 })
      .width('100%')
      .aspectRatio(1)
      .objectFit(ImageFit.Cover)
      .borderRadius(8)
  }
}

// [End Prefetch_5]