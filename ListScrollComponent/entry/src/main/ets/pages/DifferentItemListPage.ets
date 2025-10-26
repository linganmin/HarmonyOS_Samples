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
import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants } from '../common/constants/CommonConstants';
import { Logger } from '../common/util/Logger';
import { BlogData, Params } from '../model/types';
import { EasyBlogItem } from '../component/PublicView';
import { DifferentItemViewModel } from '../viewmodel/DifferentItemViewModel';
import { JSON } from '@kit.ArkTS';
import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh';

@Builder
function buildDifferentItemListPage() {
  DifferentItemListPage()
}

// [Start quick_start_4_c]
// [Start Pull_Refresh]
// [Start Load_More]
@Component
struct DifferentItemListPage {
  myListManager: MyListManager = new MyListManager({
    defaultNodeItem: 'EasyBlogItemContainer',
    context: this.getUIContext()
  });
  @State dataArray: BlogData[] = [];
  @State myViewModel: DifferentItemViewModel = new DifferentItemViewModel(this.myListManager, this.dataArray);
  // [StartExclude quick_start_4_c]
  // [StartExclude Pull_Refresh]
  // [StartExclude Load_More]
  scroller: Scroller = new Scroller();
  refreshConfigurator = new PullToRefreshConfigurator()
    .setLoadBackgroundColor($r('app.color.home_background_color'));
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass = (this.context as common.UIAbilityContext).windowStage.getMainWindowSync();

  // [EndExclude quick_start_4_c]
  aboutToAppear(): void {
    // [StartExclude quick_start_4_c]
    let orientation = window.Orientation.AUTO_ROTATION;
    this.windowClass.setPreferredOrientation(orientation, (err: BusinessError) => {
      const errCode: number = err.code;
      if (errCode) {
        Logger.error('Failed to set window orientation. Cause:' + JSON.stringify(err));
        return;
      }
      Logger.info('Succeed to setting window orientation');
    })

    this.initView();
    // [EndExclude quick_start_4_c]
    this.myListManager.registerNodeItem('EasyBlogItemContainer', wrapBuilder(EasyBlogItemContainer));
    this.myListManager.registerNodeItem('HotVideoBlogItemContainer', wrapBuilder(HotVideoBlogItemContainer));
    this.myListManager.preCreate('HotVideoBlogItemContainer', 30);
    this.myListManager.preCreate('EasyBlogItemContainer', 30);
    this.myViewModel.loadData();
  }

  initView() {
    this.myListManager.setItemViewStyle((_item, _index, _data: ESObject) => {
    })
    this.myListManager.setViewStyle({ space: 10, scroller: this.scroller })
    // [StartExclude quick_start_4_c]
      .cachedCount(2)
      .width('100%')
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
    // [EndExclude quick_start_4_c]
  }

  // [EndExclude Pull_Refresh]
  // [EndExclude Load_More]
  @Builder
  buildListView() {
    RecyclerView({
      viewManager: this.myListManager
    })
  }

  build() {
    // [StartExclude quick_start_4_c]
    // [StartExclude Pull_Refresh]
    // [StartExclude Load_More]
    NavDestination() {
      Column() {
        Row({ space: 8 }) {
          Text($r('app.string.page_different_item'))
            .fontSize($r('app.float.title_font_size'))
            .fontWeight(FontWeight.Bold)
        }
        .padding(12)
        .width(CommonConstants.FULL_WIDTH)
        .backgroundColor(Color.White)

        // [EndExclude quick_start_4_c]
        // [EndExclude Pull_Refresh]
        // [EndExclude Load_More]
        PullToRefresh({
          // [StartExclude quick_start_4_c]
          data: $dataArray,
          scroller: this.scroller,
          refreshConfigurator: this.refreshConfigurator,
          // [EndExclude quick_start_4_c]
          customList: () => {
            this.buildListView();
          },
          // [StartExclude quick_start_4_c]
          // [StartExclude Load_More]
          onRefresh: () => {
            return new Promise<string>((resolve, _reject) => {
              this.myViewModel.loadData((isSuccess) => {
                // [StartExclude Pull_Refresh]
                if (isSuccess) {
                  resolve('');
                } else {
                  resolve('');
                }
                // [EndExclude Pull_Refresh]
              });
            });
          },
          // [EndExclude Load_More]
          // [StartExclude Pull_Refresh]
          onLoadMore: () => {
            return new Promise<string>((resolve) => {
              this.myViewModel.loadDataMore((isSuccess) => {
                // [StartExclude Load_More]
                if (isSuccess) {
                  resolve('');
                } else {
                  resolve('');
                }
                // [EndExclude Load_More]
              });
            });
          }
          // [EndExclude quick_start_4_c]
          // [EndExclude Pull_Refresh]
        })
        // [StartExclude quick_start_4_c]
        // [StartExclude Pull_Refresh]
        // [StartExclude Load_More]
      }
      .padding({ bottom: 30 })
      .backgroundColor($r('app.color.home_background_color'))
    }
    .hideTitleBar(true)
    .backgroundColor(Color.White)
    // [EndExclude Pull_Refresh]
    // [EndExclude Load_More]
    // [EndExclude quick_start_4_c]
  }
}
// [End Pull_Refresh]
// [End Load_More]
// [End quick_start_4_c]
// [Start quick_start_4_c]
class MyListManager extends ListManager {
  onWillCreateItem(index: number, data: BlogData) {
    if (index % 4 === 3) {
      let node: NodeItem<Params> | null = this.dequeueReusableNodeByType('HotVideoBlogItemContainer');
      node?.setData({ blogData: data });
      return node;
    }
    let node: NodeItem<Params> | null = this.dequeueReusableNodeByType('EasyBlogItemContainer');
    node?.setData({ blogData: data });
    return node;
  }
}

// Reusable EasyBlog Component Template
@Builder
function EasyBlogItemContainer($$: Params) {
  EasyBlogItem({ blogData: $$.blogData })
}

// Reusable HotVideoBlog Component Template
@Builder
function HotVideoBlogItemContainer($$: Params) {
  HotVideoBlogItem({ blogData: $$.blogData })
}
// [End quick_start_4_c]

@Component
struct HotVideoBlogItem {
  @State blogData: BlogData = new BlogData();

  aboutToReuse(params: Record<string, ESObject>): void {
    this.blogData = params.blogData;
  }

  build() {
    Column({ space: 12 }) {
      Text($r('app.string.hot_video'))
        .fontSize(16)
        .lineHeight(20)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.None })
        .width('100%')
        .height('auto')
        .padding({ left: 12 })
      List({ space: 12 }) {
        ForEach(this.blogData.images, (image: string) => {
          ListItem() {
            Stack() {
              Image(image)
                .sourceSize({ width: 100, height: 100 })
                .width(100)
                .height(130)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
            }
          }
        }, (item: string) => JSON.stringify(item))
      }
      .contentStartOffset(12)
      .contentEndOffset(12)
      .width('100%')
      .height(130)
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
    }
    .justifyContent(FlexAlign.Start)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(Color.White)
  }
}