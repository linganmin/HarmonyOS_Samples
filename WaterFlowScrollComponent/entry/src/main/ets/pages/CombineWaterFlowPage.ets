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
import { NodeItem, PartReuse, RecyclerView, WaterFlowManager } from '@hadss/scroll_components';
// [End quick_start_4_b]
import { BlogData, Params } from '../model/types';
import { collections, JSON, MessageEvents, taskpool, util, worker } from '@kit.ArkTS';
import { CommonConstants } from '../common/constants/CommonConstants';
import { Logger } from '../common/util/Logger';
import { ComponentContent } from '@kit.ArkUI';
import { sceneMockData } from '../workers/GetNetworkData';
import { generateImages } from '../model/mock';
import { common } from '@kit.AbilityKit';
import { isChinese } from '../model/mock'
import { BusinessError } from '@kit.BasicServicesKit'

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

class MyWaterFlowManager extends WaterFlowManager {
  onWillCreateItem(index: number, data: BlogData) {
    let node: NodeItem<Params> | null = this.dequeueReusableNodeByType('BlogItemContainer');
    node?.setData({ blogItem: data });
    return node;
  }
}

enum FooterState {
  Loading = 0,
  End = 1
}

class MyParams {
  footerState: FooterState = FooterState.Loading;

  constructor(footerState: FooterState) {
    this.footerState = footerState;
  }
}

@Builder
function buildText(params: MyParams) {
  Column() {
    if (params.footerState == FooterState.Loading) {
      Row() {
        LoadingProgress().width(30).height(30)
        Text($r('app.string.loading'))
          .fontSize(12)
          .height(30)
          .margin({ top: 2 })
      }
    } else if (params.footerState == FooterState.End) {
      Text($r('app.string.load_done'))
        .fontSize(12)
        .height(30)
        .align(Alignment.Center)
        .margin({ top: 2 })
    } else {
      Text($r('app.string.loading'))
        .fontSize(12)
        .height(30)
        .align(Alignment.Center)
        .margin({ top: 2 })
    }
  }
  .width('100%')
  .alignItems(HorizontalAlign.Center)
}

@Entry
@Component
struct WaterFlowPage {
  @State footerState: FooterState = FooterState.Loading
  waterFlowView: WaterFlowManager = new MyWaterFlowManager({
    defaultNodeItem: "BlogItemContainer",
    context: this.getUIContext()
  });
  scroller: Scroller = new Scroller();
  @State data: Array<BlogData> = [];
  private fetches: Map<number, BlogData> = new Map();
  footerContent: ComponentContent<MyParams> =
    new ComponentContent<MyParams>(this.getUIContext(), wrapBuilder<[MyParams]>(buildText),
      new MyParams(this.footerState));
  @State isLoadMore: boolean = false;
  fetchAgent = new worker.ThreadWorker('entry/ets/workers/FetchAgent.ets', { name: 'fetchAgent' });
  cachePath = (this.getUIContext().getHostContext() as common.Context).getApplicationContext().cacheDir;
  imageCaches: Map<string, string> = new Map();

  // [Start PreCreate]
  aboutToAppear(): void {
    // [StartExclude PreCreate]
    this.initView();
    // [Start Prefetch_1]
    // Registers the callback that prefetcher invokes when a data referenced by a data source item needs to be fetched.
    this.waterFlowView.registerFetchCallback(this.fetchCallback);
    /**
     * Registers the callback that prefetcher invokes when a specific fetch should be
     * canceled to avoid wasting system resources, such as network bandwidth.
     */
    this.waterFlowView.registerCancelCallback(this.cancelCallback);
    taskpool.execute(generateRandomBlogData).then((data: ESObject) => {
      this.data = data;
      this.waterFlowView.setDataSource(data);
    }).catch((err: Error) => {
      const error = err as BusinessError
      Logger.error(`generateRandomBlogData failed, code = ${error.code} message = ${error.message}`)
    });
    // [End Prefetch_1]
    // [EndExclude PreCreate]
    // register components.
    this.waterFlowView.registerNodeItem('BlogItemContainer', wrapBuilder(BlogItemContainer));
    this.waterFlowView.registerNodeItem('AdaptiveTextComponent', wrapBuilder(AdaptiveTextComponentContainer));
    this.waterFlowView.registerNodeItem('GridImageViewContainer', wrapBuilder(GridImageViewContainer));

    this.waterFlowView.preCreate('BlogItemContainer', 30);
    this.waterFlowView.preCreate('AdaptiveTextComponent', 30);
    this.waterFlowView.preCreate('GridImageViewContainer', 30);
    // [StartExclude PreCreate]
    Logger.info('WaterFlowPage==>  nodePool : ' + JSON.stringify(util.getHash(this.waterFlowView.getRecyclePool())));

    this.workerOnMessage();
    // [EndExclude PreCreate]
  }
  // [End PreCreate]

  aboutToDisappear() {
    try {
      this.fetchAgent.terminate();
    } catch (err) {
      const error = err as BusinessError
      Logger.error(`FetchAgent terminate failed. code = ${error.code}, message = ${error.message}`);
    }
    this.imageCaches.clear();
    this.fetches.clear();
  }

  initView() {
    // [Start Prefetch_3]
    this.waterFlowView.setViewStyle({
      scroller: this.scroller
    })
      // [StartExclude Prefetch_3]
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .columnsTemplate(CommonConstants.WATER_FLOW_COLUMNS_TEMPLATE)
      .columnsGap(CommonConstants.COLUMNS_GAP)
      .rowsGap(CommonConstants.ROWS_GAP)
      .padding({
        top: CommonConstants.PADDING,
        left: CommonConstants.PADDING,
        right: CommonConstants.PADDING
      })// [EndExclude Prefetch_3]
      .onScrollIndex((start: number, end: number) => {
        if (end > 0) {
          /**
           * Call this method when the visible area boundaries change.
           * The prefetcher will start prefetching after the first call to this method
           * in all cases where the autoStart option is not set to false.
           */
          this.waterFlowView.visibleAreaChanged(start, end);
        }
        // [StartExclude Prefetch_3]
        if (end + 30 > this.waterFlowView.nodeAdapter.totalNodeCount) {
          if (!this.isLoadMore) {
            this.isLoadMore = true
            taskpool.execute(generateRandomBlogData).then((data: ESObject) => {
              this.waterFlowView.nodeAdapter.pushData(data);
              this.isLoadMore = false;
            })
          }
        }
        // [EndExclude Prefetch_3]
      })
      .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean) => {
        /**
         * By default, the prefetcher begins invoking user code to fetch data with the first call to the visibleAreaChanged method.
         * Sometimes, this can waste resources because, in practice, onScrollIndex triggers the callback even when the component is not actually visible to the user.
         * To avoid this, subscribe to the onVisibleAreaChange event.
         */
        if (isVisible) {
          // Call this method to start prefetching.
          this.waterFlowView.nodeAdapter.prefetcher?.start();
        } else {
          // Call this method to stop prefetching. For instance, this should be done if a related component becomes invisible.
          this.waterFlowView.nodeAdapter.prefetcher?.stop();
        }
      })
    // [End Prefetch_3]
  }

  workerOnMessage() {
    this.fetchAgent.onmessage = (e: MessageEvents) => {
      let data = this.fetches.get(e.data.fetchId)
      if (data === undefined) {
        return;
      }

      switch (e.data.type) {
        case 'SUCCESS':
          if (data.callback) {
            data.callback(e.data.fetchUrl);
          } else {
            data.fetchUrl = e.data.fetchUrl
          }
          this.imageCaches.set(data.images[0], e.data.fetchUrl)
          this.fetches.delete(e.data.fetchId)
          break;
        case 'FAIL':
          this.fetches.delete(e.data.fetchId)
          break;
        default:
          break;
      }
    }
  }

  // [Start Prefetch_2]
  fetchCallback: (item: ESObject, fetchId: number) => Promise<void> = (item: ESObject, fetchId: number) => {
    let data = item as BlogData;
    if (data.images.length == 0) {
      return Promise.resolve();
    }
    let url = data.images[0];
    if (this.imageCaches.has(url)) {
      // If cached, skip re-downloading and load the data directly.
      if (data.callback) {
        data.callback(this.imageCaches.get(url));
      } else {
        data.fetchUrl = this.imageCaches.get(url) as string
      }
      return Promise.resolve();
    }
    this.fetches.set(fetchId, data);
    this.fetchAgent.postMessageWithSharedSendable({
      type: 'fetch',
      cachePath: this.cachePath,
      url: data.images[0],
      fetchId: fetchId
    });
    return Promise.resolve();
  }
  cancelCallback: (fetchId: number) => void = (fetchId: number) => {
    this.fetches.delete(fetchId);
    this.fetchAgent.postMessageWithSharedSendable({ type: 'cancel', fetchId: fetchId });
  }
  // [End Prefetch_2]

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
        Text($r('app.string.scenario_waterFlow2'))
          .fontSize($r('app.float.title_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_color'))
      }
      .padding(CommonConstants.PADDING)
      .width(CommonConstants.FULL_WIDTH)
      .backgroundColor(Color.White)

      this.getWaterFlow()
    }
    .height(CommonConstants.FULL_HEIGHT)
    .backgroundColor('#F5F5F5')
  }
}

@Builder
function BlogItemContainer($$: Params) {
  BlogItem({ blogItem: $$.blogItem })
}

// [Start quick_start_4_b]
@Component
struct BlogItem {
  @State blogItem: BlogData = new BlogData()

  // In reusable components, you must use aboutToReuse to update data, just like native recycling.
  aboutToReuse(params: ESObject): void {
    this.blogItem = params.blogItem;
  }

  aboutToRecycle(): void {
    this.blogItem.callback = undefined;
    this.blogItem.fetchUrl = ImageContent.EMPTY;
  }

  build() {
    Column({ space: 12 }) {
      HeaderComponent({ blogItem: this.blogItem })
      if (this.blogItem?.content.length > 0) {
        // cache component.
        PartReuse({
          type: 'AdaptiveTextComponent',
          builder: wrapBuilder(AdaptiveTextComponentContainer),
          data: { blogItem: this.blogItem }
        })
      }
      if (this.blogItem?.images && this.blogItem.images.length > 0) {
        PartReuse({
          type: 'GridImageViewContainer',
          builder: wrapBuilder(GridImageViewContainer),
          data: { blogItem: this.blogItem }
        })
      }

      BottomContent({ blogItem: this.blogItem })
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}
// [End quick_start_4_b]

@Component
export struct HeaderComponent {
  @ObjectLink blogItem: BlogData

  build() {
    Row({ space: 8 }) {
      Image(this.blogItem.user.avatar)
        .width(40)
        .height(40)
        .borderRadius(20)
      Column() {
        Text(this.blogItem.user.name)
          .fontSize(16)
          .fontColor('#333')
        Text(this.blogItem.time)
          .fontSize(12)
          .fontColor('#999')
      }.alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
  }
}

// [Start quick_start_4_b]
@Builder
export function AdaptiveTextComponentContainer($$: Params) {
  AdaptiveTextComponent({ blogItem: $$.blogItem })
}
// [End quick_start_4_b]
@Component
export struct AdaptiveTextComponent {
  @State private showFullText: boolean = false;
  @State blogItem: BlogData = new BlogData();

  // In reusable components, you must use aboutToReuse to update data, just like native recycling.
  aboutToReuse(params: ESObject): void {
    this.blogItem = params.blogItem;
  }

  build() {
    Stack() {
      // Text container.
      Text(isChinese() ? this.blogItem.content : 'The protection of personal privacy is urgently needed.')
        .fontSize(16)
        .lineHeight(20)
        .maxLines(this.showFullText ? undefined : 3)
        .textOverflow({ overflow: TextOverflow.None })
        .width('auto')
        .height('auto')

    }
    .width('auto')
    .height('auto')
  }
}

// [Start quick_start_4_b]
@Builder
function GridImageViewContainer($$: Params) {
  GridImageView({ blogItem: $$.blogItem })
}
// [End quick_start_4_b]
@Component
struct GridImageView {
  @State blogItem: BlogData = new BlogData()
  @State fetchUrl: string | ImageContent = ImageContent.EMPTY
  callback = (fetchUrl: string) => {
    this.blogItem.fetchUrl = fetchUrl;
    this.fetchUrl = fetchUrl;
  }

  aboutToAppear() {
    this.blogItem.callback = this.callback;
    this.fetchUrl = this.blogItem.fetchUrl;
  }

  aboutToRecycle() {
    this.blogItem.callback = undefined;
    this.fetchUrl = ImageContent.EMPTY;
  }

  aboutToReuse(params: ESObject): void {
    this.blogItem = params.blogItem;
    this.blogItem.callback = this.callback;
    this.fetchUrl = this.blogItem.fetchUrl;
  }

  build() {
    // [Start Prefetch_4]
    // Preload images using prefetch.
    Image(this.fetchUrl)
      .sourceSize({ width: 100, height: 100 })
      .width(CommonConstants.FULL_WIDTH)
      .aspectRatio(1)
      .objectFit(ImageFit.Cover)
    // [End Prefetch_4]
  }
}

@Component
export struct BottomContent {
  @ObjectLink blogItem: BlogData

  build() {
    // Interactive toolbar
    Row({ space: 20 }) {
      Row() {
        Image($r('app.media.icon_like'))
          .width(14)
          .height(14)
        Text(this.blogItem.likes.toString())
          .fontSize(14)
          .margin({ left: 4 })
      }
      .backgroundColor(Color.Transparent)

      Row() {
        Image($r('app.media.icon_comment'))
          .width(14)
          .height(14)
        Text(this.blogItem.comments.toString())
          .fontSize(14)
          .margin({ left: 4 })
      }
      .backgroundColor(Color.Transparent)

      Row() {
        Image($r('app.media.icon_share'))
          .width(14)
          .height(14)
        Text(this.blogItem.reposts.toString())
          .fontSize(14)
          .margin({ left: 2 })
      }
      .backgroundColor(Color.Transparent)
    }
    .width('50%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ top: 8 })
  }
}