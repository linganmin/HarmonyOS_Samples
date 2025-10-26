/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import * as Const from '../common/constant/CommonConstants';
import Item from './NewsItem';
import ListModel from '../model/ListModel';
import { ResData, Refresh } from '../common/types/CommonTypes';
import { getUrl, loadMore, refreshing, refreshState } from '../common/utils/Refresh';
import { common } from '@kit.AbilityKit';

@Component
export default struct ListPage {
  @State isRefresh: boolean = false;
  @State newsModel: ListModel = new ListModel();
  @Watch('getInitData') @LocalStorageLink('List') List: ResData[] = [];
  @LocalStorageLink('Fail') isFail: boolean = false;
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  getInitData() {
    this.newsModel.currentPage = 1;
    if (this.List.length === this.newsModel.pageSize) {
      this.newsModel.currentPage++;
      this.newsModel.hasMore = true;
    } else {
      this.newsModel.hasMore = false;
    }
    this.newsModel.newsData = this.List;
    if (this.List.length !== 0) {
      this.newsModel.pageState = Const.PageState.SUCCESS;
    }
  }

  aboutToAppear() {
    this.getInitData();
  }

  build() {
    Column() {
      if (!this.isFail && this.newsModel.pageState === Const.PageState.SUCCESS) {
        this.listLayout()
      } else if (!this.isFail && this.newsModel.pageState === Const.PageState.LOADING) {
        this.loadingLayout()
      } else {
        this.failLayout()
      }
    }
    .width(Const.FULL_WIDTH)
    .height(Const.FULL_HEIGHT)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  loadingLayout() {
    this.refreshLayout({
      isVisible: true,
      imageSrc: $r('app.media.ic_pull_up_load'),
      textValue: $r('app.string.pull_up_load_text'),
      heightValue: this.newsModel.pullDownRefreshHeight,
    })
  }

  @Builder
  refreshBuilder() {
    this.refreshLayout({
      isVisible: true,
      imageSrc: this.newsModel.pullDownRefreshImage,
      textValue: this.newsModel.pullDownRefreshText,
      heightValue: this.newsModel.pullDownRefreshHeight,
    })
  }

  @Builder
  listLayout() {
    Refresh({ refreshing: $$this.isRefresh, builder: this.refreshBuilder }) {
      List() {
        ForEach(this.newsModel.newsData, (item: ResData) => {
          ListItem() {
            Item({ itemData: item })
          }
          .width(Const.FULL_WIDTH)
          .backgroundColor($r('app.color.white'))
          .margin({ bottom: Const.LIST_ITEM_MARGIN_TOP })
          .borderRadius(Const.LIST_ITEM_BORDER_RADIUS)
          .align(Alignment.Top)
        }, (item: ResData, index?: number) => `${item.id}${index}`)

        ListItem() {
          if (this.newsModel.hasMore) {
            this.loadMore({
              isVisible: true,
              imageSrc: this.newsModel.pullUpLoadImage,
              textValue: this.newsModel.pullUpLoadText,
              heightValue: this.newsModel.pullUpLoadHeight,
            })
          } else {
            this.noMore()
          }
        }
      }
      .width(Const.FULL_WIDTH)
      .height(Const.FULL_HEIGHT)
      .padding({ left: Const.LIST_MARGIN_LEFT, right: Const.LIST_MARGIN_RIGHT })
      .backgroundColor($r('app.color.listColor'))
      .edgeEffect(EdgeEffect.None)
      .onScrollIndex((start: number, end: number) => {
        // Listen to the first index of the current list.
        this.newsModel.startIndex = start;
        this.newsModel.endIndex = end;

        loadMore(this.newsModel, getUrl(this.context));
      })
    }
    .width(Const.FULL_WIDTH)
    .onStateChange((state: RefreshStatus) => {
      refreshState(this.newsModel, state);
    })
    .onRefreshing(() => {
      refreshing(this.newsModel, getUrl(this.context)).finally(() => {
        this.isRefresh = false;
      });
    })
    .refreshOffset(Const.CUSTOM_LAYOUT_HEIGHT)
    .pullToRefresh(true)
  }

  @Builder
  failLayout() {
    Image($r('app.media.none'))
      .height(Const.LIST_NONE_IMAGE_SIZE)
      .width(Const.LIST_NONE_IMAGE_SIZE)
    Text($r('app.string.page_none_msg'))
      .opacity(Const.LIST_NONE_TEXT_OPACITY)
      .fontSize(Const.LIST_NONE_TEXT_SIZE)
      .fontColor($r('app.color.fontColor_text3'))
    .margin({ top: Const.LIST_NONE_TEXT_MARGIN })
  }

  @Builder
  refreshLayout(refresh: Refresh) {
    Row() {
      Image(refresh.imageSrc)
        .width(Const.REFRESH_IMAGE_WIDTH)
        .height(Const.REFRESH_IMAGE_HEIGHT)

      Text(refresh.textValue)
        .margin({
          left: Const.REFRESH_TEXT_MARGIN_LEFT,
          bottom: Const.REFRESH_TEXT_MARGIN_BOTTOM
        })
        .fontSize(Const.REFRESH_TEXT_FONT_SIZE)
        .textAlign(TextAlign.Center)
    }
    .clip(true)
    .width(Const.FULL_WIDTH)
    .justifyContent(FlexAlign.Center)
    .height(refresh.heightValue)
  }

  @Builder
  loadMore(refresh: Refresh) {
    Column() {
      if (refresh.isVisible) {
        this.refreshLayout(refresh)
      }
    }
  }

  @Builder
  noMore() {
    Row() {
      Text($r('app.string.prompt_message'))
        .margin({ left: Const.NO_MORE_NORMAL_PADDING })
        .fontSize(Const.NO_MORE_TITLE_FONT)
        .textAlign(TextAlign.Center)
    }
    .width(Const.FULL_WIDTH)
    .margin({ bottom: Const.TAB_HEIGHT })
    .justifyContent(FlexAlign.Center)
    .height(Const.CUSTOM_LAYOUT_HEIGHT)
  }
}