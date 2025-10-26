/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

// DocsCode 1
import { SongInfoItem } from '../model/LearningResource';
import DataSourcePrefetching from '../model/ArticleListData';
import { ObservedArray } from '../utils/ObservedArray';
import { ReusableArticleCardView } from '../components/ReusableArticleCardView';
import Constants from '../constants/Constants';
import PageViewModel from '../components/PageViewModel';
import { BasicPrefetcher } from '@kit.ArkUI';

@Entry
@Component
export struct LazyForEachListPage {
  @State collectedIds: ObservedArray<string> = ['1', '2', '3', '4', '5', '6'];
  @State likedIds: ObservedArray<string> = ['1', '2', '3', '4', '5', '6'];
  @State isListReachEnd: boolean = false;
  // 创建DataSourcePrefetching对象，具备任务预取、取消能力的数据源
  private readonly dataSource = new DataSourcePrefetching(PageViewModel.getItems());
  // 创建BasicPrefetcher对象，默认的动态预取算法实现
  private readonly prefetcher = new BasicPrefetcher(this.dataSource);

  build() {
    Column() {
      Header()
      List({ space: Constants.SPACE_16 }) {
        LazyForEach(this.dataSource, (item: SongInfoItem) => {
          ListItem() {
            ReusableArticleCardView({ articleItem: item })
          }
          .reuseId('article')
        })
      }
      .cachedCount(5)
      .onScrollIndex((start: number, end: number) => {
        // 列表滚动触发visibleAreaChanged，实时更新预取范围，触发调用prefetch、cancel接口
        this.prefetcher.visibleAreaChanged(start, end)
      })
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .padding({ left: 10, right: 10 })
      .layoutWeight(1)
    }
    .backgroundColor($r('app.color.text_background'))
  }
}
// DocsCode 1

@Builder
function Header() {
  Row() {
    Text($r('app.string.lazy_foreach'))
      .fontSize($r('app.float.header_font_size'))
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Start)
      .width('100%')
      .fontFamily('HarmonyHeiTi-Bold')
      .padding({ left: $r('app.float.md_padding_margin') })
  }
  .height($r('app.float.top_navigation_height'))
  .margin({ top: $r('app.float.lg_padding_margin') })
}
